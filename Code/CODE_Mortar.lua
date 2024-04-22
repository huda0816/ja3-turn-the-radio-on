function OnMsg.ClassesGenerate()
	Mortar.GetMishapChance = HUDA_BombardMishapChance
	Mortar.GetMishapDeviationVector = HUDA_BombardMishapDeviationVector

	function Mortar:ValidatePos(aim_pt)
		local attacker = SelectedObj

		if not attacker.team.player_team then
			return aim_pt
		end

		if HasPerk(attacker, "DangerClose") then
			return aim_pt
		end
		local weapon = attacker ~= self.owner and self or attacker:GetActiveWeapons(attacker)
		local pt = GetCursorPos(self.movement_mode and "walkable")
		local lof_params = {
			weapon = weapon,
			step_pos = attacker:GetOccupiedPos(),
			stance = "Standing",
			prediction = true
		}

		local action_id = attacker ~= self.owner and "BombardRemote" or "Bombard"

		local attack_data = attacker:ResolveAttackParams(action_id, pt, lof_params)
		local attacker_pos3D = attack_data.step_pos
		if not attacker_pos3D:IsValidZ() then
			attacker_pos3D = attacker_pos3D:SetTerrainZ()
		end
		local min_aim_range = attacker.session_id ~= self.owner and 0 or 15 * const.SlabSizeX
		if min_aim_range and IsCloser(attacker_pos3D, aim_pt, min_aim_range - 1) then
			aim_pt = attacker_pos3D + SetLen(aim_pt - attacker_pos3D, min_aim_range)
		end
		return aim_pt
	end

	-- function Mortar:GetJamChance(condition)
	--     local jam_chance = (100 - condition) / 4
	--     if GameState.RainHeavy or GameState.RainLight or GameState.DustStorm then
	--         jam_chance = MulDivRound(jam_chance, 100 + const.EnvEffects.RainJamChanceMod, 100)
	--     end
	--     return jam_chance
	-- end

	function Mortar:GetAttackResults(action, attack_args)
		local attacker = attack_args.obj

		local prediction = attack_args.prediction
		local trajectory, stealth_kill

		local lof_idx = table.find(attack_args.lof, "target_spot_group", attack_args.target_spot_group or "Torso")

		local lof_data = (attack_args.lof or empty_table)[lof_idx or 1]

		-- local target_pos = not attack_args.target_pos and (not lof_data or not lof_data.target_pos) and IsValid(attack_args.target) and attack_args.target:GetPos()
		local target_pos = attack_args.target_pos

		local ordnance = attack_args.action_id == "BombardRemote" and attack_args.ordnance or self.ammo

		if not target_pos:IsValidZ() then
			target_pos = target_pos:SetTerrainZ()
		end

		local mishap
		if not prediction and not attack_args.explosion_pos and IsKindOf(self, "MishapProperties") then
			local chance = self:GetMishapChance(attacker, target_pos)
			if CheatEnabled("AlwaysMiss") or chance > 40 then
				mishap = true
			end
		end
		if not attack_args.explosion_pos and
			(not ((trajectory and #trajectory ~= 0 or self.trajectory_type == "bombard") and self.ammo) or 0 >=
				self.ammo.Amount) then
			return {}
		end
		local jammed, condition = false, false
		if prediction then
			attack_args.jam_roll = 0
			attack_args.condition_roll = 0
		else
			attack_args.jam_roll = attack_args.jam_roll or 1 + attacker:Random(100)
			attack_args.condition_roll = attack_args.condition_roll or 1 + attacker:Random(100)
			jammed, condition = self:ReliabilityCheck(attacker, 1, attack_args.jam_roll, attack_args.condition_roll)
		end
		if jammed then
			return {
				jammed = true,
				condition = condition
			}
		end
		local impact_pos = attack_args.explosion_pos or trajectory and 0 < #trajectory and trajectory[#trajectory].pos or
			target_pos
		local aoe_params = self:GetAreaAttackParams(action.id, attacker, impact_pos)
		aoe_params.stealth_kill = stealth_kill
		if attack_args.stealth_attack then
			aoe_params.stealth_attack_roll = not prediction and attacker:Random(100) or 100
		end
		aoe_params.prediction = prediction
		local results = GetAreaAttackResults(aoe_params, nil, not prediction and ordnance.AppliedEffects)
		results.trajectory = trajectory
		results.ordnance = ordnance
		results.weapon = ordnance
		results.jammed = jammed
		results.condition = condition
		results.fired = not jammed and 1
		results.mishap = mishap
		results.burn_ground = ordnance.BurnGround
		results.explosion_pos = target_pos
		if not jammed then
			results.fired = Min(attack_args.bombard_shots, ordnance.Amount)
		end
		CompileKilledUnits(results)

		return results
	end

	MortarInventoryItem.MagazineSize = 6

	MortarShell_HE.CenterUnitDamageMod = 200
	MortarShell_HE.CenterObjDamageMod = 500
	MortarShell_HE.CenterAppliedEffects = {
		"Suppressed",
	}
	MortarShell_HE.AreaOfEffect = 4
	MortarShell_HE.CenterAreaOfEffect = 2
	MortarShell_HE.AreaAppliedEffects = {
		"Suppressed",
	}
	MortarShell_HE.PenetrationClass = 4
	MortarShell_HE.BurnGround = false
	MortarShell_HE.BaseDamage = 30
end
