params ["_arty", "_bombZones"];

while {true} do {

private _bomb_zone = selectRandom _bombZones;

	{	
		[_x, [[[getMarkerPos _bomb_zone,300]]] call BIS_fnc_randomPos, currentMagazine _x, 100, selectRandom [1,3]] spawn BIS_fnc_fireSupport;
		_x setAmmo [currentMagazine _x,5]; //Munitions infinies
	} forEach _arty;

	sleep (random 60) + 60;	

};