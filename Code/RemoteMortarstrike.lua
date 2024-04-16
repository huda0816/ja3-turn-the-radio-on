PlaceObj('CombatAction', {
	ActionType = "Ranged Attack",
	AimType = "parabola aoe",
	Comment = "remote mortar attack",
	ConfigurableKeybind = false,
	CostBasedOnWeapon = true,
	Description = T(169779903706, --[[CombatAction Bombard Description]]
		"Setup a zone bombarded at the start of your next turn."),
	DisplayName = T(293721021077, --[[CombatAction Bombard DisplayName]] "Bombard Remote"),
	GetAPCost = function(self, unit, args)
		return 8 * const.Scale.AP
	end,
	GetActionDamage = function(self, unit, target, args)
		local weapon = self:GetAttackWeapons(unit, args)
		if weapon and IsKindOf(weapon.ammo, "Ordnance") then
			return weapon.ammo.BaseDamage
		end
		return 0
	end,
	GetActionDescription = function(self, units)
		local unit = units[1]
		local attacks = unit and (unit:GetUIActionPoints() / (self:ResolveValue("ap_per_shot") * const.Scale.AP)) or 1
		return T { self.Description, attacks = attacks }
	end,
	GetActionResults = function(self, unit, args)
		local weapon = self.attackOptions.mortar
		local target = ResolveGrenadeTargetPos(args.target)
		local ammos = weapon and self.attackOptions.unit:GetAvailableAmmos(weapon, self.attackOptions.ammo, "unique")
		if not weapon or not target or not ammos then
			return {}
		end
		local args = table.copy(args)
		local cost_ap = args.spent_ap or self:GetAPCost(unit)
		args.weapon = weapon
		args.target = target
		args.ordnance = args.ordnance or ammos and #ammos > 0 and ammos[1]
		args.can_use_covers = false
		args.bombard_shots = args.bombard_shots or self.attackOptions.rounds
		weapon.BombardRadius = (self.attackOptions.spacing * self.attackOptions.rounds) / 3
		local attack_args = unit:PrepareAttackArgs(self.id, args)
		local results = weapon:GetAttackResults(self, attack_args)
		return results, attack_args
	end,
	GetAttackWeapons = function(self, unit, args)
		if args and args.weapon then return args.weapon end

		return self.attackOptions and self.attackOptions.mortar
	end,
	GetMaxAimRange = function(self, unit, weapon)
		return 100000000000
	end,
	GetUIState = function(self, units, args)
		return CombatActionGenericAttackGetUIState(self, units, args)
	end,
	Icon = "UI/Icons/Hud/heavy_weapon_attack",
	IdDefault = "Bombardremotedefault",
	IsAimableAttack = false,
	KeybindingFromAction = "actionRedirectHeavyAttack",
	MultiSelectBehavior = "first",
	RequireState = "any",
	Run = function(self, unit, ap, ...)
		unit:SetActionCommand("PrepareRemoteBombard", self.id, ap, ...)
	end,
	SortKey = 1,
	UIBegin = function(self, units, args)
		CombatActionAttackStart(self, units, args, "IModeCombatAreaAim")
	end,
	group = "WeaponAttacks",
	id = "BombardRemote",
})

function Unit:PrepareRemoteBombard(action_id, cost_ap, args)
	local target = args.target
	if not IsPoint(target) and not IsValid(target) then
		self:GainAP(cost_ap)
		CombatActionInterruped(self)
		return
	end
	local action = CombatActions[action_id]
	args = table.copy(args)
	if cost_ap <= 0 then
		cost_ap = action:GetAPCost(self)
	end
	args.spent_ap = cost_ap
	args.prediction = false
	if not g_Combat then
		self:ExplorationStartCombatAction(action_id, cost_ap, args)
	end
	self:PushDestructor(function(self)
		self:SetBehavior()
		self:SetCombatBehavior()
	end)
	local results, attack_args = action:GetActionResults(self, args)
	self:PrepareToAttack(attack_args, results)

	-- weapon load
	local voxel_pos = GetPassSlab(self) or SnapToVoxel(self):SetZ(self:GetVisualPos():z())
	self:SetPos(voxel_pos)
	self:SetAxisAngle(axis_z, self:GetVisualOrientationAngle(), 0)
	PlayTransitionAnims(self, "nw_Standing_Idle")

	local weapon = action:GetAttackWeapons(self, args)

	if IsValid(self.prepared_bombard_zone) then
		DoneObject(self.prepared_bombard_zone)
	end
	local ordnance = results.ordnance
	local bombard_radius = weapon.BombardRadius
	local bombard_shots = results.fired
	
	HUDA_RemoveFiredAmmo(weapon, ordnance, bombard_shots)

	self.attackOptions = nil

	PlayFX("BombardZoneSetup", "start", self)

	local zone = PlaceObject("BombardZone")
	local target_pos = IsValid(target) and target:GetPos() or target

	-- mishap check & effect
	if IsKindOf(weapon, "MishapProperties") then
		local chance = weapon:GetMishapChance(self, target_pos)
		if not CheatEnabled("AlwaysHit") and (CheatEnabled("AlwaysMiss") or self:Random(100) < chance) then
			target_pos = target_pos
			self:ShowMishapNotification(action)
		end
	end

	local time
	if not g_Combat then
		time = 5000
	end

	zone.attacker = self
	zone:Setup(target_pos, bombard_radius, self.team.side, ordnance, bombard_shots, time)

	zone.action_id = action_id
	zone.weapon_id = weapon.id
	zone.weapon_condition = results.condition
	self.prepared_bombard_zone = zone

	self:ProvokeOpportunityAttacks(action, "attack reaction")

	self:PopDestructor()
	if g_Combat then
		self.ActionPoints = 0
		Msg("UnitAPChanged", self, action_id)
	end
end

function HUDA_RemoveFiredAmmo(weapon, ordnance, amount)
	local ownerId = weapon.owner
	local ammo_type = ordnance.class
	local weapon_ammo = weapon.ammo

	-- first check if the weapon has the ammo and remove as much as possible

	if weapon_ammo and weapon_ammo.class == ammo_type then
		if weapon.ammo.Amount <= amount then
			amount = amount - weapon_ammo.Amount
			weapon_ammo.Amount = 0
			weapon.ammo = nil
		else
			weapon_ammo.Amount = weapon_ammo.Amount - amount
			amount = 0
		end
	end

	if amount <= 0 then
		return
	end

	-- then check the weapon.owner items

	local owner = gv_UnitData[ownerId]

	local items = owner:GetItems()

	for i, item in ipairs(items) do
		if item.class == ammo_type then
			if item.Amount <= amount then
				amount = amount - item.Amount
				item.Amount = 0
				table.remove(items, i)
			else
				item.Amount = item.Amount - amount
				amount = 0
			end
		end

		if amount <= 0 then
			return
		end
	end

	-- then check the squad bag

	local bag = GetSquadBag(owner.Squad)

	for i, item in ipairs(bag) do
		if item.class == ammo_type then
			if item.Amount <= amount then
				amount = amount - item.Amount
				item.Amount = 0
				table.remove(bag, i)
			else
				item.Amount = item.Amount - amount
				amount = 0
			end
		end

		if amount <= 0 then
			return
		end
	end
end
