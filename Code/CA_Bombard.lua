function OnMsg.DataLoaded()
	CombatActions.Bombard.GetActionDescription = function(self, units)
		local attacks = 1

		local unit = units[1]

		if not unit.team.player_team then
			attacks = unit and (unit:GetUIActionPoints() / (self:ResolveValue("ap_per_shot") * const.Scale.AP)) or 1
		else
			attacks = HUDA_GetMaxAttacks(units[1])
		end

		attacks = HUDA_GetMaxAttacks(units[1])

		return T {
			self.Description,
			attacks = attacks
		}
	end

	CombatActions.Bombard.GetUIState = function(self, units, args)
		local attacks = HUDA_GetMaxAttacks(units[1])

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
end

local HUDA_Original_CombatActionAttackStart = CombatActionAttackStart

function CombatActionAttackStart(self, units, args, mode, noChangeAction)
	if self.id == "Bombard" and mode == "IModeCombatFreeAim" then
		return CombatActions.Bombard.UIBegin(self, units, args)
	end

	return HUDA_Original_CombatActionAttackStart(self, units, args, mode, noChangeAction)
end
