//Fonction ACE self pour effacer les marqueurs SL2A

_deleteSl2aMarkers = [
		"deleteMkr", 
		"Purger le SL2A", 
		"",
		{ 
			{deleteMarker _x} forEach (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString});
		},
		{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
] call ace_interact_menu_fnc_createAction;
[player,1,["ACE_SelfActions"],_deleteSl2aMarkers] call ace_interact_menu_fnc_addActionToObject;
