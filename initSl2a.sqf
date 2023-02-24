/* 
	Initialise l'environnement SL2A

	Le premier argument active le SL2A pour des IA, le second pour des joueurs.

	Ex. : 
	[opfor, blufor] execVM "initSl2a.sqf" active le SL2A pour des IA en camp opfor et pour des joueurs en camp blufor.
	[false, blufor] execVM "initSl2a.sqf" désactive le SL2A pour les IA et active le sl2a pour des joueurs en camp blufor.

	Pour affecter des unités ou groupes sur lesquels activer le SL2A :

*/

params [["_sideIA", opfor], ["_sidePlayer", blufor], ["_cls", "StaticMortar"],["_debug", false]];

if (_debug) then {sl2a_DBG = true} else {sl2a_DBG = false};

sl2aIA_side = _sideIA;
sl2aIA_detectGrp = objNull;
sl2aIA_counterUnits = [];
sl2aIA_fireMissions = [];

sl2aPl_side = _sidePlayer;
sl2aPl_detectGrp = objNull;
sl2aPl_isActive = true;

//Compile les fonctions utilitaires
invSquare = compile preprocessfilelinenumbers ("fn_invSquare.sqf");
artyCounterFire = compile preprocessfilelinenumbers ("fn_artyFire.sqf");
detectShot = compile preprocessfilelinenumbers ("fn_detectShot.sqf");

private _isUnit = objNull;

//Initialise les groupes et variables IA
if (sl2aIA_side isNotEqualTo false) then {
	//Choppe le groupe de détection. Le premier groupe répondant au critère sera désigné comme étant le groupe de détection.
	{
		_isUnit = _x getVariable ["sl2a_detect_ia", false];
		if (_isUnit) exitWith {sl2aIA_detectGrp = _x};
	} forEach allGroups select {_x isEqualTo sl2aIA_side};
	//Choppe les unités de contre-batterie.
	sl2aIA_counterUnits = vehicles select {side group _x isEqualTo sl2aIA_side && _x getVariable "sl2a_counter_ia"};
	if (sl2aIA_detectGrp isEqualTo objNull || count sl2aIA_counterUnits isEqualTo 0) then {
		sl2aIA_side = false;
		if (sl2a_DBG) then {
			[format ["SL2A init IA: aucun groupe IA trouvé: SL2A IA inactif."]] remoteExec ["systemChat"];
		};
	} else {
		if (sl2a_DBG) then {
			[format ["SL2A init IA: Groupe IA de détection => %1 | Groupe IA de contre-batterie => %2", sl2aIA_detectGrp, sl2aIA_counterUnits]] remoteExec ["systemChat"];
		};
		//Lance la fonction de tir de contre-batterie
		[] spawn artyCounterFire;
	};
};

//Initialise les groupes et variables Joueurs
if (sl2aPl_side isNotEqualTo false) then {
	/*Pour les joueurs, le système de détection est un véhicule. Le premier véhicule répondant au critère sera
	  désigné comme étant le véhicule de détection.
	*/
	{
		_isUnit = _x getVariable ["sl2a_detect_player", false];
		if (_isUnit) exitWith {sl2aPl_detectGrp = _x};
	} forEach (8 allObjects 1);
	if (sl2aPl_detectGrp isEqualTo objNull) then {
		sl2aPl_side = false;
		if (sl2a_DBG) then {
			[format ["SL2A init joueurs: aucun véhicle équipé du système trouvé: SL2A Joueurs inactif."]] remoteExec ["systemChat"];
		};
	} else {
		if (sl2a_DBG) then {
			[format ["SL2A init joueurs: véhicle équipé du SL2A: %1.", sl2aPl_detectGrp]] remoteExec ["systemChat"];
			publicVariable "sl2aPl_detectGrp";
		};
	};
};

//Ajoute les EH aux pièces d'artillerie qui seront surveillées
{
	[
		_x,
		"fired",
		{
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			
			//Filtre les tirs qui ne viennent pas d'un canon (ex. mortier monté qui dispose d'arme d'autodéfense)
			private _parents = [configFile >> "CfgWeapons" >> _weapon, true] call BIS_fnc_returnParents;
			if !("CannonCore" in _parents) exitWith {};

			//Detection by AI
			if (sl2aIA_side isNotEqualTo false) then {
				[_unit, sl2aIA_side, sl2aIA_detectGrp] call detectShot;
			};
			//Detection by players
			if (sl2aPl_side isNotEqualTo false) then {
				[_unit, sl2aPl_side, sl2aPl_detectGrp, true] call detectShot;
			};
		}
	] call CBA_fnc_addClassEventHandler;
} forEach [_cls];