/* Initialise l'environnement sl2a */

params [["_sideIA", opfor], ["_sidePlayer", blufor]];

sl2aIA_side = _sideIA;
sl2aIA_detectGrp = objNull;
sl2aIA_counterGrp = objNull;
sl2aIA_fireMissions = [];
sl2aIA_isActive = true;

//Compile les fonctions utilitaires
invSquare = compile preprocessfilelinenumbers ("fn_invSquare.sqf");
artyCounterFire = compile preprocessfilelinenumbers ("fn_artyFire.sqf");

//Initialise les groupes et variables IA
if (sl2aIA_side isNotEqualTo "") then {
	private _isUnit = objNull;
	//Choppe l'unité de détection. La première unité répondant au critère sera désignée comme étant l'unité de détection.
	{
		_isUnit = _x getVariable ["sl2a_detect", false];
		if (_isUnit) exitWith {sl2aIA_detectGrp = _x};
	} forEach allGroups select {_x isEqualTo sl2aIA_side};
	//Choppe l'unité de contre-batterie. La première unité répondant au critère sera désignée comme étant l'unité de contre-batterie.
	{
		_isUnit = _x getVariable ["sl2a_counter", false];
		if (_isUnit) exitWith {sl2aIA_counterGrp = _x};
	} forEach allGroups select {_x isEqualTo sl2aIA_side};
	/* DBG */
	systemChat format ["SL2A init: Groupe IA de détection> %1 | Groupe IA de contre-batterie> %2", sl2aIA_detectGrp, sl2aIA_counterGrp];
	/* DBG */
	if (sl2aIA_detectGrp isEqualTo objNull || sl2aIA_counterGrp isEqualTo objNull) then {sl2aIA_isActive = false};
} else {
	sl2aIA_isActive = false;
};
/* DBG */
systemChat format ["SL2A init: SL2A est actif pour les IA> %1", sl2aIA_isActive];
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
		if (sl2aIA_isActive) then {
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
			private _probaEnreg = [_distance,2000000] call invSquare; //Attention, le second argument est une sorte de chiffre magique pour déterminer la proba d'enregistrement du tir par le SL2A
			/* DBG */
				systemChat format["SL2A IA: proba enreg => %1", _probaEnreg];
			/* DBG */
			if (random 1 < _probaEnreg) then {
				//Chaque tir enregistré augmente la précision de détection
				private _knowsAbout = sl2aIA_detectGrp knowsAbout _unit;
				sl2aIA_detectGrp reveal [_unit,_knowsAbout + (linearConversion [0,0.75,_probaEnreg,0.01,0.1])];
				_knowsAbout = sl2aIA_detectGrp knowsAbout _unit;
				/* DBG */
					systemChat format["SL2A IA: knowsAbout après => %1", sl2aIA_detectGrp knowsAbout _unit];
				/* DBG */
				private _tgKnowledge = _unitDetect targetKnowledge _unit;
				private _estPos = (_tgKnowledge)#6; 	//Position estimée
				private _estError = (_tgKnowledge)#5; 	//Erreur d'estimation (CEP)
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
							//Cadeau de BIS : la position estimée ne redescend jamais, on contourne le problème en modifiant la façon de donner l'erreur d'estimation
							_estError = linearConversion [0,2,_knowsAbout,150,50,true]; //Attention, on a encore quelques valeurs magiques ici
							//On demande un tir d'efficacité !
							sl2aIA_fireMissions pushBack [_estPos,_estError,selectRandom [8,12]];
							/* DBG */
								systemChat format["SL2A IA: mission de tir ajoutée (%1 | %2)", _estPos, _estError];
							/* DBG */
						};						
					};
					//On créé des marqueurs locaux
					private _mk_zn = createMarkerLocal [(format ["mk_plutotarget_zn_%1",_estError]),_estPos];
					_mk_zn setMarkerShapeLocal "ELLIPSE";
					_mk_zn setMarkerBrushLocal "SolidBorder";
					_mk_zn setMarkerSizeLocal [_estError,_estError];
					_mk_zn setMarkerAlphaLocal 0.1;
					private _mk_pos = createMarkerLocal [(format ["mk_plutotarget_pos_%1",_estError]),_estPos];
					_mk_pos setMarkerTypeLocal "Contact_dot1";
					_mk_pos setMarkerColorLocal "ColorRed";
					_mk_pos setMarkerTextLocal format ["%1 | %2", _unitDetect, str _estError];	
				};

			};
		};
	}

] call CBA_fnc_addClassEventHandler;