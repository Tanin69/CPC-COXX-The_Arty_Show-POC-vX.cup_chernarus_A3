params ["_text"];

private _markerPos = [];

{
	private "_a";
	_a = toArray (markerText _x);
	if (toString _a isEqualTo _text) exitWith
	{
		_markerPos = getMarkerPos _x;
	}
} forEach allMapMarkers;

_markerPos

