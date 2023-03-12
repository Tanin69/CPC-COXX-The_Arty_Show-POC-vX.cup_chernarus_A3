// Lance SL2A
[blufor, resistance, ["StaticMortar","CUP_B_M119_HIL","CUP_B_M270_DPICM_HIL","CUP_B_M1129_MC_MK19_Woodland"], 5, 5, false] execVM "sl2a\initsl2a.sqf";

// Lance les scripts d'artillerie hostiles
[[mortar_blufor_1,mortar_blufor_2,mortar_blufor_3],["marker_bomb_zone_blufor_1","marker_bomb_zone_blufor_2","marker_bomb_zone_blufor_3"]] execVM "arty.sqf";
[[mlr_blufor_1,mlr_blufor_2,mlr_blufor_3],["marker_bomb_zone_blufor_4","marker_bomb_zone_blufor_5"]] execVM "arty.sqf";
[[m119_blufor_1,m119_blufor_2,m119_blufor_3],["marker_bomb_zone_blufor_1","marker_bomb_zone_blufor_2","marker_bomb_zone_blufor_3","marker_bomb_zone_blufor_4","marker_bomb_zone_blufor_5"]] execVM "arty.sqf";

// Fait déguerpir le véhicule de contre-batterie s'il reçoit des tirs d'arty à proximité
/*
while {alive M1119} do {
	sleep 10;
	if (count (allMissionObjects "#crater" select {_x distance2d M1119 < 150}) > 0) then {
		systemChat "On est bombardés !"
	};
};
*/

/* Paramétrage des armes fixes */

	/* Rechargement des munitions via ACE Logistics */

		/*
		Réglages de ACE Crew Served Weapons :
			-> Ammo handling : disabled
		Réglages de ACE Artillery / mk6 mortar :
			-> Allow mk6 computer : false (évidemment)
			-> Use ammunition handling : false
		Réglages de ACE Logistics / Rearm :
			-> Rearm amount : Entire Magazine
			-> Ammunition supply : Only specific Magazines
		Attention : il ne faut pas utiliser les CSW de l'arsenal, mais bien les armes vanilla !
		*/

		//Chargement du véhicule
		private _veh = ammo_veh;
		//144 obus HE
		for "_i" from 1 to 18 do
		{  
			[_veh, "8Rnd_82mm_Mo_shells"] call ace_rearm_fnc_addMagazineToSupply;
		};
		//48 obus Fumigènes
		for "_i" from 1 to 6 do
		{  
			[_veh, "8Rnd_82mm_Mo_Smoke_white"] call ace_rearm_fnc_addMagazineToSupply;
		};
		//24 obus éclairants
		for "_i" from 1 to 3 do
		{  
			[_veh, "8Rnd_82mm_Mo_Flare_white"] call ace_rearm_fnc_addMagazineToSupply;
		};

		//Paramétrage des mortiers. Pour pouvoir gérer leur chargement initial, il faut les créer et les charger "montés" dans le véhicule
		//Fonction pour créer et charger des caisses d'obus
		private _create_load_mortars = {
			params [
				"_mortarCls",
				"_ammoVeh",
				["_mortarLoadOut",[]]
			];
			private _mortar = createVehicle [_mortarCls, [0,0,0]];
			{_mortar removeMagazine _x} forEach magazines _mortar;
			private _nbMag = count _mortarLoadOut;

			if (_nbMag isNotEqualTo 0) then {
				private _i = 1;
				for "_i" from 1 to _nbMag do {
					for "_j" from 1 to (_mortarLoadOut#(_i-1)#1) do {
						_mortar addMagazineTurret [_mortarLoadOut#(_i-1)#0,[0],8];
					};
				};
			};			
			[_mortar, _ammoVeh, true] call ace_cargo_fnc_loadItem;
		};

		["B_G_Mortar_01_F", _veh, [["8Rnd_82mm_Mo_shells", 2]]] call _create_load_mortars;
		["B_G_Mortar_01_F", _veh, [["8Rnd_82mm_Mo_shells", 2]]] call _create_load_mortars;
		["B_G_Mortar_01_F", _veh, [["8Rnd_82mm_Mo_shells", 2]]] call _create_load_mortars;

	/* Rechargement des munitions via ACE Logistics */

/* Paramétrage des armes fixes */

/* Vehicle cargo */
	
	private _cargo_ammoVeh = [
		["ACE_EntrenchingTool",4],
		["CUP_30rnd_556x45_Emag",50],
		["CUP_launch_M136",3],
		["CUP_HandGrenade_M67",20],
		["SmokeShellRed",10],
		["SmokeShell",10],
		["ACRE_PRC148",4],
		["CUP_B_Kombat_Olive",4],
		["ACE_packingBandage",20],
		["ACE_elasticBandage",20],
		["ACE_fieldDressing",20],
		["ACE_quikclot",20],
		["ACE_salineIV_250",10],
		["ACE_salineIV_500",10],
		["ACE_salineIV",10],
		["ACE_morphine",30],
		["ACE_atropine",30],
		["ACE_tourniquet",10],
		["ACE_surgicalKit",1],
		["ACE_splint",20],
		["ACE_Maptools",4],
		["Toolkit",2]
	];

	{[_x,_cargo_ammoVeh] call int_fnc_addCargo} forEach [ammo_veh, radio_veh, reco_veh];

/* Vehicle cargo */
