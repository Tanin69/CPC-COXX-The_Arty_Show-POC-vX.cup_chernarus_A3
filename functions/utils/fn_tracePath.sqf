params [
	"_posStart",
	"_posEnd",
	["_vehClass", "car"],
	["_behaviour", "safe"],
	["_pathColor", "colorRed"],
	["_global", false]
];

_posStart = _posStart call CBA_fnc_getPos;
_posEnd = _posEnd call CBA_fnc_getPos;

private _rdmSeed = floor(random 1000);

private _agent = calculatePath [_vehClass, _behaviour, _posStart, _posEnd];
_agent addEventHandler ["PathCalculated", {
	_this#0 setVariable ["path", _this#1];
}];

waitUntil {_agent getVariable ["path", []] isNotEqualTo []};
private _tbPos = _agent getVariable "path";
private _marker = objNull;
if (_global) then {
	{
		_marker = createMarker [["mrkTracePath", _x#0, _rdmSeed] joinString "_", _x];
		_marker setMarkerShadow false;
		_marker setMarkerType "mil_dot";
		_marker setMarkerColor _pathColor;
	} forEach _tbPos;
} else {
	{
		_marker = createMarkerLocal [["mrkTracePath", _x#0, _rdmSeed] joinString "_", _x];
		_marker setMarkerShadowLocal false;
		_marker setMarkerTypeLocal "mil_dot";
		_marker setMarkerColorLocal _pathColor;
	} forEach _tbPos;
};

_tbPos