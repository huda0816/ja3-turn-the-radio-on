return {
	PlaceObj('ModItemCode', {
		'CodeFileName', "Code/Script.lua",
	}),
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
	PlaceObj('ModItemFolder', {
		'name', "New folder",
	}),
	PlaceObj('ModItemCode', {
		'name', "Mortar",
		'CodeFileName', "Code/Mortar.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Reinforcements",
		'CodeFileName', "Code/Reinforcements.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "RemoteMortarstrike",
		'CodeFileName', "Code/RemoteMortarstrike.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "MortarStrike",
		'CodeFileName', "Code/MortarStrike.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Radio",
		'CodeFileName', "Code/Radio.lua",
	}),
	PlaceObj('ModItemTextStyle', {
		RolloverTextColor = 4281612093,
		TextColor = 4281612093,
		TextFont = T(161756368563, --[[ModItemTextStyle HUDA_Radio TextFont]] "Source Code Pro, 14"),
		group = "Default",
		id = "HUDA_Radio",
	}),
	PlaceObj('ModItemSoundPreset', {
		group = "Default",
		id = "HUDA_RadioStatic",
		type = "IngameUI",
		PlaceObj('Sample', {
			'file', "Mod/a7iPvXU/Sounds/police-radio-bleep-edit.wav",
		}),
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_Bombard",
		'CodeFileName', "Code/OR_Bombard.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "X_Radio",
		'CodeFileName', "Code/X_Radio.lua",
	}),
}