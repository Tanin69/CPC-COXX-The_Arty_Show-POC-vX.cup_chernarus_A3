while {true} do {

	{
		[_x, getMarkerPos "mrk_bomb_zone_opfor", currentMagazine _x, 100, 5] spawn BIS_fnc_fireSupport;
		_x setAmmo [currentMagazine _x,5]; //Munitions infinies
		sleep (random 5) + 10;
	} forEach [arty_1, arty_2];

	sleep (random 30) + 30;	

};