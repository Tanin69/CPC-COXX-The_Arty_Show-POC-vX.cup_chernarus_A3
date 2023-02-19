/*
	Calcule la fonction inverse du carré avec certains paramètres
	Les valeurs par défaut sont réglées sur la probabilité de détection d'un signal sonore en fonction de la distance 
*/

params ["_distance", ["_power",1000000], ["_max",0.75], ["_min", 0.001]];

if (_distance isEqualTo 0) exitWith {0};
_return = _power / (_distance * _distance);
//systemChat format ["Valeur de retour de fn_invSquare: %1", _return];
if (_return > _max) exitWith {_max};
if (_return < _min) exitWith {_min};
_return
