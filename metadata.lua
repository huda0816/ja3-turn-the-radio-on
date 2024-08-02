return PlaceObj('ModDef', {
	'title', "Turn the radio on",
	'description', "This mod adds a radio item to the game which enables two actions:\n\n[list]\n[*]Call reinforcemnets\n[*]Call mortar strike\n[/list]\n\nTo be able to perform this actions there has to be an allied squad in an adjacent sector equipped with a radio. To call in a mortar strike this squad needs a mortar and shells.\n\nThe merc who is using the radio needs at least 50 leadership. Higher leadership will reduce the action cost.\n\nThe mishap chance of the mortar strike is depending on the stats of the merc who is equipped with the mortar.\n\n[b]Additionally this mod implements changes from my mortar rework mod:[/b]\n\nWhenever you use a mortar you can choose the number of rounds and the spread of the attack.\n\nThere is an option which is turned on by default which changes some of the props of the mortar and the HE shell. Deactivate it, if you do not want this changes.",
	'image', "Mod/a7iPvXU/Images/turntheradioontitle.png",
	'last_changes', "Fixed bobby ray configuration",
	'id', "a7iPvXU",
	'author', "permanent666",
	'version_minor', 3,
	'version', 767,
	'lua_revision', 233360,
	'saved_with_revision', 350233,
	'code', {
		"InventoryItem/HUDA_Radio.lua",
		"Code/SETUP_Options.lua",
		"Code/CA_UseRadio.lua",
		"Code/CA_BombardRemote.lua",
		"Code/CODE_Reinforcements.lua",
		"Code/CODE_MortarStrike.lua",
		"Code/CA_Bombard.lua",
		"Code/CODE_Mortar.lua",
		"Code/CODE_Utils.lua",
		"Code/OR_Bombard.lua",
		"Code/X_Radio.lua",
		"Code/X_Mortar.lua",
	},
	'default_options', {
		HUDA_MortarAdjustments = true,
	},
	'has_data', true,
	'saved', 1721431075,
	'code_hash', 4859296463216779399,
	'affected_resources', {
		PlaceObj('ModResourcePreset', {
			'Class', "InventoryItemCompositeDef",
			'Id', "HUDA_Radio",
			'ClassDisplayName', "Inventory item",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "TextStyle",
			'Id', "HUDA_Radio",
			'ClassDisplayName', "Text style",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "TextStyle",
			'Id', "HUDA_Radio_Bright",
			'ClassDisplayName', "Text style",
		}),
	},
	'steam_id', "3232997067",
})