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
	Icon = "Mod/a7iPvXU/Images/use_radio.png",
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
		HUDA_SpawnRadioDialog()
	end,
	group = "Default",
	id = "UseRadio",
})

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