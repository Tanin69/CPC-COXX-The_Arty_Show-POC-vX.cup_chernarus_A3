params [
	["_callingScript", ""],
	["_msg", ""],
	["_value", ""],
	["_outputType", 1],
	["_msgType", 0]
];

switch _msgType do {
	case 0: {_msgType = "INFO"};
	case 1: {_msgType = "WARNING"};
	case 2: {_msgType = "ERROR"};
	case 3: {_msgType = "FATAL ERROR"};
};

if (_outputType isEqualTo 0) then {
	hint format ["%1 %2: %3 -> %4", _callingScript, _msgType, _msg, _value];
};
if (_outputType isEqualTo 1) then {
	diag_log text format ["%1 %2: %3 -> %4", _callingScript, _msgType, _msg, _value];
};
if (_outputType isEqualTo 2) then {
	systemChat format ["%1 %2: %3 -> %4", _callingScript, _msgType, _msg, _value];
};
if (_outputType isEqualTo 3) then {
	diag_log text format ["%1 %2: %3 -> %4", _callingScript, _msgType, _msg, _value];
	systemChat format ["%1 %2: %3 -> %4", _callingScript, _msgType, _msg, _value];
};




