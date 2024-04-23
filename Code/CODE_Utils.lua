


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
		if reinforcements.squad.UniqueId == squad.UniqueId then
			return true
		end
	end

	return IsSquadTravelling(squad)
end

function HUDA_GetAdjacentAlliedSquads(sector_id, needRadio)

	local cardinalSectors = HUDA_GetCardinalSectors(sector_id)

	local adjacentSquads = {}

	for direction, sector_id in pairs(cardinalSectors) do
		local sector = gv_Sectors[sector_id]

		local squads = sector.ally_and_militia_squads

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
				sectorId = sector_id,
				name = squad.Name
			})

			::continue::
		end
	end

	return adjacentSquads
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