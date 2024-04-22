local ExplorationBombardTickLen = 500

local function ExplorationBombardUpdate()
	if g_Combat or IsSetpiecePlaying() then return end
	local activate_zone
	local deactivate_zones = {}
	for idx, zone in ipairs(g_Bombard) do
		if zone.action_id ~= "BombardRemote" and zone.attacker and zone.attacker.combat_behavior ~= "PreparedBombardIdle" and zone.attacker.combat_behavior ~= "PrepareBombard" then
			deactivate_zones[#deactivate_zones + 1] = idx
		elseif zone.remaining_time >= 0 then
			zone.remaining_time = Max(0, zone.remaining_time - ExplorationBombardTickLen)
			if zone.remaining_time == 0 then
				if not activate_zone or activate_zone.attacker and not zone.attacker then
					activate_zone = zone
				end
			elseif zone.timer_text then
				zone.timer_text.ui.idText:SetText(Untranslated(zone.remaining_time / 1000))
			end
		end
	end
	for _, idx in ipairs(deactivate_zones) do
		local zone = table.remove(g_Bombard, idx)
		if IsValid(zone.attacker) then
			zone.prepared_bombard_zone = nil
		end
		if IsValid(zone) then
			DoneObject(zone)
		end
	end
	if activate_zone and not IsValidThread(bombard_activate_thread) then -- only one bombardment at a time
		bombard_activate_thread = CreateGameTimeThread(function()
			if IsValid(activate_zone.attacker) then
				activate_zone.attacker:StartBombard() -- consume ammo
			end
			activate_zone:Activate()
			table.remove_value(g_Bombard, g_Bombard)
			bombard_activate_thread = false
		end)
	end
end

MapGameTimeRepeat("ExplorationBombard", ExplorationBombardTickLen, ExplorationBombardUpdate)

function BombardZone:Activate()
	if self.action_id == "BombardRemote" then
		BombardRemoteZoneActivate(self)
		return
	end
    if not self:IsValidZone() then
        DoneObject(self)
        return
    end
    local attacker = self.attacker
    local pos = self:GetPos()
    if attacker and attacker.command == "PreparedBombardIdle" then
        if g_Combat and attacker:GetEnumFlags(const.efVisible) ~= 0 then
            SnapCameraToObj(attacker)
        end
        attacker:SetState("nw_Standing_MortarFire")
        local duration = attacker:TimeToAnimEnd()
        local firing_time = duration
        local weapon = attacker:GetActiveWeapons()
        local visual_weapon = weapon and weapon:GetVisualObj()
        for i = 1, self.num_shots do
            if IsValid(visual_weapon) and attacker.command == "PreparedBombardIdle" then
                attacker:SetState("nw_Standing_MortarFire")
                PlayFX("MortarFire", "start", visual_weapon)
                duration = attacker:TimeToAnimEnd()
                Sleep(duration)
                PlayFX("MortarFiring", "end", visual_weapon)
                if (i + 1) <= self.num_shots then
                    attacker:SetState("nw_Standing_MortarLoad")
                    duration = attacker:TimeToAnimEnd()
                    Sleep(duration)
                else
                    attacker:InterruptPreparedAttack()
                    SnapCameraToObj(pos)
                end
            end
        end
    end
    if g_Combat then
        LockCameraMovement("bombard")
        AdjustCombatCamera("set", nil, self)
    end
    -- Sleep(const.Combat.BombardSetupHoldTime)
    if IsSetpiecePlaying() then
        return
    end
    local ordnance = PlaceInventoryItem(self.ordnance)
    local radius = self.radius * const.SlabSizeX
    local fall_threads = {}
    -- if self.visual then
    --     Sleep(600)
    --     DoneObject(self.visual)
    --     self.visual = nil
    -- end
    if self.timer_text then
        self.timer_text:delete()
        self.timer_text = false
    end
    if self.side == "player1" or self.side == "player2" or self.side == "neutral" then
        ShowTacticalNotification("allyMortarFire", true)
    else
        ShowTacticalNotification("enemyMortarFire", true)
    end
    for i = 1, self.num_shots do
        do
            local dist = InteractionRand(radius, "Bombard")
            local angle = InteractionRand(7000 * i, "Bombard")
            if self.side == "player1" or self.side == "player2" then
                dist, angle = HUDA_BombardAccuracyCheck(attacker, radius, i, self.num_shots, pos)
            end
            local fall_pos = RotateRadius(dist, angle, pos):SetTerrainZ(const.SlabSizeZ / 2)
            local sky_pos = fall_pos + point(0, 0, 100 * guim)
            if 0 < self.bombard_offset then
                sky_pos = RotateRadius(self.bombard_offset, self.bombard_dir, sky_pos)
            end
            local col, pts = CollideSegmentsNearest(sky_pos, fall_pos)
            if col then
                fall_pos = pts[1]
            end
            fall_threads[i] = CreateGameTimeThread(function()
                local visual = PlaceObject("OrdnanceVisual")
                visual:ChangeEntity(ordnance.Entity or "MilitaryCamp_Grenade_01")
                visual.fx_actor_class = self.ordnance
                visual:SetPos(sky_pos)
                local fall_time = MulDivRound(sky_pos:Dist(fall_pos), 1000, const.Combat.MortarFallVelocity)
                visual:SetPos(fall_pos, fall_time)
                Sleep(fall_time)
                if not IsSetpiecePlaying() then
                    ExplosionDamage(self.attacker, ordnance, fall_pos, visual)
                end
                DoneObject(visual)
                Msg(CurrentThread())
            end)
            Sleep(self.ordnance_launch_delay)
        end
    end
    for _, thread in ipairs(fall_threads) do
        if IsValidThread(thread) then
            WaitMsg(thread, 1000)
        end
    end
    if self.side == "player1" or self.side == "player2" or self.side == "neutral" then
        HideTacticalNotification("allyMortarFire")
    else
        HideTacticalNotification("enemyMortarFire")
    end
    DoneObject(ordnance)
    DoneObject(self)
    if IsValid(self.attacker) then
        -- self.attacker:InterruptPreparedAttack()
    end
end

function BombardRemoteZoneActivate(self)
	local ordnance = g_Classes[self.ordnance]
	if not (self.radius and self.side and ordnance and self.num_shots > 0) then
		DoneObject(self)
		return
	end

	local attacker = self.attacker
	local pos = self:GetPos()
	if attacker then

		self.attacker:InterruptPreparedAttack()
		if g_Combat and attacker:GetEnumFlags(const.efVisible) ~= 0 then
			SnapCameraToObj(attacker)
		end
	end

	--No need to reset them as it is assumed AIExecutionController:Done to run later on.
	if g_Combat then
		LockCameraMovement("bombard")
		AdjustCombatCamera("set", nil, self)
	end

	Sleep(const.Combat.BombardSetupHoldTime)
	if IsSetpiecePlaying() then return end
	
	local ordnance = PlaceInventoryItem(self.ordnance)
	assert(ordnance) -- IsValidZone checks the template already
	
	local radius = self.radius * const.SlabSizeX
	local fall_threads = {}
	
	if self.visual then
		Sleep(600) -- delay to match camera transition
		DoneObject(self.visual)
		self.visual = nil
	end
	if self.timer_text then
		self.timer_text:delete()
		self.timer_text = false
	end
	
	--[[if IsValid(self.attacker) then
		local weapon = self.attacker:GetActiveWeapons()
		local visual_obj = weapon:GetVisualObj(self)
		PlayFX("WeaponFire", "start", visual_obj, nil, nil, axis_z)
	end--]]
	
	if self.side == "player1" or self.side == "player2" or self.side == "neutral" then
		ShowTacticalNotification("allyMortarFire",true)
	else 
		ShowTacticalNotification("enemyMortarFire",true)
	end
	for i = 1, self.num_shots do
		-- pick a random position in the circle
		local dist = InteractionRand(radius, "Bombard")
		local angle = InteractionRand(360*60, "Bombard")
		if self.side == "player1" or self.side == "player2" then
			dist, angle = HUDA_BombardAccuracyCheck(attacker, radius, i, self.num_shots, pos)
		end
		local fall_pos = RotateRadius(dist, angle, pos):SetTerrainZ(const.SlabSizeZ / 2)
		local sky_pos = fall_pos + point(0, 0, 100*guim)

		if self.bombard_offset > 0 then
			sky_pos = RotateRadius(self.bombard_offset, self.bombard_dir, sky_pos)
		end

		-- find the explosion pos (collision from the sky downwards)
		local col, pts = CollideSegmentsNearest(sky_pos, fall_pos)
		if col then
			fall_pos = pts[1]
		end
		
		-- animate the fall
		fall_threads[i] = CreateGameTimeThread(function()
			local visual = PlaceObject("OrdnanceVisual")
			visual:ChangeEntity(ordnance.Entity or "MilitaryCamp_Grenade_01")
			visual.fx_actor_class = self.ordnance
			visual:SetPos(sky_pos)		
			local fall_time = MulDivRound(sky_pos:Dist(fall_pos), 1000, const.Combat.MortarFallVelocity)
			visual:SetPos(fall_pos, fall_time)
			Sleep(fall_time)
			if not IsSetpiecePlaying() then 			
				-- trigger explosion based on <ordnance>
				ExplosionDamage(self.attacker, ordnance, fall_pos, visual)
			end
			DoneObject(visual)
			Msg(CurrentThread())
		end)
		Sleep(self.ordnance_launch_delay)
	end
	
	for _, thread in ipairs(fall_threads) do
		if IsValidThread(thread) then
			WaitMsg(thread, 1000)
		end
	end

	if self.side == "player1" or self.side == "player2" or self.side == "neutral" then
		HideTacticalNotification("allyMortarFire")
	else 
		HideTacticalNotification("enemyMortarFire")
	end
	
	DoneObject(ordnance)
	DoneObject(self)
	if IsValid(self.attacker) then
		self.attacker:InterruptPreparedAttack()
	end
end