function HUDA_SquadHasRadio(squad)
	for i, unitId in ipairs(squad.units) do
		local unit = gv_UnitData[unitId]

		local items = unit:GetItems()

		for i, item in ipairs(items) do
			if IsKindOf(item, "HUDA_Radio") or IsKindOf(item, "CustomPDA") then
				return true
			end
		end
	end

	return false
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

function HUDA_IsSquadTravelling(squad)
	gv_HUDA_Reinforcements = gv_HUDA_Reinforcements or {}

	for i, reinforcements in ipairs(gv_HUDA_Reinforcements) do

		local squadId = reinforcements.squadId or reinforcements.squad.UniqueId -- backwards compatibility

		if squadId == squad.UniqueId then
			return true
		end
	end

	return IsSquadTravelling(squad)
end

function HUDA_GetAdjacentSquads(sector_id, needRadio, side)
	local cardinalSectors = HUDA_GetCardinalSectors(sector_id)

	local adjacentSquads = {}

	for direction, cardinal_sector_id in pairs(cardinalSectors) do
		local sector = gv_Sectors[cardinal_sector_id]

		local squads

		if side then
			squads = side == "enemy1" and sector.enemy_squads or sector.ally_and_militia_squads
		else
			squads = sector.all_squads
		end

		for i, squad in ipairs(squads) do
			if HUDA_IsSquadTravelling(squad) then
				goto continue
			end

			if needRadio and not HUDA_SquadHasRadio(squad) then
				goto continue
			end			

			table.insert(adjacentSquads, {
				squadId = squad.UniqueId,
				direction = direction,
				sectorId = cardinal_sector_id,
				name = squad.Name,
				minDelay = HUDA_GetMinimumReinforcmentDelay(squad, sector_id)
			})

			::continue::
		end
	end

	return adjacentSquads
end

function HUDA_GetMinimumReinforcmentDelay(squad, destination)

    local travelTime = GetSectorTravelTime(squad.CurrentSector, destination)

	if travelTime < 20000 then
		return 3
	elseif travelTime < 40000 then
		return 7
	elseif travelTime < 60000 then
		return 12
	end

end

function HUDA_GetAdjacentAlliedSquads(sector_id, needRadio)
	return HUDA_GetAdjacentSquads(sector_id, needRadio, "player1")
end

function HUDA_GetBestExitZoneInteractable(direction)
	local bestExitZone = false
	MapForEach("map", "ExitZoneInteractable", function(o)
		if not bestExitZone then
			bestExitZone = o
			return
		end
		local ox, oy = o:GetPosXYZ()

		local bx, by = bestExitZone:GetPosXYZ()

		if direction == "down" then
			if oy < by then
				bestExitZone = o
			end
		elseif direction == "up" then
			if oy > by then
				bestExitZone = o
			end
		elseif direction == "left" then
			if ox < bx then
				bestExitZone = o
			end
		elseif direction == "right" then
			if ox > bx then
				bestExitZone = o
			end
		end
	end)

	return bestExitZone
end
