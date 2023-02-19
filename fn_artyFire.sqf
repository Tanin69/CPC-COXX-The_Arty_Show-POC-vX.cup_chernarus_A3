

while {alive (vehicle leader sl2aIA_counterGrp)} do {

	if (count sl2aIA_fireMissions > 0) then {
	
		private _fireMissionData = sl2aIA_fireMissions deleteAt 0;
		private _firePos = _fireMissionData#0;
		private _fireRadius = _fireMissionData#1;
		private _nbTirs = _fireMissionData#2;
		private _min = 5;
		private _max = 10;
		systemChat format["SL2A IA: mission de tir sur position %1 et rayon %2",_firePos, _fireRadius];
		
		//Gestion de la zone d'interdiction de feu. Si une unité amie est dans le rayon de tir (transmis en paramètre) + 100 m., l'ordre de tir est annulé
		_unitsInNFZ = (units opfor) select {_x distance2D _firePos <= _fireRadius + 100};
		if (count _unitsInNFZ > 0) exitWith {
			systemChat format["SL2A IA: mission de tir annulée (unités amies dans la zone de danger)"];
		};

		//if (_fireRadius < 50) then {_fireRadius = 50} else {_fireRadius};
		[vehicle leader sl2aIA_counterGrp, _firePos, "8Rnd_82mm_Mo_shells", _fireRadius, _nbTirs, [_min,_max]] spawn BIS_fnc_fireSupport;

	};
	sleep (random 20) + 20;	
};




