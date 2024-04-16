function HUDA_ReinforceEnemy()
	local cardinalSectors = HUDA_GetCardinalSectors(gv_CurrentSectorId)

	for direction, sector_id in pairs(cardinalSectors) do
		local sector = gv_Sectors[sector_id]

		if sector.enemy_squads then
			for i, squad in ipairs(sector.enemy_squads) do
				HUDA_SendReinforcements(squad, sector_id, direction)
			end
		end
	end
end

function HUDA_SendReinforcements(squad, sector_id, direction)
	CreateRealTimeThread(function()
		Sleep(10000)
		HUDA_SetSatelliteSquadCurrentSector(squad, gv_CurrentSectorId, sector_id)
		HUDA_SpawnReinforcements(squad, direction)
		CombatLog("important", Untranslated("Reinforcements have arrived"))
	end)
end

function HUDA_SetSatelliteSquadCurrentSector(squad, sector_id, prev_sector_id)
	RemoveSquadFromSectorList(squad, squad.CurrentSector)
	AddSquadToSectorList(squad, sector_id)

	squad.arrive_in_sector = false
	squad.PreviousSector = prev_sector_id
	squad.CurrentSector = sector_id
	local sector = gv_Sectors[sector_id]
	squad.returning_water_travel = false
	squad.water_route = false
	SetSquadWaterTravel(squad, false)
	squad.route = false
	squad.uninterruptable_travel = false

	Msg("SquadSectorChanged", squad)

	squad.XVisualPos = sector.XMapPosition
	squad.traversing_shortcut_start_sId = false
	squad.traversing_shortcut_start = false
	Msg("SquadTeleported", squad)

	if not g_SatelliteUI then return end
	if squad.Side ~= "player1" or gv_Sectors[sector_id .. "_Underground"] or gv_Sectors[prev_sector_id .. "_Underground"] then
		g_SatelliteUI:UpdateSectorVisuals(prev_sector_id)
		g_SatelliteUI:UpdateSectorVisuals(sector_id)
	end

	ObjModified(gv_Squads)
	ObjModified(squad)
	ObjModified(gv_Sectors[sector_id])
end

function HUDA_SpawnReinforcements(squad, direction)
	local units = squad.units
	local bestExitZone = HUDA_GetBestExitZoneInteractable(direction)
	local positions = bestExitZone:GetRandomPositions(#units)

	SpawnSquadUnits(units, positions)

	-- local units = squad.units
	-- local bestExitZone = HUDA_GetBestExitZoneInteractable(direction)
	-- local positions = bestExitZone:GetRandomPositions(#units)
	for i = 1, #positions do
		local unit = g_Units[units[i]]
		if not IsMerc(unit) then
			unit:SetSide('enemy1')
			-- unit:AddStatusEffect('ReinforcementProtection')
			unit:AddStatusEffect('Suspicious')
			TriggerUnitAlert("surprise", unit, "suspicious")
		else
			unit:SetSide('player1')
		end
	end
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
