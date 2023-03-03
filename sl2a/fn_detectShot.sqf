params ["_unit", "_side", "_detectGrp", "_sensiv",["_isPLayer", false], "_ammo"];

//Filtre les tirs des pièces amies
if (_side isEqualTo side _unit) exitWith {
	//systemChat "SL2A IA: tir de mortier ami détecté (filtré)"
};
private _unitDetect = leader _detectGrp; 
private _distance = _unitDetect distance2D _unit;
if (sl2a_DBG) then {
	[format ["SL2A: distance entre le tir et le groupe de détection ( %1) => %2.", _detectGrp, str _distance]] remoteExec ["systemChat"];
};

//Le système est inactif si son support est en déplacement
private _vehDetect = objNull;
if !(_isPlayer) then {
	_vehDetect = vehicle leader _detectGrp;
} else {
	_vehDetect = vehicle _detectGrp;
};
if (speed _vehDetect > 3) exitWith {
	if (sl2a_DBG) then {
		[format ["SL2A: %1 est en déplacement. SL2A inactif", _detectGrp]] remoteExec ["systemChat"];
	};
};

//Ajuste la probabilité de détection en fonction du calibre.
private _caliber = getNumber (configFile >> "CfgAmmo" >>_ammo >> "ace_rearm_caliber");
if (_caliber > 82) then {
	private _varSensiv = _caliber - 82;
	private _sensivBonus = linearConversion [0,300, _varSensiv, 0,3000000];
	_sensiv = _sensiv + _sensivBonus;
	if (sl2a_DBG) then {
		[format ["SL2A: calibre %1 détecté. Bonus de sensibilité= %2. Nouvelle sensibilité: %3", _caliber, (_sensivBonus/1000000), _sensiv/1000000]] remoteExec ["systemChat"];
	};
};
//Ajuste la probabilité de détection en fonction de la distance
private _probaEnreg = [_distance,_sensiv] call invSquare;
//Ajuste la probabilité de détection en fonction du relief
private _reliefEffect = [_detectGrp, _unit] call getTerrainThickness;
_probaEnreg = _probaEnreg - (_reliefEffect/10000);
if (sl2a_DBG) then {
	[format ["SL2A: effet de relief => %1 (%2 oté de la proba)", _reliefEffect, _reliefEffect/10000]] remoteExec ["systemChat"];
};
if (sl2a_DBG) then {
	[format ["SL2A: proba enreg => %1", _probaEnreg]] remoteExec ["systemChat"];
};
//Si le tir est détecté avec succès, sa localisation va être déterminée
if (random 1 < _probaEnreg) then {
	//Chaque tir enregistré augmente la précision de détection
	private _targetKnowledge = _detectGrp getVariable [str _unit,[0,position _unit]];
	private _knowsAbout = _targetKnowledge#0;
	if (_knowsAbout <= 4) then {
		_knowsAbout = _knowsAbout + (linearConversion [0,0.75,_probaEnreg,0.01,0.4, true]);
	};
	//Si l'unité s'est déplacée depuis la précédente détection, la précision chute
	private _unitDisplace = position _unit distance2D _targetKnowledge#1;
	if (_unitDisplace > 1) then {					
		if (sl2a_DBG) then {
			[format ["SL2A: l'unité s'est déplacée de %1", _unitDisplace]] remoteExec ["systemChat"];
		};
		_knowsAbout = _knowsAbout - (linearConversion [100,1000,_unitDisplace,0.05,4, true]);
		if (_knowsAbout < 0) then {_knowsAbout = 0};
	};
	_detectGrp setVariable [str _unit, [_knowsAbout,position _unit]];
	if (sl2a_DBG) then {
		[format["SL2A: knowsAbout après => %1", _knowsAbout]] remoteExec ["systemChat"];
	};
	private _estError = (linearConversion [0,4,_knowsAbout,1000,50, true]); 	//Erreur d'estimation (CEP)
	private _estPos = [[[position _unit,_estError]]] call BIS_fnc_randomPos;
	if (sl2a_DBG) then {
		[format["SL2A: tir localisé, erreur estimée => %1 m.", _estError]] remoteExec ["systemChat"];
	};

	//Si la détection est un succès (knowsAbout>0), l'enregistrement du tir permet d'estimer une localisation.
	if (_knowsAbout > 0) then {
		
		if (_isPLayer) then {
			//Si c'est un système joueur, on crée des marqueurs pour l'équipage du véhicule (un beau remoteExec !)
			[
				([_estError,_estPos,_unitDetect,_detectGrp, _caliber]),
				{
					params ["_estError", "_estPos", "_unitDetect", "_detectGrp", "_caliber"];
					if (vehicle player isEqualTo _detectGrp) then {
						vehicle player vehicleChat format ["Tir de calibre %1 localisé. ECP: %2", _caliber, _estError]; 
						private _mk_zn = createMarkerLocal [(format ["mk_sl2a_border_%1_%2",_estError,_unitDetect]),_estPos,4];
						_mk_zn setMarkerShapeLocal "ELLIPSE";
						_mk_zn setMarkerBrushLocal "border";
						_mk_zn setMarkerSizeLocal [_estError,_estError];
						if (_estError isEqualTo 50) then {
							_mk_zn setMarkerColorLocal "ColorRed";	
						};
						_mk_zn = createMarkerLocal [(format ["mk_sl2a_zone_%1_%2",_estError,_unitDetect]),_estPos,4];
						_mk_zn setMarkerShapeLocal "ELLIPSE";
						_mk_zn setMarkerBrushLocal "Solid";
						_mk_zn setMarkerSizeLocal [_estError,_estError];
						_mk_zn setMarkerAlphaLocal 0.3;
						if (_estError isEqualTo 50) then {
							_mk_zn setMarkerColorLocal "ColorRed";	
						};
						private _mk_pos = createMarkerLocal [(format ["mk_sl2a_pos_%1_%2",_estError,_unitDetect]),_estPos,4];
						_mk_pos setMarkerTypeLocal "Contact_dot1";
						_mk_pos setMarkerColorLocal "ColorRed";
						_mk_pos setMarkerTextLocal format ["Cal. %1 | %2", _caliber, str _estError];	
					} 
				}
			] remoteExec ["call"];			
		} else { //Si c'est un système IA, on commande des tirs de contre batterie
			//Dès que l'erreur d'estimation est suffisamment faible (une autre valeur magique), on pousse une mission de tir dans la liste
			if (_estError <= 250 && _estError > 150) then {
				//On commande un tir de réglage, c'est plus amusant :-D
				sl2aIA_fireMissions pushBack [_estPos,_estError,1];
				if (sl2a_DBG) then {
					[format ["SL2A: mission de tir ajoutée (%1 | %2)", _estPos, _estError]] remoteExec ["systemChat"];
				};		
			} else {
				if (_estError <= 150 && _estError > 0) then {
					//On demande un tir d'efficacité !
					sl2aIA_fireMissions pushBack [_estPos,_estError,selectRandom [8,12]];
					if (sl2a_DBG) then {
						[format ["SL2A: mission de tir ajoutée (%1 | %2)", _estPos, _estError]] remoteExec ["systemChat"];
					};		
				};						
			};
		};				
	};
};