/*
	Function: fn_chooseSpawnTask

	Description:
		Choose players spawn position by task selection

	Parameters:
		_rankID - optional default 2 (SERGEANT) - minimal rankID required in order to be able to move the marker (see https://community.bistudio.com/wiki/rankId) [NUMBER]
		_allowAfterMissionStart - optional false - allow players TP after mission start (use with caution !)
		_spawnMrkName - optional default "marker_spawn" - existing spawn marker name
		_selectPosMode - optional default "TASKNAME" - mode to find spawn pos form task. 
						"TASKNAME" : find existing spawn markers position from their name, following the rule spawn_TASKNAME where TASKNAME is the
						name of the task for the spawn marker
						"TASKAREA" : find a random pos around the task position, from a min and max distance from the
						task pos [STRING]
		_areaDef - optional default [500, 700, 1] - if selectPosMode is "TASKAREA", min and max distance from task 
				   destination (position) for spawn position, third element is water mode as in BIS_fnc_findSafePos
				   (0 - cannot be in water, 1 - can either be in water or not, 2 - must be in water)
		
	Returns:
		Nothing

	Examples:
		(begin example)
		[3] call gdc_fnc_chooseSpawnTask
		//Defining spawn position is available for players with at least Lieutenant rank. Other options set to default
		[2, "AREA", [1000, 1200]] call gdc_fnc_chooseSpawnTask
		//Minimal rank required is Sergeant (same as default), AREA mode to get the spawn position, at a min distance
		//of 1000 meters from task position and max distance of 1200 meters, on water or not
		(end)

	Author:
		tanin69

*/

params [
	["_rankID", 2],
	["_allowAfterMissionStart", false],
	["_spawnMrkName", "marker_spawn"],
	["_selectPosMode", "TASKNAME"],
	["_areaDef", [500, 700, 1]]
];

private _initSpawnPos = getMarkerPos _spawnMrkName;
private _spawnPos = [];
private _units = playableUnits + switchableUnits;

if (_rankID player >= 2) then {
	[
		//Object (BIS EH param)
		player,
		//BIS EH
		"TaskSetAsCurrent",
		//EH Code
		{
			//To get variable names more explicit than the cba arguments
			private _curTask = _this#1;
			private _spawnMrkName = _thisArgs#0;
			private _selectPosMode = _thisArgs#1;
			private _areaDef = _thisArgs#2;
			private _spawnPos = _thisArgs#3;
			private _units = _thisArgs#4;
			private _initSpawnPos = _thisArgs#5;
			private _allowAfterMissionStart = _thisArgs#6;
			if (_selectPosMode isEqualTo "TASKNAME") then {
				//get marker pos from task name
				private _mrkSpawnName = "marker_spawn_" + taskName _curTask;
				_spawnPos = getMarkerPos _mrkSpawnName;
			};
			if (_selectPosMode isEqualTo "TASKAREA") then {
				//get safe spawn pos from random area around task destination (position)
				_spawnPos = [
					[taskName _curTask] call BIS_fnc_taskDestination,
					_areaDef#0,
					_areaDef#1,
					10,
					_areaDef#2,
					0,
					0
				] call BIS_fnc_findSafePos;
			};
			//No current task selected after a task selection (restore default spawn pos)
			if (_curTask isEqualTo taskNull) then {
				_spawnPos = _initSpawnPos;
			};

			[_units, _spawnPos, _spawnMrkName, _thisType, _thisID, _allowAfterMissionStart] spawn {
				params ["_units", "_spawnPos", "_spawnMrkName", "_thisType", "_thisID", "_allowAfterMissionStart"];
				//move spawn marker to spawn pos
				_spawnMrkName setMarkerPos _spawnPos;
				//Move players to spawn position
				if (isServer) then {
					{_x setPos _spawnPos;} forEach _units;
				};
				//Prevent players to change position after mission start
				if !(_allowAfterMissionStart) then {
					waituntil {time > 0};
					player removeEventHandler [_thisType, _thisID];
				}
			};
		},
		//Additional params passed to EH code
		[ _spawnMrkName, _selectPosMode, _areaDef, _spawnPos, _units, _initSpawnPos, _allowAfterMissionStart]
	] call CBA_fnc_addBISEventHandler;
};