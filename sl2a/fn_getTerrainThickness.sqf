params ["_begObj", "_endObj", ["_minElev",10], ["_treshold",10]];

private _startPos = getPosASL _begObj;
private _endPos = getPosASL _endObj;
_startPos = _startPos vectorAdd [0,0,_minElev];
_endPos = _endPos vectorAdd [0,0,_minElev];
private _distance = _begObj distance2D _endObj;
private _stepSize = 1;
private _lineVec = [];
private _normLineVec = [];
private _moveVec = [];
private _newPos = _startPos;
private _thickness = 0;
private _intersect = [];
private _prevIntersect = [];

for "_i" from 0 to _distance step _stepSize do {
	_prevIntersect = _intersect;
	_lineVec = _endPos vectorDiff _startPos;
	_normLineVec = vectorNormalized _lineVec;
	_moveVec = _normLineVec vectorMultiply _i;
	_newPos = _startPos vectorAdd _moveVec;
	_intersect = lineIntersectsSurfaces [_newPos, _endPos, _begObj, _endObj, true, 1, "VIEW", "NONE", false];
	if (_intersect isEqualTo []) exitWith {};
	if (_prevIntersect isNotEqualTo _intersect && {(_intersect#0#5) select [0,1] isEqualTo "#"}) then {
		if ((getTerrainHeightASL [(_intersect#0#0)#0, (_intersect#0#0)#1]) - (_intersect#0#0)#2 > _treshold) then {
			_thickness = _thickness + _stepSize;
		};
		//systemChat format ["Hauteur du terrain: %1, hauteur du point: %2, différence: %3",(getTerrainHeightASL [(_intersect#0#0)#0, (_intersect#0#0)#0]), (_intersect#0#0)#2, (getTerrainHeightASL [(_intersect#0#0)#0, (_intersect#0#0)#0]) - (_intersect#0#0)#2];
	};
	//sleep 0.01;
};
//systemChat format ["Epaisseur mesurée: %1", _thickness];
_thickness
