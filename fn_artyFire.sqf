/* Effectue des tirs d'artillerie à partir d'une liste de missions (tableau global) */

while {true} do {

	if (count sl2aIA_fireMissions > 0) then {
	
		private _fireMissionData = sl2aIA_fireMissions deleteAt 0;
		private _firePos = _fireMissionData#0;
		private _fireRadius = _fireMissionData#1;
		private _nbRounds = _fireMissionData#2;
		private _min = 5;
		private _max = 10;
		systemChat format["SL2A IA: mission de tir sur position %1 et rayon %2",_firePos, _fireRadius];

		//Gestion de la zone d'interdiction de feu. Si une unité amie est dans le rayon de tir (transmis en paramètre) + 100 m., l'ordre de tir est annulé
		private _unitsInNFZ = (units opfor) select {_x distance2D _firePos <= _fireRadius + 100};
		if (count _unitsInNFZ > 0) exitWith {
			systemChat format["SL2A IA: mission de tir annulée (unités amies dans la zone de danger)"];
		};

		//On répartit le nombre de tirs sur chaque unité...
		private _nbUnits = count sl2aIA_counterUnits;
		private _nbRndPerUnit = floor _nbRounds / _nbUnits;
		if (_nbRndPerUnit isEqualTo 0) then {_nbRndPerUnit = 1};

		//...Et on balance la purée
		{
			[_x, _firePos, currentMagazine _x, _fireRadius, _nbRndPerUnit, [_min,_max]] spawn BIS_fnc_fireSupport;
			_x setAmmo [currentMagazine _x,1]; //Munitions infinies	
		} forEach sl2aIA_counterUnits;

	};

	sleep (random 20) + 20;	
};




