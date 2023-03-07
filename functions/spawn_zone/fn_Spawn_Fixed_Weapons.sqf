/*

Author :
tanin69

Version :
1.0

Date :
14/12/2019

Description :
Spawn les armes fixes d'une zone, selon une probabilité et permet à des IA de monter dans l'arme fixe sous certaines conditions

Parameter(s) : 
0 : STRING - le nom de la zone contenant les armes fixes
1 : SIDE   (optional, default opfor) - side de l'arme fixe (opfor, blufor, independent)
2 : STRING (optional, default "rhsgref_ins_DSHKM") - classname de l'arme fixe
3 : STRING (optional, default "rhsgref_ins_rifleman") - classname du gunner
4 : NUMBER (optional, default 0.5) - Probabilité que l'arme fixe soit spawnée
5 : NUMBER (optional, default 0.5) - Probabilité que l'arme fixe soit spawnée avec un gunner
6 : NUMBER (optional, default 0.8) - Probabilité pour qu'un ordre de monter dans l'arme fixe soit donné à une IA hostile (si les conditions sont remplies)

ex. : ["Nord3"] spawn fn_spawnFixedWeapons;
ex. : ["Nord3",opfor,"rhsgref_ins_DSHKM","rhsgref_ins_rifleman",1,0.1,1] spawn fn_spawnFixedWeapons;

Returns :
Nothing

*/

//Rayon de détection (mètres) du pseudo trigger, avec le marqueur reçu en paramètre comme centre
#define RDETECT 300
//Rayon (mètres) dans lequel des IA recevront l'ordre de monter dans l'arme fixe, avec le marqueur reçu en paramètre comme centre
#define RMOUNT 100


params [
	"_zn",
	["_side",opfor],
	["_clsFixedW","rhsgref_ins_DSHKM"],
	["_cslGunner","rhsgref_ins_rifleman"],
	["_probaFixedW",0.5],
	["_probaGunner",0.5],
	["_probaOrderGunner",0.8]
];

//Le groupe de l'arme et l'éventuel gunner spawné
private _grp    = "";
//L'arme spawnée
private _fw     = "";
//Side du groupe au format EAST, WEST, etc.
private _sideComp = "";
//Construit le nom des marqueurs à partir du nom de la zone
private _mrkFW = "mrkFW" + _zn;
//Tableau des noms de marqueurs d'arme fixe de la zone
private _tbMrk = allMapMarkers select {[_mrkFW, _x, true] call BIS_fnc_inString};
//Tableau des joueurs
private _all_players = [];

//Tableau des joueurs
if (isMultiplayer) then {
	_all_players = playableUnits;
} else {
	_all_players = switchableUnits;
};

//Convertit la side au format opfor, blufor, etc. utilisé par LUCY en side au format EAST, WEST, etc. utilisé par certaines fonctions BI
switch (_side) do {
	case opfor:       {_sideComp = EAST};
	case independent: {_sideComp = RESISTANCE};
	case blufor:      {_sideComp = WEST};
};

//Fonction pour qu'un gunner monte dans une arme fixe
gunnerMount = {
	params ["_mrkD","_fwD", "_sideComp","_probaOrderGunner"];
	private _u="";
	while {true} do {
		/*
		//DBG start
		_str = "DBG_spawnFixedWeapons: : gunnerMount alive !";
		systemChat _str;
		//DBG end
		*/
		if (isNull assignedGunner _fwD) then {
			if (random 1 < _probaOrderGunner) then {
				_u = [allUnits select {side _x == _sideComp} inAreaArray [getMarkerPos _mrkD,RMOUNT,RMOUNT,0,false]] call BIS_fnc_nearestPosition;
				if (typeName _u != "ARRAY") then {
					_u assignAsGunner _fwD;
					[_u] orderGetIn true;
					/* DBG start
					_str = "DBG_spawnFixedWeapons: : " + str(_u) + " a reçu l'ordre de monter dans l'arme fixe " + str(_fwD);
					systemChat _str;
					DBG end */
				};
			};
		};
		sleep 5;
	};	
};

{

	//Le nom du marqueur de l'arme fixe
	private _mrk = _x;
	//Azimut vers lequel pointe l'arme. Récupéré dans le nom du marqueur de l'arme fixe
	private _azim = parseNumber(_mrk select [(count _mrk)-3,3]);
	
	// Spawn une arme fixe selon une proba sur la position du marqueur reçu en paramètre
	if (random 1 < _probaFixedW) then {
		//Si l'arme fixe est spawnée, il y a une proba que le tireur soit spawné avec l'arme
		if (random 1 < _probaGunner) then {
			_grp = [getMarkerPos _mrk,_side,_clsFixedW,[_cslGunner],_azim,["NONE", 0, 0],-1] call GDC_fnc_lucySpawnVehicle;
		}
		//Sinon, on spawn l'arme sans tireur
		else {
			_grp = [getMarkerPos _mrk,_side,_clsFixedW,[],_azim,["NONE", 0, 0],-1] call GDC_fnc_lucySpawnVehicle;
		};
		_fw = _grp#1;
		//Pseudo trigger : scanne si une unité hostile a repéré un joueur (ou une unité jouable) dans le rayon RDETECT
		[_mrk,_fw,_sideComp,_probaOrderGunner,_all_players] spawn {
			params["_mrk","_fw","_sideComp","_probaOrderGunner","_all_players"];
			private _hdl = scriptNull;
			/*
			//DBG start
			private _compteBoucle = 1;
			_str = "DBG_spawnFixedWeapons: Boucle de détection démarrée sur le marqueur " + str(_mrk);
			systemChat _str;
			//DBG end
			*/
			while {true} do {
				private _menace       = false;
				private _tbPlayers    = _all_players select {_x != HC_Slot} inAreaArray [getMarkerPos _mrk,RDETECT,RDETECT,0,false]; //Faut remonter le filtre sur le HC dans la définition de la variable _all_players
				private _tbHostiles   = allUnits select {side _x == _sideComp} inAreaArray [getMarkerPos _mrk,RDETECT,RDETECT,0,false];
				
				{
					private _opfor = _x;
					{
						//si un joueur a été repéré, on quitte la boucle sur les joueurs
						if (_opfor knowsabout _x > 1.4) exitWith {
							_menace = true;
							/*
							//DBG start
							_str = "DBG_spawnFixedWeapons: Menace dans _tbPlayers :" + str(_menace);
							systemChat _str;
							//DBG end
							*/
						};		
					} forEach _tbPlayers;
					//DBG
					//_str="DBG_spawnFixedWeapons: Menace dans _tbOpfor :" + str(_menace);systemChat _str;
					//si un joueur a été repéré, quitte la boucle sur les IA hostiles
					if (_menace) exitWith{};
				} count _tbHostiles;
				/*
				//DBG start
				_str = "DBG_spawnFixedWeapons: Boucle n° " + str(_compteBoucle);
				systemChat _str;
				_compteBoucle = _compteBoucle +1;
				//DBG end
				*/

				//Si un joueur a été repéré, on lance la fonction "d'automount" du gunner à condition qu'elle n'ait pas été déjà lancée
				if (_menace) then {
					if (isNull _hdl) then {
						_hdl=[_mrk,_fw,_sideComp,_probaOrderGunner] spawn gunnerMount;
						/*
						//DBG start
						_str = "DBG_spawnFixedWeapons: gunnerMount appelé...";
						systemChat _str;
						//DBG end
						*/
					};				
				//Si pas ou plus de menace, on termine la fonction d'automount et on désassigne un éventuel gunner
				} else {
					if !(isNull _hdl) then {
						terminate _hdl;
						sleep 5;
						private _fwGunner = gunner _fw;
						if !(isNull _fwGunner) then {
							unassignVehicle _fwGunner;
							/*
							//DBG start
							_str = str(_fwGunner) + " a reçu l'ordre de lâcher l'arme " + str(_fw);
							systemChat _str;
							//DBG end
							*/	
						};
						/*
						//DBG start
						_str = "DBG_spawnFixedWeapons: gunnerMount terminé.";
						systemChat _str;
						//DBG end
						*/
					};
				};
				
				sleep 5;
			};
		};
	};

} forEach _tbMrk;