/*
	Function: fn_Fx_Boom

	Description:
		Add explosion, fire and smoke effects on an object. MP compatible

	Parameters:
		_obj - the object to which adding effect
		_explosion - optional default [true, "medium", 0.5] - create explosion effect : effect or not, small/medium/big effect, vertical offset from object position  ARRAY
		_fire - optional default [true, "medium", 0.5] - create fire effect (same array values as previous parameter)
		_smoke - optional default [true, "medium", 0.5] - create smoke effect (same array values as previous parameter)
		
	Returns:
		Nothing

	Examples:
		(begin example)
		(end)

	Author:
		tanin69

*/


params [
	"_obj",
	["_explo", [true, "medium", 0.5]],
	["_fire", [true, "medium", 0.5]],
	["_smoke", [true, "medium", 0.5]]
];

systemChat str _this;

private _objPos = getPos (_obj);

//Explosion
if (_explo#0) then {
	private _bomb = "";
	private _boom = "";
	private _exploPos = [(_objPos#0),(_objPos#1),_explo#2];
	sleep 3 + random 4;
	if (_explo#1 isEqualTo "small") then {
		_boom = "ACE_IEDUrbanSmall_Range_Ammo";
	};
	if (_explo#1 isEqualTo "medium") then {
		_boom = "HelicopterExploSmall";
	};
	if (_explo#1 isEqualTo "big") then {
		_boom = "HelicopterExploBig";
	};
	_bomb = _boom createVehicle _exploPos;
	_bomb setDamage 1;
};

//Flammes
if (_fire#0) then {
	private _fireEffect = "#particlesource" createVehicle [_objPos#0, _objPos#1, _fire#2];
	private _refractEffect = "#particlesource" createVehicle [_objPos#0, _objPos#1, _fire#2];
	if (_fire#1 isEqualTo "small") then {
		[_fireEffect, "fxp_PlanExplFireMin1"] remoteExec ["setParticleClass", -2];
		[_fireEffect,[0.1,1.5,0.5]] remoteExec ["setParticleFire", -2] ;
	};
	if (_fire#1 isEqualTo "medium") then {
		private _fireEffect_1 = "#particlesource" createVehicle [_objPos#0, _objPos#1 + 0.5, _fire#2];
		private _fireEffect_2 = "#particlesource" createVehicle [_objPos#0, _objPos#1 - 0.3, _fire#2];
		private _fireEffect_3 = "#particlesource" createVehicle [_objPos#0+1.2, _objPos#1 - 0.8, _fire#2];
		[_fireEffect, "SmallFireBarrel"] remoteExec ["setParticleClass", -2];
		[_fireEffect_1, "SmallFireBarrel"] remoteExec ["setParticleClass", -2];
		[_fireEffect_2, "fxp_PlanExplFireMin1"] remoteExec ["setParticleClass", -2];
		[_fireEffect_3, "fxp_PlanExplFireMin1"] remoteExec ["setParticleClass", -2];
		[_fireEffect, [0.1,1.5,0.5]] remoteExec ["setParticleFire", -2];
		[_refractEffect, "ObjectDestructionRefractSmall"] remoteExec ["setParticleFire", -2];
	};
	if (_fire#1 isEqualTo "big") then {
		private _fireEffect_1 = "#particlesource" createVehicle [_objPos#0+3, _objPos#1+3, _fire#2];
		private _fireEffect_2 = "#particlesource" createVehicle [_objPos#0-4, _objPos#1+2.5, _fire#2];
		private _fireEffect_3 = "#particlesource" createVehicle [_objPos#0+1.2, _objPos#1-2.4, _fire#2];
		private _fireEffect_4 = "#particlesource" createVehicle [_objPos#0+1.5, _objPos#1-1.5, _fire#2];
		[_fireEffect, "fxp_objectdestructionfire1"] remoteExec ["setParticleClass", -2];
		[_fireEffect_1, "SmallFireBarrel"] remoteExec ["setParticleClass", -2];
		[_fireEffect_2, "SmallFireBarrel"] remoteExec ["setParticleClass", -2];
		[_fireEffect_3, "SmallFireBarrel"] remoteExec ["setParticleClass", -2];
		[_fireEffect_4, "fxp_objectdestructionfire1"] remoteExec ["setParticleClass", -2];
		[_fireEffect, [2,3,0.5]] remoteExec ["setParticleFire", -2];
		[_refractEffect, "ObjectDestructionRefract"] remoteExec ["setParticleFire", -2];
	};
};

sleep 2 + random 2;

//Fumée
if (_smoke#0) then {
	private _smokeEffect = "#particlesource" createVehicle [(_objPos#0),(_objPos#1),_smoke#2];  
	if (_smoke#1 isEqualTo "small") then {
		[_smokeEffect, "MediumDestructionSmoke"] remoteExec ["setParticleClass", -2];
	};
	if (_smoke#1 isEqualTo "medium") then {
		[_smokeEffect, "ObjectDestructionSmokeSmallx"] remoteExec ["setParticleClass", -2];
	};
	if (_smoke#1 isEqualTo "big") then {
		[_smokeEffect, "fxp_CarFuelDestSmoke"] remoteExec ["setParticleClass", -2];
	};
};