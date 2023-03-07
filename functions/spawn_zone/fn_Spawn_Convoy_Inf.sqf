/* ----------------------------------------------------------------------------
Function: fn_spawnConvoy_Inf

Description:
	Spawns a convoy of vehicles with infantry, send it at destination and execute
	the code for infantery groups.	The convoy will drive on "SAFE" behaviour mode
	(will take roads), but will	jump in "COMBAT" behaviour mode as soon as 
	"Hit" event is fired. Must be executed in scheduled environment.

Parameters:
	_spawnPos - spawn position [Position or String]
	_goWP - Array of positions for each waypoint for the go trip [ARRAY]
	_exitWP - Array of positions for each waypoint for the exit trip [ARRAY]
	_tbVehInf - Array - 0: vehicle class name, 1: array of infantery unit class names, 2: code [ARRAY], 3: custom vehicle crew [ARRAY], 4: vehicle customization (see BIS_fnc_initVehicle and Eden 'Edit vehicle Appearence' object menu) [ARRAY]
	_side - optional default opfor. Side for the spawned units [SIDE]
	_exitCondition - optional default true. Code, must return true to allow exit trip [CODE]
	_azimut - optional default 0. Direction of vehicle at spawn [NUMBER]
	_convoySeparation - optional default 50. Distance in meters between vehicles composing the convoy [NUMBER]
	_convoySpeed - optional default 50. Convoy speed in km per hour [NUMBER]
	_convoyDespawn - optional false. Convoy despawn condition at last exit waypoint [STRING]
	_debug - optional false. Print debug messages to systemChat (in any case, messages will be printed in the rpt file).
	_tracePath - optional [false, false]. Create a marker path (global or local)  second array element) following calculated path between every waypoints [ARRAY]
	
Returns:
	Nothing

Examples:
    (begin example)
	[
		"mrkSp_1",
		["mrkgo_1_1", "mrkgo_1_2", "mrkgo_1_3", "mrkgo_1_4", "mrkgo_1_5", "mrkgo_1_6", "mrkUl_1_1"],
		["mrkExit_1_1", "mrkSp_1"],
		[ 
			[
				"B_G_Offroad_01_F",
				[],
				{},
				["B_Soldier_F", "B_Soldier_F"],
				[["Green",1],true]  
			], 
			[
				"I_E_Truck_02_transport_F",
				["CUP_O_INS_Officer", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F"],
				{params ["_group"]; systemChat format ["My group is %1", _group]},
				[],
				[]
			],
			[
				"I_E_Truck_02_transport_F",
				["B_Soldier_F", "B_Soldier_F", "B_Soldier_F","B_Soldier_F", "B_Soldier_F"],
				{params ["_group"]; systemChat format ["My group is %1", _group]},
				[],
				[]
			],
			[
				"I_E_Truck_02_transport_F",
				["B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F"],
				{params ["_group"]; systemChat format ["My group is %1", _group]},
				[],
				[]
			]
		],
		opfor,
		{sleep 10;true},
		180,
		30,
		50,
		"[group this, allPlayers, 500] call CBA_fnc_getNearest isEqualTo []",
		true,
		true
	] spawn int_fnc_Spawn_Convoy_Inf;
    (end)

Author:
	tanin69
---------------------------------------------------------------------------- */

params [
	["_spawnPosition", [0,0,0], [[], ""]],
	["_goWP", [[0,0,0]], [[]]],
	["_exitWP", [[0,0,0]], [[]]],
	["_tbVehInf", ["", [], {}, [], []], [[]]],
	["_side", opfor],
	["_exitCondition", {true}, [{}]],
	["_azimut", 0, [0]],
	["_convoySeparation", 50, [0]],
	["_convoySpeed", 50, [0]],
	["_convoyDespawn", "false", [""]],
	["_debug", false, [true]],
	["_tracePath", [false, false], [[true, true]]]
];

#include "..\..\include\debug_macros.hpp"

private _convoyGrp = "";
private _tbGrpInf = [];
private _tbConvoyVeh = [];
private _veh = []; 
private _wp = "";
private _grpInf = grpNull;
private _convoyElementVeh = objNull;
private _convoyElementGrp = grpNull;

/*Params validation*/
	private _haltScript = false;
	//Spawn position
	_spawnPos = _spawnPosition call CBA_fnc_getPos;
	if (_spawnPos isEqualTo [0,0,0]) then {
		ERR4("spawn point argument returned a wrong position:",_spawnPosition, "->", _spawnPos);
		_haltScript = true;
	};

	//waypoints positions for go trip 
	private _wpPos = [];
	{
		_wpPos = _x call CBA_fnc_getPos;
		if (_wpPos isEqualTo [0,0,0]) then {
			ERR3("wrong GO waypoint position:", _goWP#_forEachIndex, _wpPos);
			//[SCRIPT, format ["Wrong waypoint position for _goWP#%1. %2", _forEachIndex, _x], _wpPos, OUT, 3] call int_fnc_Log_Msg;
			_haltScript = true;
		};
	} forEach _goWP;

	//waypoints positions for exit trip 
	private _wpPos = [];
	{
		_wpPos = _x call CBA_fnc_getPos;
		if (_wpPos isEqualTo [0,0,0]) then {
			//[SCRIPT, format ["Wrong waypoint position for _exitWP#%1. %2", _forEachIndex, _x], _wpPos, OUT, 3] call int_fnc_Log_Msg;
			ERR3("wrong EXIT waypoint position:", _goWP#_forEachIndex, _wpPos);
			_haltScript = true;
		};
	} forEach _exitWP;

	//Convoy elements
	{
		if !(_x isEqualTypeArray ["", [], {}, [], []]) then {
			//[SCRIPT, format ["wrong argument format for _tbVehInf#%1.]", _forEachIndex], _x, OUT, 3] call int_fnc_Log_Msg;
			_haltScript = true;
		};
		private _vehClassName = _x#0;
		private _grpDef = _x#1;
		private _code = _x#2;
		if (_vehClassName isEqualTo "") then {
			//[SCRIPT, format ["Vehicle class name for _tbVehInf#%1 is an empty string.", _forEachIndex], _vehClassName, OUT, 3] call int_fnc_Log_Msg;
			ERR5("Vehicle class name is an empty string:", "Index", _forEachIndex, ":", str _vehClassName);
			_haltScript = true;
		};
		if (!(_vehClassName isKindOf "LandVehicle") || (_vehClassName isKindOf "StaticWeapon"))  then {
			//[SCRIPT, format ["Vehicle class for _tbVehInf#%1 doesn't seem to be a land vehicle. This could lead to impredictible result.", _forEachIndex], _vehClassName, OUT, 1] call int_fnc_Log_Msg;
			WARN5("Vehicle class doesn't seem to be a land vehicle. This could lead to impredictible result:", "Index", _forEachIndex,":", str _vehClassName);
		};
		if (count _grpDef > 0) then {
			{
				if !(_x isKindOf "CAMANBase") then {
					//[SCRIPT, format ["One or more soldier class names for _tbVehInf#%1 are not a CAMANBase class. This could lead to impredictible result.", _forEachIndex], _grpDef, OUT, 1] call int_fnc_Log_Msg;
					WARN5("One or more soldier class names are not a CAMANBase class. This could lead to impredictible result:", "Index", _forEachIndex,":", str _grpDef);
				};
			} forEach _grpDef;
		};
		
	} forEach _tbVehInf;
	//if a fatal error has been met, interrupt the script
	if (_haltScript) exitWith {
		//[SCRIPT, "script aborted due to fatal error(s).", "See .rpt file for more informations", OUT, 3] call int_fnc_Log_Msg;
		ERR1("Some fatal errors occured. Script execution aborted");
	};
/*Params validation*/

/* Trace path with calculatePath BIS command */
	if (_tracePath#0) then {
		private _traceWP = [_spawnPosition] + _goWP;
		for "_i" from 0 to (count _traceWP) -2 do {
			[_traceWP#_i,  _traceWP#(_i+1), _tbVehInf#0#0, "safe", "colorGreen", _tracePath#1] call int_fnc_tracePath;
		};
		_traceWP = [_goWP#(count _goWP -1)] + _exitWP;
		for "_i" from 0 to (count _traceWP) -2 do {
			[_traceWP#_i,  _traceWP#(_i+1), _tbVehInf#0#0, "safe", "colorRed", _tracePath#1] call int_fnc_tracePath;
		};
		
	};
/* Trace path with calculatePath BIS command */

/* Convoy creation */
	
	//Iterate in each convoy element
	{ 
		private _vehSpawn = _x#0;
		private _grpInfCompo = _x#1;
		private _grpInfCode = _x#2;
		private _customCrew = _x#3;
		private _customVeh = _x#4;
		//Spawn Inf group and set side (only if there is an infantry group for this vehicle)
		if (_grpInfCompo isNotEqualTo []) then {
			_grpInf = [[0,0,0], _side, _grpInfCompo] call GDC_fnc_lucySpawnGroupInf;
			{
				//Add envent handler on each unit in case of convoy attack during trip
				_x addEventHandler ["Hit", {
					params ["_unit"];
					group _unit setBehaviour "COMBAT";
					{
						{moveOut _x;[_x] allowGetIn false} forEach assignedCargo (vehicle _x);
					} forEach (units group _unit);
					_unit removeEventHandler ["Hit", _thisEventHandler];
				}];		
			} forEach units _grpInf;
			//Array for code execution on infantry group at convoy destination
			_tbGrpInf pushBack [_grpInf, _grpInfCode];
			//spyGrpInf = _tbGrpInf;
		};
		
		//Spawn vehicle with crew and set side 
		//...With custom crew
		if (_customCrew isNotEqualTo []) then {
			_convoyElement = [_spawnPos, _side, _vehSpawn, _customCrew, _azimut] call gdc_fnc_lucySpawnVehicle;
			_convoyElementVeh = _convoyElement#1;
			_convoyElementGrp = _convoyElement#0;
		//...With crew from vehicle class
		} else {
			_convoyElement = [_spawnPos, _azimut, _vehSpawn, _side] call BIS_fnc_spawnVehicle;
			_convoyElementVeh = _convoyElement#0;
			_convoyElementGrp = _convoyElement#2;
		};
		//VCom conflicts with this script -> disable Vcom for vehicles 
		_convoyElementGrp setVariable ["Vcm_Disable", true];
		//...And, if applicable, with customized appearence of the vehicle
		if (_customVeh isNotEqualTo []) then {
			[_convoyElementVeh, _customVeh#0, _customVeh#1] call BIS_fnc_initVehicle;
		};
		INF2("Convoy element created:", _convoyElementVeh);
		_tbConvoyVeh pushBack _convoyElementVeh;
		//spyConvoyVeh = _tbConvoyVeh;
		{
			//Add envent handler on each vehicle unit in case of convoy attack during trip
			_x addEventHandler ["Hit", {
				params ["_unit"];
				group _unit setBehaviour "COMBAT";
				{
					{moveOut _x;[_x] allowGetIn false} forEach assignedCargo (vehicle _x);
				} forEach (units group _unit);
				for "_i" from count waypoints (group _unit) - 1 to 0 step -1 do
				{
					deleteWaypoint [(group _unit), _i];
				};
				_unit removeEventHandler ["Hit", _thisEventHandler];
			}];
		} forEach units (_convoyElementVeh);
		//If vehicle is the first vehicle, set it as the convoy leader and give it convoy orders
		if (_forEachIndex isEqualTo 0) then { 
			_convoyGrp = _convoyElementGrp;
			_convoyGrp setBehaviour "CARELESS";
			_convoyGrp setFormation "COLUMN";
			_convoyElementVeh limitSpeed _convoySpeed;
			//spyConvoyGrp = _convoyGrp;
			//go trip with a list of waypoints
			{
				private _wpPos = _x call CBA_fnc_getPos;
				_wp = _convoyGrp addWaypoint [_wpPos, -1];
				_wp setWaypointType "MOVE";
			} forEach _goWP;
		};
		//Following vehicles
		if (_forEachIndex > 0) then { 
			(units (_convoyElementGrp)) join _convoyGrp;
			_convoyElementVeh limitSpeed _convoySpeed*1.15;
		};
		_convoyElementVeh setConvoySeparation _convoySeparation;
		
		//Load inf group in its vehicle (only if there is an infantry group for this vehicle)
		if (_grpInfCompo isNotEqualTo []) then {
			sleep 5;
			{_x moveInCargo (_convoyElementVeh)} forEach units _grpInf;
		};
		//Wait for vehicle to leave safe zone before proceeding with next convoy element
		waituntil {sleep 1;count (allUnits inAreaArray [_spawnPos, 20, 20]) isEqualTo 0};
	} forEach _tbVehInf;
/* Convoy creation */

//Force convoy vehicles to follow convoy leader in case they stop during the trip
//Thanks to Tova (https://forums.bohemia.net/forums/topic/226608-simple-convoy-script-release/)
while {currentWaypoint _convoyGrp isNotEqualTo (count waypoints _convoyGrp)} do {
	{
		if (speed vehicle _x < 5) then {
				(vehicle _x) doFollow (leader _convoyGrp);
		};	
	} forEach (units _convoyGrp) - (crew (vehicle (leader _convoyGrp))) - allPlayers;
	sleep 10;
};
_arrivalGrpPos = [_convoyGrp, 3, "-"] call gdc_fnc_posToGrid;
INF2("Convoy arrived at destination: ", _arrivalGrpPos);

{
	INF2("Waiting for vehicle to stop:", _x);
	waituntil {sleep 2;speed _x <=0};
	INF2("Vehicle stopped:", _x);
	if (count assignedCargo _x > 0) then {
		INF3("Vehicle cargo:", count assignedCargo _x, "units");
		{moveOut _x;[_x] allowGetIn false;} forEach assignedCargo _x;
	};
} forEach _tbConvoyVeh;
INF1("All infantery groups disembarked. Go for it baby !");

//Launch code defined for each infantry group
{
	[_x#0] spawn (_x#1);
} forEach _tbGrpInf;

//Convoy exit
INF2("Exit condition for convoy:", _exitCondition);

waitUntil _exitCondition;
INF1("Exit condition for convoy fulfilled");

//Exit trip with waypoints list
private _wpPos = [0,0,0];
{
	_wpPos = _x call CBA_fnc_getPos;
	_wp = _convoyGrp addWaypoint [_wpPos, -1];
	_wp setWaypointType "MOVE";	
} forEach _exitWP;
INF7("Convoy proceeding to next waypoint: n°", currentWayPoint _convoyGrp, "@", waypointPosition [_convoyGrp, currentWaypoint _convoyGrp], "with _convoyDespawn set as", _convoyDespawn);

_wp setWaypointStatements [_convoyDespawn, "{ deleteVehicle (vehicle _x); deleteVehicle _x; } forEach units group this;"];

while {currentWaypoint _convoyGrp isNotEqualTo (count waypoints _convoyGrp)} do {
	{
		if (speed vehicle _x < 5) then {
			(vehicle _x) doFollow (leader _convoyGrp);
		};	
	} forEach (units _convoyGrp) - (crew (vehicle (leader _convoyGrp))) - allPlayers;
	sleep 10;
};