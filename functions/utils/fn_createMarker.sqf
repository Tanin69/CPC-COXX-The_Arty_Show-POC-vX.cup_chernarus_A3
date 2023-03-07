/* create a unique marker with one command */

params [
	"_markerPos",
	["_icon", "hd_dot"],
	["_markerText", ""],
	["_markerNamePrefix", "marker_"],
	["_color", "colorRed"],
	["_global", false]
];

private _mrk = objNull;
private _tagTime = systemTime joinString "";
private _mrkSuffix = _tagTime + str floor(random 100);

if (_global) then {
	_mrk = createMarker [_markerNamePrefix + _mrkSuffix, _markerPos, 1];
} else {
	_mrk = createMarkerLocal [_markerNamePrefix + _mrkSuffix, _markerPos, 1];
};

_mrk setMarkerType _icon;
_mrk setMarkerColor _color;
_mrk setMarkerText _markerText;

_mrk