/**
 * @brief Measure terrain thickness between 2 given objects.
 *
 * @param {Object} _begObj, the first object.
 * @param {Object} _endObj, the second object.
 * @param {Number} _minElev, elevation added to the position objects.
 * @param {Number} _threshold, Amount of terrain above in order to be counted.
 *
 * @return {Number} terrain thickness
 */
params ["_begObj", "_endObj", ["_minElev",10], ["_threshold",10]];

private _startPos = getPosASL _begObj vectorAdd [0, 0, _minElev + _threshold];
private _endPos = getPosASL _endObj vectorAdd [0, 0, _minElev + _threshold];

if (not terrainIntersectASL [_startPos, _endPos]) exitWith { 0 };

private _distanceStartEnd = _begObj distance _endObj;
private _stepSize = 1;
private _stepVector = vectorNormalized (_endPos vectorDiff _startPos)
	vectorMultiply _stepSize;
private _thickness = 0;


private _currentPos = _startPos;
private _intersect = terrainIntersectAtASL[_currentPos, _endPos];
while {
	_startPos distance _currentPos < _distanceStartEnd
	and terrainIntersectASL [_intersect, _endPos]
} do {
	_intersect = terrainIntersectAtASL[_currentPos, _endPos];

	/*
	When _currentPos is underground terrainIntersectAtASL should return the same
	position. If the position returned isn't the same we consider that the
	position is ouside so the next intersection should be from the next hill to
	be mesured.

	A better condition would be _intersect distance _currentPos < _epsilon
	because we're comparing floats.
	*/
	if (_intersect isNotEqualTo _currentPos) then {
		_currentPos = _intersect;
	};

	_thickness = _thickness + _stepSize;
	_currentPos = _currentPos vectorAdd _stepVector;
};

_thickness
