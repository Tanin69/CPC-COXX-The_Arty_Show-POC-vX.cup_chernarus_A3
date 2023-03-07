/* Ajoute les objets à un conteneur (véhicule, caisse ou sac à dos)

Paramètres :
0: OBJ, vehicle to which items will be added
1: ARRAY of STRINGS, array of classnames to add to the vehicle
2: BOOL clear items in vehicles. Optional default true

*/

params [
	"_veh",
	"_tbClassNames",
	["_clear", true]
];

if (_clear) then {
	clearItemCargoGlobal _veh;
	clearMagazineCargoGlobal _veh;
	clearWeaponCargoGlobal _veh;
	clearBackpackCargoGlobal _veh;
};

{
	if (_x#0 isKindOf "Bag_Base") then {
		_veh addBackpackCargoGlobal _x;
	} else {
		_veh addItemCargoGlobal _x;
	}
	
} forEach _tbClassNames;