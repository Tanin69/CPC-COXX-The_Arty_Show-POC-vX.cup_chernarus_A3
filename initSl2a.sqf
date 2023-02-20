/* 
	Initialise l'environnement SL2A

	Le premier argument active le SL2A pour des IA, le second pour des joueurs.

	Ex. : 
	[opfor, blufor] execVM "initSl2a.sqf" active le SL2A pour des IA en camp opfor et pour des joueurs en camp blufor.
	[false, blufor] execVM "initSl2a.sqf" désactive le SL2A pour les IA et active le sl2a pour des joueurs en camp blufor.

	Pour affecter des unités ou groupes sur lesquels activer le SL2A :
	- Pour le groupe de détection (celui qui utilise le SL2A), insérer dans l'init du _groupe_ : this setVariable ["sl2a_detect", true];
	- Pour les unités de contre-batterie (IA uniquement), insérer dans l'init de _chaque pièce_ de contre-batterie : this setVariable ["sl2a_counter", true];

*/

params [["_sideIA", opfor], ["_sidePlayer", blufor]];

sl2aIA_side = _sideIA;
sl2aIA_detectGrp = objNull;
sl2aIA_counterUnits = [];
sl2aIA_fireMissions = [];

sl2aPl_side = _sidePlayer;
sl2aPl_detectGrp = objNull;
sl2aPl_counterUnits = [];
sl2aPl_fireMissions = [];
sl2aPl_isActive = true;

//Compile les fonctions utilitaires
invSquare = compile preprocessfilelinenumbers ("fn_invSquare.sqf");
artyCounterFire = compile preprocessfilelinenumbers ("fn_artyFire.sqf");

//Initialise les groupes et variables IA
if (sl2aIA_side isNotEqualTo false) then {
	private _isUnit = objNull;
	//Choppe le groupe de détection. Le premier groupe répondant au critère sera désigné comme étant le groupe de détection.
	{
		_isUnit = _x getVariable ["sl2a_detect", false];
		if (_isUnit) exitWith {sl2aIA_detectGrp = _x};
	} forEach allGroups select {_x isEqualTo sl2aIA_side};
	//Choppe les unités de contre-batterie.
	sl2aIA_counterUnits = vehicles select {side group _x isEqualTo sl2aIA_side && _x getVariable "sl2a_counter"};
	/* DBG */
		systemChat format ["SL2A init: Groupe IA de détection => %1 | Groupe IA de contre-batterie => %2", sl2aIA_detectGrp, sl2aIA_counterUnits];
	/* DBG */
	if (sl2aIA_detectGrp isEqualTo objNull || count sl2aIA_counterUnits isEqualTo 0) then {sl2aIA_isActive = false};
};
/* DBG */
	systemChat format ["SL2A init: SL2A est actif pour les IA => %1", sl2aIA_side];
/* DBG */

//Initialise les groupes et variables Joueurs
if (sl2aPl_side isNotEqualTo false) then {
};
/* DBG */
	systemChat format ["SL2A init: SL2A est actif pour les joueurs => %1", sl2aPl_side];
/* DBG */

//Lance la fonction de tir de contre-batterie
[] spawn artyCounterFire;


//Ajoute les EH aux pièces d'artillerie qui seront surveillées
[
	"StaticMortar",
	"fired",
	{
		params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
		
		/* DBG */
			//systemChat format ["_unit: %1",_unit];
		/* DBG */
		
		//Filtre les tirs qui ne viennent pas d'un canon (ex. mortier monté qui dispose d'arme d'autodéfense)
		private _parents = [configFile >> "CfgWeapons" >> _weapon, true] call BIS_fnc_returnParents;
    	if !("CannonCore" in _parents) exitWith {};

		//Detection by AI
		if (sl2aIA_side isNotEqualTo false) then {
			//Filtre les tirs des pièces amies
			if (sl2aIA_side isEqualTo side _unit) exitWith {
				//systemChat "SL2A IA: tir de mortier ami détecté (filtré)"
			};
			private _unitDetect = leader sl2aIA_detectGrp; 
			/* DBG */
				private _distance = _unitDetect distance2D _unit;
				systemChat format ["SL2A IA: distance entre le tir et le groupe de détection ( %1) => %2.", sl2aIA_detectGrp, str _distance];
			/* DBG */
			
			//En fonction de la distance au tir, le SL2A réussit (ou pas) à enregistrer un tir
			private _probaEnreg = [_distance,4000000] call invSquare; //Attention, le second argument est une sorte de chiffre magique pour déterminer la proba d'enregistrement du tir par le SL2A
			/* DBG */
				systemChat format["SL2A IA: proba enreg => %1", _probaEnreg];
			/* DBG */
			if (random 1 < _probaEnreg) then {
				//Chaque tir enregistré augmente la précision de détection
				private _targetKnowledge = sl2aIA_detectGrp getVariable [str _unit,[0,position _unit]];
				private _knowsAbout = _targetKnowledge#0;
				private _unitDisplace = position _unit distance2D _targetKnowledge#1; 
				if (_knowsAbout <= 4) then {
					_knowsAbout = _knowsAbout + (linearConversion [0,0.75,_probaEnreg,0.01,0.4, true]);
				};
				//Si l'unité s'est déplacée depuis la précédente détection, la précision chute
				if (_unitDisplace > 0) then {					
					systemChat format ["SL2A IA: l'unité s'est déplacée de %1", _unitDisplace];
					_knowsAbout = _knowsAbout - (linearConversion [100,1000,_unitDisplace,0.05,4, true]);
					if (_knowsAbout < 0) then {_knowsAbout = 0};
				};
				sl2aIA_detectGrp setVariable [str _unit, [_knowsAbout,position _unit]];
				/* DBG */
					systemChat format["SL2A IA: knowsAbout après => %1", _knowsAbout];
				/* DBG */
				private _estError = (linearConversion [0,4,_knowsAbout,1000,50, true]); 	//Erreur d'estimation (CEP)
				private _estPos = [[[position _unit,_estError]]] call BIS_fnc_randomPos;
				/* DBG */
					systemChat format["SL2A IA: tir localisé, erreur estimée => %1 m.", _estError];
				/* DBG */

				//Si la détection est un succès (knowsAbout>0), l'enregistrement du tir permet d'estimer une localisation.
				if (_knowsAbout > 0) then {
					
					//Dès que l'erreur d'estimation est suffisamment faible (une autre valeur magique), on pousse une mission de tir dans la liste
					if (_estError <= 250 && _estError > 150) then {
						//On commande un tir de réglage, c'est plus amusant :-D
						sl2aIA_fireMissions pushBack [_estPos,_estError,1];
						/* DBG */
							systemChat format["SL2A IA: mission de tir ajoutée (%1 | %2)", _estPos, _estError];
						/* DBG */		
					} else {
						if (_estError <= 150 && _estError > 0) then {
							//On demande un tir d'efficacité !
							sl2aIA_fireMissions pushBack [_estPos,_estError,selectRandom [8,12]];
							/* DBG */
								systemChat format["SL2A IA: mission de tir ajoutée (%1 | %2)", _estPos, _estError];
							/* DBG */		
						};						
					};				
					/* DBG */
						//On créé des marqueurs locaux
						private _mk_zn = createMarkerLocal [(format ["mk_sl2a_border_%1",_estError]),_estPos];
						_mk_zn setMarkerShapeLocal "ELLIPSE";
						_mk_zn setMarkerBrushLocal "border";
						_mk_zn setMarkerSizeLocal [_estError,_estError];
						private _mk_zn = createMarkerLocal [(format ["mk_sl2a_zn_%1",_estError]),_estPos];
						_mk_zn setMarkerShapeLocal "ELLIPSE";
						_mk_zn setMarkerBrushLocal "Solid";
						_mk_zn setMarkerSizeLocal [_estError,_estError];
						_mk_zn setMarkerAlphaLocal 0.1;
						private _mk_pos = createMarkerLocal [(format ["mk_sl2a_pos_%1",_estError]),_estPos];
						_mk_pos setMarkerTypeLocal "Contact_dot1";
						_mk_pos setMarkerColorLocal "ColorRed";
						_mk_pos setMarkerTextLocal format ["%1 | %2", _unitDetect, str _estError];
					/* DBG */	
				};
			};
		};

		if (sl2aPl_side isNotEqualTo false) then {
		};
	}

] call CBA_fnc_addClassEventHandler;