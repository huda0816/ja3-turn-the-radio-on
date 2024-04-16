function OnMsg.TurnStart()
	HUDA_ReinforceEnemy()
end

function HUDA_GetCardinalSectors(sector_id)
	local directions = { "down", "up", "left", "right" }
	local sectors = {}
	local i = 1
	ForEachSectorCardinal(sector_id, function(sector_id)
		sectors[directions[i]] = sector_id
		i = i + 1
	end)
	return sectors
end

function HUDA_GetAdjacentAlliedSquads(sector_id, needRadio)
	local cardinalSectors = HUDA_GetCardinalSectors(sector_id)

	local adjacentSquads = {}

	for direction, sector_id in pairs(cardinalSectors) do
		local sector = gv_Sectors[sector_id]

		local squads = sector.ally_and_militia_squads

		for i, squad in ipairs(squads) do
			if needRadio and not HUDA_SquadHasRadio(squad) then
				goto continue
			end

			table.insert(adjacentSquads, {
				squadId = squad.UniqueId,
				direction = direction,
				sectorId = sector_id,
				name = squad.Name
			})

			::continue::
		end
	end

	return adjacentSquads
end

function HUDA_SquadHasRadio(squad)
	for i, unitId in ipairs(squad.units) do
		local unit = gv_UnitData[unitId]

		local items = unit:GetItems()

		for i, item in ipairs(items) do
			if IsKindOf(item, "HUDA_Radio") then
				return true
			end
		end
	end

	return false
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

function HUDA_GetAdjacentMortarSquads(sector_id)
	local adjacentSquads = HUDA_GetAdjacentAlliedSquads(sector_id, "needRadio")

	local mortarSquads = {}

	for i, prepSquad in ipairs(adjacentSquads) do
		local squad = gv_Squads[prepSquad.squadId]

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

			print("Mortar ammo", #mortarData.mortarAmmo)

			if mortarData.mortarAmmo then
				prepSquad.mortarData = mortarData

				table.insert(mortarSquads, prepSquad)
			end
		end
	end

	return mortarSquads
end
