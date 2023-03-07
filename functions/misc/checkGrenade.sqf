_unit = player;
//systemChat str _unit;
_grenade = false;
//On vérifie le niveau de connaissance du joueur par le ENIS du périmètre *avant qu'il n'entre dans le tunnel*
//Le knowsAbout est un poil brutal... Voir si on peut faire mieux avec getHideFrom ou targetKnowledge
{
	if (_x inArea trgTest) then {
		systemChat format ["Unité %1 dans le périmètre", _x];
		_knowsAbout = _x knowsAbout _unit;
		systemChat str _knowsAbout;
		if (_knowsAbout >= 2) exitWith {systemChat "T'es repéré, mec"};
	};
} forEach units opfor;

//Le joueur entre dans le tunnel. On vérifie s'il y a des joueurs amis dans le périmètre. Si oui, la gre ne pourra pas être lancée
{
	if (_x inArea trgTest) exitWith {_grenade = true}
} forEach allPlayers;
if (_grenade isEqualTo false) then {
	systemChat "T'es couvert, mec";
} else {
	systemChat "Tu risques de te prendre une gre !";
};


