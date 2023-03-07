/*

Author :
tanin69

Version :
1.0 : version initiale
1.1 : ajout des paramètres optionnels de CBA_fnc_taskDefend

Date :
15/12/2019

Description :
Spawn des garnisons dans une zone donnée, sur des marqueurs

Parameter(s) : 
0 : STRING - le nom de la zone
1 : ARRAY  - composition du groupe à spawner. Ex. : ["rhsgref_ins_squadleader", "rhsgref_ins_rifleman_aks74","rhsgref_ins_militiaman_mosin"]
2 : SIDE (optional, default opfor) - side du groupe (opfor, blufor, independent)
3 : NUMBER (optional, default 40) - rayon dans lequel les soldats se mettent en garnison (CBA_fnc_taskDefend)
4 : NUMBER (optional, default 2) - seuil minimal de positions de fortification pour que les IA se fortifient (CBA_fnc_taskDefend)
5 : NUMBER (optional, default 0) - probabilité pour que l'unité patrouille au lieu de se fortifier (CBA_fnc_taskDefend)
6 : NUMBER (optional, default 0.7) - probabilité pour que les unités restent fortifiées si elles sont attaquées (CBA_fnc_taskDefend)

Returns :
Nothing

*/

params [
	"_zone",
	"_group",
	["_side",opfor],
	["_radius", 40],
	["_threshold", 2],
	["_patrol", 0],
	["_hold", 0.7]
];

private _mrkGn = "mrkGn" + _zone;
private _tbMrkGn = allMapMarkers select {[_mrkGn, _x, true] call BIS_fnc_inString};

{
	private _pos = getMarkerPos _x;
	_grp = [_pos, _side, selectRandom _group] call GDC_fnc_lucySpawnGroupInf;
	[_grp, nil, _radius, _threshold, _patrol, _hold] call CBA_fnc_taskDefend;
	{_x unlinkItem "CUP_NVG_HMNVS_Hide";} forEach units _grp;
} forEach _tbMrkGn;