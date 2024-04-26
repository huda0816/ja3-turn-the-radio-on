return {
	PlaceObj('ModItemInventoryItemCompositeDef', {
		'Id', "HUDA_Radio",
		'object_class', "InventoryItem",
		'ScrapParts', 4,
		'Repairable', false,
		'Icon', "Mod/a7iPvXU/Images/walkietalkie.png",
		'DisplayName', T(924450383399, --[[ModItemInventoryItemCompositeDef HUDA_Radio DisplayName]] "Radio"),
		'DisplayNamePlural', T(653926910588, --[[ModItemInventoryItemCompositeDef HUDA_Radio DisplayNamePlural]] "Radios"),
		'AdditionalHint', T(978187773035, --[[ModItemInventoryItemCompositeDef HUDA_Radio AdditionalHint]] "<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Can be used to call in reinforcements \n<image UI/Conversation/T_Dialogue_IconBackgroundCircle.tga 400 130 128 120> Can be used to call in mortar strikes"),
		'UnitStat', "Leadership",
		'Cost', 1200,
		'CanAppearInShop', true,
		'Tier', 2,
		'RestockWeight', 80,
		'CanBeConsumed', false,
		'PocketL_amount', 1,
		'PocketML_amount', 1,
		'Carabiner_amount', 1,
	}),
	PlaceObj('ModItemCode', {
		'name', "SETUP_Options",
		'CodeFileName', "Code/SETUP_Options.lua",
	}),
	PlaceObj('ModItemOptionToggle', {
		'name', "HUDA_MortarAdjustments",
		'DisplayName', "Adjustments of the mortar and it's HE shell",
		'Help', "Deactivate if you want vanilla behaviour or handle mortar changes with a different mod (restart necessary)",
		'DefaultValue', true,
	}),
	PlaceObj('ModItemCode', {
		'name', "CA_UseRadio",
		'CodeFileName', "Code/CA_UseRadio.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CA_BombardRemote",
		'CodeFileName', "Code/CA_BombardRemote.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CODE_Reinforcements",
		'CodeFileName', "Code/CODE_Reinforcements.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CODE_MortarStrike",
		'CodeFileName', "Code/CODE_MortarStrike.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CA_Bombard",
		'CodeFileName', "Code/CA_Bombard.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CODE_Mortar",
		'CodeFileName', "Code/CODE_Mortar.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CODE_Utils",
		'CodeFileName', "Code/CODE_Utils.lua",
	}),
	PlaceObj('ModItemTextStyle', {
		RolloverTextColor = 4281612093,
		TextColor = 4281612093,
		TextFont = T(161756368563, --[[ModItemTextStyle HUDA_Radio TextFont]] "Source Code Pro, 14"),
		group = "Default",
		id = "HUDA_Radio",
	}),
	PlaceObj('ModItemTextStyle', {
		RolloverTextColor = 4289773231,
		TextColor = 4289773231,
		TextFont = T(367926567718, --[[ModItemTextStyle HUDA_Radio_Bright TextFont]] "Source Code Pro, 14"),
		group = "Default",
		id = "HUDA_Radio_Bright",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_Bombard",
		'CodeFileName', "Code/OR_Bombard.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "X_Radio",
		'CodeFileName', "Code/X_Radio.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "X_Mortar",
		'CodeFileName', "Code/X_Mortar.lua",
	}),
}