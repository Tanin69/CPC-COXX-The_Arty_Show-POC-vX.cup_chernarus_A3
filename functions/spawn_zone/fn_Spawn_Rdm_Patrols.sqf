/*

Author :
tanin69

Version :
1.0

Date :
05/12/2019

Description :
Spawn des patrouilles à WP aléatoires dans une zone donnée et sur des marqueurs randomisés

Parameter(s) : 
0 : STRING - le nom de la zone
1 : ARRAY  - nombre de patrouilles. Ex. [2,3,4,5] pour un nombre de patrouilles comprises entre 2 et 5
2 : ARRAY  - composition du groupe à spawner. Ex. : ["rhsgref_ins_squadleader", "rhsgref_ins_rifleman_aks74","rhsgref_ins_militiaman_mosin"]
3 : SIDE (optional, default opfor) - side du groupe (opfor, blufor, independent)

Returns :
Nothing

*/

params ["_zone", "_rdmNum","_group","_side"];

private _mrkZn = "mrkZn" + _zone;
private _mrkSn = "mrkPl" + _zone;
private _tbMrkSn = allMapMarkers select {[_mrkSn, _x, true] call BIS_fnc_inString};
private _nbPat = selectRandom _rdmNum; 
private _spawn = [];
private _grp =[];

for "_i" from 1 to _nbPat do {
	_spawn = selectRandom  _tbMrkSn;
	_grp = [(getMarkerPos _spawn), _side, selectRandom _group] call GDC_fnc_lucySpawnGroupInf;
	_grp setVariable ["PLUTO_ORDER","QRF"];
	_grp setVariable ["Vcm_Disable",false];
	[_grp, _mrkZn] call GDC_fnc_lucyGroupRandomPatrol;
	{_x unlinkItem "CUP_NVG_HMNVS_Hide";} forEach units _grp;
};