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