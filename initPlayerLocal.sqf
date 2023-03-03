/* Fonctions ACE self pour la gestion du SL2A */

	_rootSl2a = [
		"rootSl2a",
		"SL2A",
		"",
		{},
		{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
	] call ace_interact_menu_fnc_createAction;
	[player,1,["ACE_SelfActions"],_rootSl2a] call ace_interact_menu_fnc_addActionToObject;

	_deleteAllSl2aMarkers = [
			"deleteAllMkr", 
			"Purger le SL2A", 
			"",
			{ 
				{deleteMarker _x} forEach (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString});
			},
			{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
	] call ace_interact_menu_fnc_createAction;
	[player,1,["ACE_SelfActions","rootSl2a"],_deleteAllSl2aMarkers] call ace_interact_menu_fnc_addActionToObject;

	_delete500Sl2aMarkers = [
			"delete500Mkr", 
			"Purger > 500 m", 
			"",
			{ 
				private _mrks = allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString};
				{
					if (parsenumber((_x splitString "_")#3)>500) then {deleteMarker _x};
				} forEach _mrks;
			},
			{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
	] call ace_interact_menu_fnc_createAction;
	[player,1,["ACE_SelfActions","rootSl2a"],_delete500Sl2aMarkers] call ace_interact_menu_fnc_addActionToObject;

	_delete400Sl2aMarkers = [
			"delete500Mkr", 
			"Purger > 400 m", 
			"",
			{ 
				private _mrks = allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString};
				{
					if (parsenumber((_x splitString "_")#3)>400) then {deleteMarker _x};
				} forEach _mrks;
			},
			{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
	] call ace_interact_menu_fnc_createAction;
	[player,1,["ACE_SelfActions","rootSl2a"],_delete400Sl2aMarkers] call ace_interact_menu_fnc_addActionToObject;

	_delete300Sl2aMarkers = [
			"delete500Mkr", 
			"Purger > 300 m", 
			"",
			{ 
				private _mrks = allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString};
				{
					if (parsenumber((_x splitString "_")#3)>300) then {deleteMarker _x};
				} forEach _mrks;
			},
			{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
	] call ace_interact_menu_fnc_createAction;
	[player,1,["ACE_SelfActions","rootSl2a"],_delete300Sl2aMarkers] call ace_interact_menu_fnc_addActionToObject;

	_delete200Sl2aMarkers = [
			"delete500Mkr", 
			"Purger > 200 m", 
			"",
			{ 
				private _mrks = allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString};
				{
					if (parsenumber((_x splitString "_")#3)>200) then {deleteMarker _x};
				} forEach _mrks;
			},
			{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
	] call ace_interact_menu_fnc_createAction;
	[player,1,["ACE_SelfActions","rootSl2a"],_delete200Sl2aMarkers] call ace_interact_menu_fnc_addActionToObject;

	_delete100Sl2aMarkers = [
			"delete500Mkr", 
			"Purger > 100 m", 
			"",
			{ 
				private _mrks = allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString};
				{
					if (parsenumber((_x splitString "_")#3)>100) then {deleteMarker _x};
				} forEach _mrks;
			},
			{count (allMapMarkers select {["mk_sl2a_", _x, true] call BIS_fnc_inString}) > 0}
	] call ace_interact_menu_fnc_createAction;
	[player,1,["ACE_SelfActions","rootSl2a"],_delete100Sl2aMarkers] call ace_interact_menu_fnc_addActionToObject;

/* Fonctions ACE self pour effacer les marqueurs SL2A */
