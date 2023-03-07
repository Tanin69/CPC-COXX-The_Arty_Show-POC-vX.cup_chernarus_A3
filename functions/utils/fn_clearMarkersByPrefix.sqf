params ["_prefix", ""];

{
	private "_a";
	_a = toArray _x;
	_a resize 12;
	if (toString _a isEqualTo _prefix) then
	{
		deleteMarker _x;
	}
} forEach allMapMarkers;