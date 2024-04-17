-- function OnMsg.ModsReloaded()
CombatActions.Bombard.GetActionDescription = function(self, units)
	local attacks = 1

	local unit = units[1]

	if not unit.team.player_team then
		attacks = unit and (unit:GetUIActionPoints() / (self:ResolveValue("ap_per_shot") * const.Scale.AP)) or 1
	else
		attacks = HUDAGetMaxAttacks(self, units[1])
	end

	attacks = HUDAGetMaxAttacks(self, units[1])

	return T {
		self.Description,
		attacks = attacks
	}
end

CombatActions.Bombard.GetUIState = function(self, units, args)
	local attacks = HUDAGetMaxAttacks(self, units[1])

	if attacks < 1 then
		return "disabled", AttackDisableReasons.NoAP
	end

	return CombatActionGenericAttackGetUIState(self, units, args)
end

CombatActions.Bombard.GetMinAimRange = function()
	return 15
end

CombatActions.Bombard.GetActionResults = function(self, unit, args)
	local weapon = self:GetAttackWeapons(unit, args)
	local target = ResolveGrenadeTargetPos(args.target)
	local ammos = weapon and unit:GetAvailableAmmos(weapon, nil, "unique")
	if not weapon or not target or not ammos then
		return {}
	end
	local args = table.copy(args)
	local cost_ap = args.spent_ap or self:GetAPCost(unit)

	if unit.team.player_team then
		weapon.BombardRadius = (self.bombard_radius * self.bombard_shots) / 3
		args.bombard_shots = self.bombard_shots
	else
		args.bombard_shots = cost_ap / (self:ResolveValue("ap_per_shot") * const.Scale.AP)
	end

	args.weapon = weapon
	args.target = target
	args.ordnance = args.ordnance or ammos[1]
	args.can_use_covers = false

	local attack_args = unit:PrepareAttackArgs(self.id, args)
	local results = weapon:GetAttackResults(self, attack_args)
	return results, attack_args
end

CombatActions.Bombard.UIBegin = function(self, units, args)
	if units[1].team.player_team then
		HUDA_SpawnMortarStrikeDialog()
	else
		CombatActionAttackStart(self, units, args, "IModeCombatAreaAim")
	end
end
-- -- end

local HUDA_Original_CombatActionAttackStart = CombatActionAttackStart

function CombatActionAttackStart(self, units, args, mode, noChangeAction)
	if self.id == "Bombard" and mode == "IModeCombatFreeAim" then
		return CombatActions.Bombard.UIBegin(self, units, args)
	end

	return HUDA_Original_CombatActionAttackStart(self, units, args, mode, noChangeAction)
end

function HUDA_SpawnMortarStrikeDialog()
	local popupHost = GetDialog("InGameInterface")

	OpenDialog("HUDAMortarDialog", popupHost, {
		mortarRounds = { { value = 1, name = "1" }, { value = 2, name = "2" }, { value = 3, name = "3" }, { value = 4, name = "4" }, { value = 5, name = "5" } },
		mortarSpacing = { { value = 2, name = "NARROW" }, { value = 4, name = "NORMAL" }, { value = 6, name = "WIDE" } }
	})
end

function HUDABombardMishapChance(attacker, target, async)
	local new_attacker = attacker

	if IsKindOf(target, "Unit") then
		new_attacker = target
	end

	local accuracy = Max(0, round(HUDAAccuracyCheck(new_attacker), 1))

	if (accuracy < 60) then
		HUDAShowMishapNotification(new_attacker)
	end

	if (accuracy < 60) then
		PlayVoiceResponse(new_attacker, "AimAttack_Low")
	end

	return 100 - accuracy
end

function HUDABombardMishapDeviationVector(item, attacker, target)
	return point(0, 0, 0)
end

function HUDAShowMishapNotification(attacker)
	if attacker.team.player_team then
		local text = attacker:GetActiveWeapons().DisplayName
		HideTacticalNotification("playerAttack")
		ShowTacticalNotification("playerAttack", false, T({
			989807512852,
			"<attack> Mishap",
			attack = text
		}))
	else
		local text = GetTacticalNotificationText("enemyAttack") or attacker:GetActiveWeapons().DisplayName
		HideTacticalNotification("enemyAttack")
		ShowTacticalNotification("enemyAttack", false, T({
			989807512852,
			"<attack> Mishap",
			attack = text
		}))
	end
end

function HUDAGetMaxAttacks(self, unit)
	if not unit.team.player_team then
		return 3
	end

	local strength_points = 20

	local adjusted_strenght_points = strength_points + round((100 - unit.Strength) * strength_points / 100, 1)

	local dexterity_points = 20

	local adjusted_dexterity_points = dexterity_points + round((100 - unit.Dexterity) * dexterity_points / 100, 1)

	local adjusted_setup = round((adjusted_dexterity_points + adjusted_strenght_points) / 10, 1)

	if HasPerk(unit, "GrizzlyPerk") then
		adjusted_setup = 1
	elseif HasPerk(unit, "HeavyWeaponsTraining") then
		adjusted_setup = adjusted_setup - 2
	end

	adjusted_setup = Max(1, adjusted_setup)

	local aps = round((unit:GetUIActionPoints() + 1) / 1000, 1) - adjusted_setup;

	local shot_dexterity_points = 15 + round((100 - unit.Dexterity) * 15 / 100, 1)           -- 17

	local shot_explosives_points = 10 + round((100 - unit.Explosives) * 10 / 100, 1)         -- 20

	local adjusted_shot_setup = round((shot_dexterity_points + shot_explosives_points) / 10, 1) -- 4

	if HasPerk(unit, "HeavyWeaponsTraining") then
		adjusted_shot_setup = adjusted_shot_setup - 1
	end

	adjusted_shot_setup = Max(1, adjusted_shot_setup)

	local weapon = unit:GetActiveWeapons()

	local shots = weapon.ammo and Min(3, Min(weapon.ammo.Amount, round(aps / adjusted_shot_setup, 1))) or 0

	return shots
end

function HUDAAccuracyCheck(attacker, rand)
	local weapon = attacker:GetActiveWeapons()

	local weapon_condition = weapon.Condition

	local heavyRain = GameState.RainHeavy

	local fog = GameState.Fog

	local wisdom = attacker.Wisdom

	local wisdomWeight = 0.3

	local dexterity = attacker.Dexterity

	local dexterityWeight = 0.2

	local explosives = attacker.Explosives

	local explosivesWeight = 0.5

	local heavy_weapon_expert = HasPerk(attacker, "HeavyWeaponsTraining")

	local heavy_weapon_bonus = heavy_weapon_expert and 40 or 0

	local baseAccuracy = ((wisdom * wisdomWeight) + (dexterity * dexterityWeight) + (explosives * explosivesWeight)) +
		heavy_weapon_bonus

	local accuracy = baseAccuracy

	-- Environmental

	local weather_penalty_multiplier = 1

	if not heavy_weapon_expert then
		weather_penalty_multiplier = 1.5
	end

	local weather_penalty = 0

	if GameState.Fog then
		weather_penalty = 10
	elseif GameState.RainHeavy then
		weather_penalty = 15
	elseif GameState.DustStorm then
		weather_penalty = 15
	elseif GameState.FireStorm then
		weather_penalty = 10
	elseif GameState.LightRain then
		weather_penalty = 5
	end

	weather_penalty = weather_penalty * weather_penalty_multiplier

	if (weather_penalty > 0) then
		if rand then
			accuracy = baseAccuracy - attacker:RandRange(weather_penalty - 5, weather_penalty + 5)
		else
			accuracy = baseAccuracy - weather_penalty
		end
	end

	-- Weapon

	local weapon_rand = 0

	if weapon_condition < 70 then
		weapon_rand = rand and attacker:RandRange(30, 60) or 45
	elseif weapon_condition < 90 then
		weapon_rand = rand and attacker:RandRange(10, 30) or 20
	elseif weapon_condition < 100 then
		weapon_rand = rand and attacker:RandRange(1, 10) or 5
	end

	accuracy = accuracy - (weapon_rand * (100 - weapon_condition) / 100)

	return accuracy
end

function HUDABombardAccuracyCheck(attacker, radius, i, num_shots, pos)
	if not attacker.team.player_team then
		local dist = InteractionRand(radius, "Bombard")
		local angle = InteractionRand(21600, "Bombard")
		return dist, angle
	end

	local accuracy = HUDAAccuracyCheck(attacker, true)

	local angle_part = 21600 / num_shots;

	local dist = radius       -- InteractionRand(radius, "Bombard")
	local angle = angle_part * i -- InteractionRand(21600, "Bombard")

	if accuracy < 10 then
		dist = radius + (attacker:RandRange(-20, 20) * const.SlabSizeX)

		angle = InteractionRand(21600, "Bombard")
	elseif accuracy < 30 then
		dist = radius + (attacker:RandRange(-12, 12) * const.SlabSizeX)

		angle = InteractionRand(21600, "Bombard")
	elseif accuracy < 60 then
		CreateFloatingText(pos, T(371973388445, "Mishap!"), "FloatingTextMiss")

		dist = radius + (attacker:RandRange(-8, 8) * const.SlabSizeX)

		angle = InteractionRand(21600, "Bombard")
	elseif accuracy < 80 then
		dist = radius + (attacker:RandRange(-4, 4) * const.SlabSizeX)

		angle = angle_part * i + (attacker:RandRange(-2000, 2000))
	elseif accuracy < 100 then
		dist = radius + (attacker:RandRange(-2, 2) * const.SlabSizeX)

		angle = angle_part * i + (attacker:RandRange(-1000, 1000))
	end

	return dist, angle
end

function BombardZone:Activate()
	if not self:IsValidZone() then
		DoneObject(self)
		return
	end
	local attacker = self.attacker
	local pos = self:GetPos()
	if attacker and attacker.command == "PreparedBombardIdle" then
		if g_Combat and attacker:GetEnumFlags(const.efVisible) ~= 0 then
			SnapCameraToObj(attacker)
		end
		attacker:SetState("nw_Standing_MortarFire")
		local duration = attacker:TimeToAnimEnd()
		local firing_time = duration
		local weapon = attacker:GetActiveWeapons()
		local visual_weapon = weapon and weapon:GetVisualObj()
		for i = 1, self.num_shots do
			if IsValid(visual_weapon) and attacker.command == "PreparedBombardIdle" then
				attacker:SetState("nw_Standing_MortarFire")
				PlayFX("MortarFire", "start", visual_weapon)
				duration = attacker:TimeToAnimEnd()
				Sleep(duration)
				PlayFX("MortarFiring", "end", visual_weapon)
				if (i + 1) <= self.num_shots then
					attacker:SetState("nw_Standing_MortarLoad")
					duration = attacker:TimeToAnimEnd()
					Sleep(duration)
				else
					attacker:InterruptPreparedAttack()
					SnapCameraToObj(pos)
				end
			end
		end
	end
	if g_Combat then
		LockCameraMovement("bombard")
		AdjustCombatCamera("set", nil, self)
	end
	-- Sleep(const.Combat.BombardSetupHoldTime)
	if IsSetpiecePlaying() then
		return
	end
	local ordnance = PlaceInventoryItem(self.ordnance)
	local radius = self.radius * const.SlabSizeX
	local fall_threads = {}
	-- if self.visual then
	--     Sleep(600)
	--     DoneObject(self.visual)
	--     self.visual = nil
	-- end
	if self.timer_text then
		self.timer_text:delete()
		self.timer_text = false
	end
	if self.side == "player1" or self.side == "player2" or self.side == "neutral" then
		ShowTacticalNotification("allyMortarFire", true)
	else
		ShowTacticalNotification("enemyMortarFire", true)
	end
	for i = 1, self.num_shots do
		do
			local dist = InteractionRand(radius, "Bombard")
			local angle = InteractionRand(7000 * i, "Bombard")
			if self.side == "player1" or self.side == "player2" then
				dist, angle = HUDABombardAccuracyCheck(attacker, radius, i, self.num_shots, pos)
			end
			local fall_pos = RotateRadius(dist, angle, pos):SetTerrainZ(const.SlabSizeZ / 2)
			local sky_pos = fall_pos + point(0, 0, 100 * guim)
			if 0 < self.bombard_offset then
				sky_pos = RotateRadius(self.bombard_offset, self.bombard_dir, sky_pos)
			end
			local col, pts = CollideSegmentsNearest(sky_pos, fall_pos)
			if col then
				fall_pos = pts[1]
			end
			fall_threads[i] = CreateGameTimeThread(function()
				local visual = PlaceObject("OrdnanceVisual")
				visual:ChangeEntity(ordnance.Entity or "MilitaryCamp_Grenade_01")
				visual.fx_actor_class = self.ordnance
				visual:SetPos(sky_pos)
				local fall_time = MulDivRound(sky_pos:Dist(fall_pos), 1000, const.Combat.MortarFallVelocity)
				visual:SetPos(fall_pos, fall_time)
				Sleep(fall_time)
				if not IsSetpiecePlaying() then
					ExplosionDamage(self.attacker, ordnance, fall_pos, visual)
				end
				DoneObject(visual)
				Msg(CurrentThread())
			end)
			Sleep(self.ordnance_launch_delay)
		end
	end
	for _, thread in ipairs(fall_threads) do
		if IsValidThread(thread) then
			WaitMsg(thread, 1000)
		end
	end
	if self.side == "player1" or self.side == "player2" or self.side == "neutral" then
		HideTacticalNotification("allyMortarFire")
	else
		HideTacticalNotification("enemyMortarFire")
	end
	DoneObject(ordnance)
	DoneObject(self)
	if IsValid(self.attacker) then
		-- self.attacker:InterruptPreparedAttack()
	end
end
