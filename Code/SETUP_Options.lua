function OnMsg.ApplyModOptions(mod_id)
	if mod_id == CurrentModId and CurrentModOptions then
		if CurrentModOptions["HUDA_MortarAdjustments"] then
			MortarInventoryItem.MagazineSize = 6

			MortarShell_HE.CenterUnitDamageMod = 200
			MortarShell_HE.CenterObjDamageMod = 500
			MortarShell_HE.CenterAppliedEffects = {
				"Suppressed",
			}
			MortarShell_HE.AreaOfEffect = 4
			MortarShell_HE.CenterAreaOfEffect = 2
			MortarShell_HE.AreaAppliedEffects = {
				"Suppressed",
			}
			MortarShell_HE.PenetrationClass = 4
			MortarShell_HE.BurnGround = false
			MortarShell_HE.BaseDamage = 30
		end
	end
end
