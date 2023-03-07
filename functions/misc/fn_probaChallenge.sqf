params [
	"_linkedObject",
	["_maxDuration",300],
	["_tbProba", [0.001,0.01,0.1,0.66]],
	["_chatty", true],
	["_forceSuccessAtEnd", false]
];

// Test only
/*
_linkedObject = computer;
private _maxDuration = 120;
private _tbProba = [0,0,0.01,0.02,0.03,1];
_chatty = true;
_linkedObject setVariable ["lastChallengeResult", ""];
*/

/* Initialize state variables for the linked object */
//All these variables are public (global exec)
//_linkedObject setVariable ["challengeSuccessfull", false, true];
private _stopHacking = false; //Possibility to run parallel challenges and to succeed from another challenge
_linkedObject setVariable ["isBeeingChallenged", true, true];

/* Initialize program variables */
private _time0 = time;
private _elapsedTime = 0;
private _totAttempts = 40;
private _totSteps = 4;
private _nbAttemptsPerStep = _totAttempts / _totSteps; 
private _loopDuration = _maxDuration / _totAttempts;
private _curAttempt = _totAttempts;
private _idCurProba = 0;
private _curProba = _tbProba select _idCurProba;
private _p = 0;
private _img = 'img\hacker_1.jpg';

/* Welcome message for user */

if (_chatty) then {
	private _lastStepProba = _tbProba select (_totSteps - 1);
	private _lastP = 1-((1-_lastStepProba)^_nbAttemptsPerStep); 
	private _str = str ([_lastP * 100, 2] call BIS_fnc_cutDecimals) + " %.";
	hintSilent parseText format [ 
  		"<br /><t size='3.0'><img image='img\hacker_1.jpg' /></t><br /><br /> 
   		<t color='#22e1e1' size='1.5'>Challenge system is up and running.</t><br /><br />
   		<t size='1.2'>Maximum time to run : %1 s.</t><br /><br />
   		<t size='1.2'>Final probability of success : ~%2</t><br /><br />",  
  		_maxDuration, 
  		_str 
  	];
};

for [{_curAttempt = _totAttempts}, {(_curAttempt > 0) && !(_stopHacking)}, {_curAttempt = _curAttempt}] do {
	
	for [{_k = 1}, {(_k < _nbAttemptsPerStep + 1) && !(_stopHacking)}, {_k = _k + 1}] do {
		
		/*DBG
		_str = "_curAttempt:" + str _curAttempt + " | _k: " + str _k; 
		systemChat _str;
		*/
		
		if (_chatty) then {
			_elapsedTime = (floor(time - _time0));
			//Calculate the probability of success after k attempts with the formula P = 1 - (1-p)^k to display the total probability to user
			_p = 1-((1-_curProba)^_k);
			systemChat " ";
			systemChat " ";
			systemChat " ";
			systemChat "Challenge report :";
			_str = "Challenge is running since " + str _elapsedTime + " s. (" + str (_maxDuration - _elapsedTime) + " s. left)";
			systemChat _str;
			_str = "Probability of success for next attempt : about " + str ([_p * 100, 2] call BIS_fnc_cutDecimals) + " %.";
			systemChat _str;
		};

		/*DBG
		_str = "Current step proba: " + str _curProba + " | Next probability of success: " + str _p;
		systemChat _str;
		*/

		// die roll : if the challenge is successfull, exit the loop after updating linked object variables
		if (random 1 < _curProba) exitWith {
			if (_chatty) then {
				_strPoS = str ([_p * 100, 2] call BIS_fnc_cutDecimals) + " %";
				hintSilent parseText format [ 
					"<br /><t size='3.0'><img image='img\hacker_1.jpg' /></t><br /><br /> 
					<t color='#48e122' size='1.5'>Challenge succeeded after %1 s. !</t><br /><br />
					<t size='1.2'>Last probability of success was %2.</t><br /><br />",  
					_elapsedTime, 
					_strPoS 
				];
			};
			_linkedObject setVariable ["challengeSuccessfull", true, true];
			_linkedObject setVariable ["isBeeingChallenged", false, true];
			_linkedObject setVariable ["lastChallengeResult",[true, _elapsedTime, _p], true];
		};
		_stopHacking = _linkedObject getVariable "challengeSuccessfull";
		_curAttempt = _curAttempt - 1;
		sleep _loopDuration;
	};
	
	if (_idCurProba < _totSteps -1) then {
		_idCurProba = _idCurProba + 1;
		_curProba = _tbProba select _idCurProba;
	};

	if (_chatty && (_curAttempt == 0) && !(_stopHacking)) then {
		_linkedObject setVariable ["lastChallengeResult",[false, _elapsedTime + _loopDuration, _p], true];
		_strPoS = str ([_p * 100, 2] call BIS_fnc_cutDecimals);
		hintSilent parseText format [ 
			"<br /><t size='3.0'><img image='img\hacker_1.jpg' /></t><br /><br /> 
			<t color='#ff0000' size='1.5'>Challenge failed !</t><br /><br />
			<t size='1.2'>Last probability of success was<br /> ~ %1.</t><br /><br />
			Same player shoot again ?<br /><br />", 
			_strPoS 
		];
	}

};