GameVar("gv_HUDA_Remotestrikers", {})

function OnMsg.TurnStart()
	gv_HUDA_Remotestrikers = {}
end

function OnMsg.CombatEnd()
	gv_HUDA_Remotestrikers = {}
end

function HUDA_GetAvailableMortarAmmo(squad, mortar)
	local ammo_class = "Ordnance"
	local types = mortar and mortar.ammo and { mortar.ammo } or {}
	local caliber = mortar.Caliber

	for i, unitId in ipairs(squad.units) do
		local unit = gv_UnitData[unitId]

		local slot_name = GetContainerInventorySlotName(unit)

		unit:ForEachItemInSlot(slot_name, ammo_class,
			function(ammo, slot_name, left, top, types, ammo_type, caliber, unique)
				if ammo.Caliber == caliber then
					table.insert(types, ammo)
				end
			end, types, caliber)
	end

	local bag = GetSquadBag(squad.UniqueId)
	for _, ammo in ipairs(bag) do
		if IsKindOf(ammo, ammo_class) and ammo.Caliber == caliber then
			table.insert(types, ammo)
		end
	end

	local summarizedAmmo

	for i, ammo in ipairs(types) do
		summarizedAmmo = summarizedAmmo or {}

		if not summarizedAmmo[ammo.class] then
			summarizedAmmo[ammo.class] = 0
		end
		summarizedAmmo[ammo.class] = summarizedAmmo[ammo.class] + ammo.Amount
	end

	return summarizedAmmo
end

function HUDA_DidSquadStrikeThisTurn(squad)
	gv_HUDA_Remotestrikers = gv_HUDA_Remotestrikers or {}

	for i, striker in ipairs(gv_HUDA_Remotestrikers) do
		if striker == squad.UniqueId then
			return true
		end
	end

	return false
end

function HUDA_GetStrikerSquadByWeapon(weapon)
	local ownerId = weapon.owner

	local owner = gv_UnitData[ownerId]

	if not owner then
		return
	end

	return owner.Squad
end

function HUDA_AddToStrikers(weapon)
	local squadId = HUDA_GetStrikerSquadByWeapon(weapon)

	gv_HUDA_Remotestrikers = gv_HUDA_Remotestrikers or {}

	table.insert(gv_HUDA_Remotestrikers, squadId)
end

function HUDA_GetAdjacentMortarSquads(sector_id)
	local adjacentSquads = HUDA_GetAdjacentAlliedSquads(sector_id, "needRadio")

	local mortarSquads = {}

	for i, prepSquad in ipairs(adjacentSquads) do
		local squad = gv_Squads[prepSquad.squadId]

		if g_Combat and HUDA_DidSquadStrikeThisTurn(squad) then
			goto continue
		end

		local mortarData = {}

		for i, unitId in ipairs(squad.units) do
			local unit = gv_UnitData[unitId]
			local items = unit:GetItems()
			for i, item in ipairs(items) do
				if item:IsKindOf("Mortar") then
					mortarData.mortar = item
					mortarData.mortarUnit = unit
				end
			end
		end

		if mortarData.mortar then
			mortarData.mortarAmmo = HUDA_GetAvailableMortarAmmo(squad, mortarData.mortar)

			if mortarData.mortarAmmo then
				prepSquad.mortarData = mortarData

				table.insert(mortarSquads, prepSquad)
			end
		end

		::continue::
	end

	return mortarSquads
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

function HUDA_BombardMishapChance(attacker, target, async)
	local new_attacker = attacker

	if IsKindOf(target, "Unit") then
		new_attacker = target
	end

	local accuracy = Max(0, round(HUDA_AccuracyCheck(new_attacker), 1))

	if (accuracy < 60) then
		HUDA_ShowMishapNotification(new_attacker)
	end

	if (accuracy < 60) then
		PlayVoiceResponse(new_attacker, "AimAttack_Low")
	end

	return 100 - accuracy
end

function HUDA_BombardMishapDeviationVector(item, attacker, target)
	return point(0, 0, 0)
end

function HUDA_ShowMishapNotification(attacker)
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

function HUDA_GetMaxAttacks(unit)
	if not unit.team.player_team then
		return 3
	end

	local weapon = unit:GetActiveWeapons()

	if not g_Combat then
		return Min(3, weapon.ammo and weapon.ammo.Amount or 0)
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

function HUDA_GetRemoteMortarAp(unit)
	-- higher leadership will reduce the AP costs

	local baseCosts = 7000

	local leadership = unit.Leadership

	local adjustedCosts = baseCosts + (100 - leadership) * 100

	return adjustedCosts
end

function HUDA_AccuracyCheck(attacker, rand)
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

function HUDA_BombardAccuracyCheck(attacker, radius, i, num_shots, pos)
	if not attacker.team.player_team then
		local dist = InteractionRand(radius, "Bombard")
		local angle = InteractionRand(21600, "Bombard")
		return dist, angle
	end

	local accuracy = HUDA_AccuracyCheck(attacker, true)

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
