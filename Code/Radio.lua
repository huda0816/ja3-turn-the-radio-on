PlaceObj('CombatAction', {
	ActionPoints = 2000,
	ActivePauseBehavior = "queue",
	ConfigurableKeybind = false,
	Description = T(10576542073808170816, --[[CombatAction UseRadio Description]] "Use Radio"),
	DisplayName = T(0816615556944457, --[[CombatAction CapturePOW DisplayName]] "UseRadio"),
	GetAPCost = function(self, unit, args)
		return 0
	end,
	GetAttackWeapons = function(self, unit, args)
		local item
		local res = unit:ForEachItem("HUDA_Radio", function(itm, slot)
			-- if itm.Condition > 0 then
			item = itm
			return "break"
			-- end
		end, item)
		return item
	end,
	GetUIState = function(self, units, args)
		local unit = units[1]

		if g_Combat and not unit:HasAP(self.ActionPoints) then
			return "disabled", GetUnitNoApReason(unit)
		end

		return "enabled"
	end,
	Icon = "Mod/LXPER6t/Icons/use_radio.png",
	IdDefault = "Useradiodefault",
	IsAimableAttack = false,
	MoveStep = true,
	MultiSelectBehavior = "first",
	Parameters = {},
	QueuedBadgeText = T(989605585095, --[[CombatAction Bandage QueuedBadgeText]] "USE RADIO"),
	RequireState = "any",
	RequireWeapon = true,
	Run = function(self, unit, ap, ...)
		unit:SetActionCommand("UseRadio", self.id, ap, ...)
	end,
	SortKey = 10,
	UIBegin = function(self, units, args)
		CombatActionUseRadioStart(self, units, args)
	end,
	group = "Default",
	id = "UseRadio",
})


function CombatActionUseRadioStart(self, units, args, mode, noChangeAction)
	HUDA_SpawnRadioDialog()


	-- mode = mode or "IModeCombatAttackBase"

	-- local unit = units[1]
	-- if IsValidThread(CombatActionStartThread) then
	-- 	DeleteThread(CombatActionStartThread)
	-- end
	-- CombatActionStartThread = CreateRealTimeThread(function()
	-- 	if g_Combat then
	-- 		WaitCombatActionsEnd(unit)
	-- 	end
	-- 	if not IsValid(unit) or unit:IsDead() or not unit:CanBeControlled() then
	-- 		return
	-- 	end
	-- 	if PlayerActionPending(unit) then
	-- 		return
	-- 	end
	-- 	if not g_Combat and not unit:IsIdleCommand() then
	-- 		NetSyncEvent("InterruptCommand", unit, "Idle")
	-- 	end

	-- 	local target = args and args.target
	-- 	local freeAim = args and args.free_aim or not UIAnyEnemyAttackGood(self)
	-- 	if freeAim and not g_Combat and self.basicAttack and self.ActionType == "Melee Attack" then
	-- 		local action = GetMeleeAttackAction(self, unit)
	-- 		freeAim = action.id ~= "CancelMark"
	-- 	end
	-- 	freeAim = freeAim and (self.id ~= "CancelMark")
	-- 	if not self.IsTargetableAttack and IsValid(target) and freeAim then
	-- 		local ap = self:GetAPCost(unit, args)
	-- 		NetStartCombatAction(self.id, unit, ap, args)
	-- 		return
	-- 	end

	-- 	if mode == "IModeCombatMelee" and target then
	-- 		local weapon = self:GetAttackWeapons(unit)
	-- 		local ok, reason = unit:CanAttack(target, weapon, self)
	-- 		if not ok then
	-- 			ReportAttackError(args.target, reason)
	-- 			return
	-- 		end
	-- 		--if not IsMeleeRangeTarget(unit, nil, nil, target) then			
	-- 		--ReportAttackError(args.target, AttackDisableReasons.CantReach)
	-- 		--return
	-- 		--end
	-- 	end

	-- 	-- Check what actually needs switching
	-- 	local changeNeeded, dlg, targetGiven = CombatActionChangeNeededTryRetainTarget(mode, self, unit, target, freeAim)

	-- 	-- Clicking a single target skill twice will cause the attack to proceed
	-- 	if not changeNeeded then
	-- 		if dlg.crosshair then
	-- 			dlg.crosshair:Attack()
	-- 		else
	-- 			dlg:Confirm()
	-- 		end
	-- 		return
	-- 	end

	-- 	-- Changing actions requires notifying the dialog to exit quietly.
	-- 	if changeNeeded == "change-action" then
	-- 		dlg.context.changing_action = true
	-- 	end

	-- 	-- It is possible for the unit to have been deselected in all our waiting.
	-- 	-- Of for the action to have been disabled.
	-- 	local state = self:GetUIState(units)
	-- 	if not SelectedObj or state ~= "enabled" then
	-- 		return
	-- 	end

	-- 	-- Patch selection outside of combat to remove multiselection
	-- 	-- We're not doing this through SelectObj as the selection changed msg
	-- 	-- will cancel the action.
	-- 	if not g_Combat then
	-- 		Selection = { unit }
	-- 	end

	-- 	local modeDlg = GetInGameInterfaceModeDlg()
	-- 	modeDlg.dont_return_camera_on_close = true
	-- 	SetInGameInterfaceMode(mode, {
	-- 		action = self,
	-- 		attacker = unit,
	-- 		target = target,
	-- 		aim = args and args.aim,
	-- 		free_aim = freeAim,
	-- 		changing_action = changeNeeded == "change-action"
	-- 	})
	-- end)
end

function HUDA_SpawnRadioDialog()
	local popupHost = GetDialog("InGameInterface")

	local reinforcementSquads = HUDA_GetAdjacentAlliedSquads(gv_CurrentSectorId, "needRadio")

	local mortarSquads = HUDA_GetAdjacentMortarSquads(gv_CurrentSectorId)

	OpenDialog("HUDAReinforcmentsDialog", popupHost, {
		reinforcementSquads = reinforcementSquads,
		mortarSquads = mortarSquads,
		mortarAmmo = { { value = "MortarShell_HE", name = "HE" }, { value = "MortarShell_Gas", name = "GAS" }, { value = "MortarShell_Smoke", name = "SMOKE" } },
		mortarRounds = { { value = 1, name = "1" }, { value = 2, name = "2" }, { value = 3, name = "3" }, { value = 4, name = "4" }, { value = 5, name = "5" } },
		mortarSpacing = { { value = 2, name = "NARROW" }, { value = 4, name = "NORMAL" }, { value = 6, name = "WIDE" } },
		Mode = "radioactions"
	})

end