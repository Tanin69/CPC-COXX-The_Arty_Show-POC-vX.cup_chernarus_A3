// Lance SL2A
[blufor, resistance, ["StaticMortar","CUP_B_M119_HIL","CUP_B_M270_DPICM_HIL","CUP_B_M1129_MC_MK19_Woodland"], 5, 5, false] execVM "sl2a\initsl2a.sqf";

// Lance les scripts d'artillerie hostiles
[[mortar_blufor_1,mortar_blufor_2,mortar_blufor_3],["marker_bomb_zone_blufor_1","marker_bomb_zone_blufor_2","marker_bomb_zone_blufor_3"]] execVM "arty.sqf";
[[mlr_blufor_1,mlr_blufor_2,mlr_blufor_3],["marker_bomb_zone_blufor_4","marker_bomb_zone_blufor_5"]] execVM "arty.sqf";
[[m119_blufor_1,m119_blufor_2,m119_blufor_3],["marker_bomb_zone_blufor_1","marker_bomb_zone_blufor_2","marker_bomb_zone_blufor_3","marker_bomb_zone_blufor_4","marker_bomb_zone_blufor_5"]] execVM "arty.sqf";

// Fait déguerpir le véhicule de contre-batterie s'il reçoit des tirs d'arty à proximité
while {alive M1119} do {
	sleep 10;
	if (count (allMissionObjects "#crater" select {_x distance2d M1119 < 150}) > 0) then {
		systemChat "On est bombardés !"
	};
};

