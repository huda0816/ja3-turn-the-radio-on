GameVar("gv_HUDA_Reinforcements", {})

function OnMsg.TurnStart()
	-- HUDA_ReinforceEnemy()
end

function OnMsg.TurnStart()
	-- local reinforcementList = gv_HUDA_Reinforcements and table.copy(gv_HUDA_Reinforcements) or empty_table

	-- for i, reinforcements in ipairs(reinforcementList) do
	-- 	if g_Combat.current_turn >= reinforcements.arrival then
	-- 		HUDA_ReinforcementArrival(reinforcements.squad, reinforcements.sector_id, reinforcements.direction)
	-- 		table.remove(gv_HUDA_Reinforcements, i)
	-- 	end
	-- end
end

function OnMsg.CombatEnd()
	local reinforcementList = gv_HUDA_Reinforcements and table.copy(gv_HUDA_Reinforcements) or empty_table

	for i, reinforcements in ipairs(gv_HUDA_Reinforcements or empty_table) do
		HUDA_ReinforcementArrival(reinforcements.squad, reinforcements.sector_id, reinforcements.direction)
		table.remove(gv_HUDA_Reinforcements, i)
	end
end

function HUDA_ReinforceEnemy()
	local enemy_squads = HUDA_GetAdjacentSquads(gv_CurrentSectorId, false, "enemy1")

	local combatTurn = g_Combat.current_turn

	for i, squad in ipairs(enemy_squads) do
		if combatTurn < squad.minDelay then
			goto continue
		end

		-- check if there are any allied squads in the sector or adjacent sectors except the one the current sector

		local ally_squads = HUDA_GetAdjacentSquads(squad.sectorId, false, "player1")

		local isThreatened = false

		for j, ally_squad in ipairs(ally_squads) do
			if ally_squad.sectorId ~= gv_CurrentSectorId then
				isThreatened = true
				break
			end
		end

		local isOnlySquad = true

		for j, enemy_squad in ipairs(enemy_squads) do
			if enemy_squad.sectorId ~= squad.sectorId then
				isOnlySquad = false
				break
			end
		end

		-- never send reinforcements if the enemy is threatened and there is only one enemy squad
		if isThreatened and isOnlySquad then
			goto continue
		end

		if not isOnlySquad then
			HUDA_SendReinforcements(squad.squadId, squad.sectorId, squad.direction)
			goto continue
		end

		-- roll a dice to determine if the enemy will reinforce

		local roll = InteractionRand(100, "Reinforcement");

		if roll < (60 + (combatTurn - squad.minDelay) * 5) then
			HUDA_SendReinforcements(squad.squadId, squad.sectorId, squad.direction)
		end

		::continue::
	end
end

function HUDA_GetReinforcementAp(unit)
	local baseCosts = 5000

	local leadership = unit.Leadership

	local adjustedCosts = baseCosts + (100 - leadership) * 100

	return adjustedCosts
end

function HUDA_ReinforcementArrival(squad, sector_id, direction)
	HUDA_SetSatelliteSquadCurrentSector(squad, gv_CurrentSectorId, sector_id)
	HUDA_SpawnReinforcements(squad, direction) -- ShowTacticalNot
	CombatLog("important", T(30425811312000000816, 'Your reinforcements have arrived!'))
end

function HUDA_SendReinforcements(squad, sector_id, direction, turns, caller)
	TimerCreate("HUDA_Reinforcements_" .. squad.UniqueId,
		T { 30425811312000000818, "Arrival of <squad>", squad = squad.Name },
		10000 * (turns or 2))

	gv_HUDA_Reinforcements = gv_HUDA_Reinforcements or {}

	local reinforcements = {
		squad = squad,
		sector_id = sector_id,
		direction = direction,
		arrival = g_Combat and ((g_Combat.current_turn or 0) + (turns or 2))
	}

	table.insert(gv_HUDA_Reinforcements, reinforcements)

	if g_Combat then
		if caller then
			local reinforcementAP = HUDA_GetReinforcementAp(caller)
			caller:ConsumeAP(reinforcementAP)
		end
	end
end

function OnMsg.TimerFinished(timerId)
	if string.starts_with(timerId, "HUDA_Reinforcements_") then
		
		local squadId = tonumber(string.sub(timerId, 21))

		TimerDelete(timerId)

		local reinforcments

		gv_HUDA_Reinforcements = gv_HUDA_Reinforcements or {}

		for k, v in pairs(gv_HUDA_Reinforcements) do
			if v.squad.UniqueId == squadId then
				reinforcments = v
				table.remove(gv_HUDA_Reinforcements, k)
				break
			end
		end

		if not reinforcments then
			return
		end

		HUDA_ReinforcementArrival(reinforcments.squad, reinforcments.squad.CurrentSector, reinforcments.direction)
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

	-- if not g_SatelliteUI then return end
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

	for i = 1, #positions do
		local unit = g_Units[units[i]]
		if not IsMerc(unit) and not unit.militia then
			unit:SetSide('enemy1')
			-- unit:AddStatusEffect('ReinforcementProtection')
			unit:AddStatusEffect('Suspicious')
			TriggerUnitAlert("surprise", unit, "suspicious")
		elseif squad.Side == "player1" then
			unit:SetSide('player1')
		end
	end
end

function OnMsg.DataLoaded()
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
end
