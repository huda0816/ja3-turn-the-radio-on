GameVar("gv_HUDA_Reinforcements", {})

function OnMsg.TurnStart()

	local reinforcementList = gv_HUDA_Reinforcements and table.copy(gv_HUDA_Reinforcements) or empty_table

	for i, reinforcements in ipairs(reinforcementList) do
		if g_Combat.current_turn >= reinforcements.arrival then
			HUDA_ReinforcementArrival(reinforcements.squad, reinforcements.sector_id, reinforcements.direction)
			table.remove(gv_HUDA_Reinforcements, i)
		end
	end
end

function OnMsg.CombatEnd()

	local reinforcementList = gv_HUDA_Reinforcements and table.copy(gv_HUDA_Reinforcements) or empty_table

	for i, reinforcements in ipairs(gv_HUDA_Reinforcements or empty_table) do
		HUDA_ReinforcementArrival(reinforcements.squad, reinforcements.sector_id, reinforcements.direction)
		table.remove(gv_HUDA_Reinforcements, i)
	end
end

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

function HUDA_GetReinforcementAp(unit)

	-- higher leadership will reduce the AP costs

	local baseCosts = 5000

	local leadership = unit.Leadership

	local adjustedCosts = baseCosts + (100 - leadership) * 10

	return adjustedCosts

end

function HUDA_ReinforcementArrival(squad, sector_id, direction)
	HUDA_SetSatelliteSquadCurrentSector(squad, gv_CurrentSectorId, sector_id)
	HUDA_SpawnReinforcements(squad, direction)
	-- ShowTacticalNotification('HUDA_AlliedReinforcementArrival', nil, nil, {})
end

function HUDA_SendReinforcements(squad, sector_id, direction, turns, caller)
	if g_Combat then
		gv_HUDA_Reinforcements = gv_HUDA_Reinforcements or {}

		if caller then
			local reinforcementAP = HUDA_GetReinforcementAp(caller)
			caller:ConsumeAP(reinforcementAP)
		end

		local reinforcements = {
			squad = squad,
			sector_id = sector_id,
			direction = direction,
			arrival = (g_Combat.current_turn or 0) + (turns or 2)
		}

		table.insert(gv_HUDA_Reinforcements, reinforcements)
	else
		CreateRealTimeThread(function()
			Sleep(100000)
			HUDA_ReinforcementArrival(squad, sector_id, direction)
		end)
	end
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

PlaceObj('TacticalNotification', {
	SortKey = -9000,
	combatLog = true,
	combatLogType = "important",
	id = "HUDA_AlliedReinforcementArrival",
	style = "green",
	text = T(30425811312000000816, 'Your reinforcements have arrived!'),
	duration = 3000,
})

PlaceObj('TacticalNotification', {
	SortKey = -9000,
	combatLog = true,
	combatLogType = "important",
	id = "HUDA_EnemyReinforcementArrival",
	style = "red",
	text = T(30425811312000010817, 'Enemy reinforcements have arrived!'),
	duration = 3000,
})
