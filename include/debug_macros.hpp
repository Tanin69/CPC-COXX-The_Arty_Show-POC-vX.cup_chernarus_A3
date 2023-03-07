/**
* Macros for easier debugging management
* 
* Usage :
* 1) Define debug output. Add a line with :
*    #define DBG_OUTPUT_SCREEN (for output to screen) or
*    #define DBG_OUTPUT_RPT (for output to rpt file)
*    if not defined, output will be to rpt
* 2) Define debug level. After the previous line, add a line with :
*    #define DBG_LEVEL_FULL (all messages will be logged)
*    #define DBG_LEVEL_NORMAL (ERROR and WARNING messages will be logged)
*	 #define DBG_LEVEL_MINIMAL (on ERROR messages will be logged)
* 3) After the previous lines, add a line with :
*    #include "include\debug_macros.hpp" 
Debug message types :
*   LOG : informative message, output only with DBG_LEVEL_FULL
*   WARNING : to be used for warning, but not for errors, output with DBG_LEVEL_FULL and DBG_LEVEL_NORMAL
*   ERROR : to be used for fatal errors, output with all DBG levels
*
* @example
* //Default mode
* #define DBG_OUTPUT_RPT 
* #define DBG_LEVEL_NORMAL
* #include "Cfg\macros.hpp"
*
* @name debug_macros.hpp
* 
* @author tanin69
*
*/

/* 
   Uncomment the following lines to force debug params for all scripts in the mission file.
   Dont forget to #include "include\debug_macros.hpp" at the beginning of script files !
*/ 
/* Full Debug to rpt */
#define DBG_OUTPUT_RPT
#define DBG_LEVEL_FULL

/* Minimal Debug to rpt (only ERROR messages)*/
//#define DBG_OUTPUT_RPT
//#define DBG_LEVEL_MINIMAL


#ifdef DBG_OUTPUT_SCREEN
	#define LOG_OUTPUT systemChat
#endif
#ifdef DBG_OUTPUT_RPT
	#define LOG_OUTPUT diag_log text
#endif
#ifndef LOG_OUTPUT
	#define LOG_OUTPUT diag_log text
#endif

#ifdef DBG_LEVEL_FULL
	#define DBG_LEVEL_NORMAL
#endif
#ifdef DBG_LEVEL_NORMAL
	#define DBG_LEVEL_MINIMAL
#endif
#ifndef DBG_LEVEL_MINIMAL
	#define DBG_LEVEL_NORMAL
	#define DBG_LEVEL_MINIMAL
#endif

#define MISSION_NAME #Mission_scripts
#define SCRIPT_NAME (__FILE__ splitString "\") select (count (__FILE__ splitString "\") - 1)

/**
* INFO messages. Only with DBG_LEVEL_FULL
* @example : INF2("Value of _myVar:", _myVar1)
*/
#ifdef DBG_LEVEL_FULL

	#define INF1(ARG1) LOG_OUTPUT format ["[%1] (%2) INFO: %3", MISSION_NAME, SCRIPT_NAME, ARG1]
	#define INF2(ARG1, ARG2) LOG_OUTPUT format ["[%1] (%2) INFO: %3 %4", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2]
	#define INF3(ARG1, ARG2, ARG3) LOG_OUTPUT format ["[%1] (%2) INFO: %3 %4 %5", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3]
	#define INF4(ARG1, ARG2, ARG3, ARG4) LOG_OUTPUT format ["[%1] (%2) INFO: %3 %4 %5 %6", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4]
	#define INF5(ARG1, ARG2, ARG3, ARG4, ARG5) LOG_OUTPUT format ["[%1] (%2) INFO: %3 %4 %5 %6 %7", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5]
	#define INF6(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6) LOG_OUTPUT format ["[%1] (%2) INFO: %3 %4 %5 %6 %7 %8", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6]
	#define INF7(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7) LOG_OUTPUT format ["[%1] (%2) INFO: %3 %4 %5 %6 %7 %8 %9", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7]
	#define INF8(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8) LOG_OUTPUT format ["[%1] (%2) INFO: %3 %4 %5 %6 %7 %8 %9 %10", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8]

#else

	#define INF1(ARG1)
	#define INF2(ARG1, ARG2)
	#define INF3(ARG1, ARG2, ARG3)
	#define INF4(ARG1, ARG2, ARG3, ARG4)
	#define INF5(ARG1, ARG2, ARG3, ARG4, ARG5)
	#define INF6(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6)
	#define INF7(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7)
	#define INF8(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8)

#endif

/**
* WARNING messages. Only with DBG_LEVEL_FULL and DBG_LEVEL_NORMAL
* @example : WARN4("Value for_myVar1:", _myVar1, "Value for _myVar2:", _myVar2)
*/
#ifdef DBG_LEVEL_NORMAL

	#define WARN1(ARG1) LOG_OUTPUT format ["[%1] (%2) WARNING: %3", MISSION_NAME, SCRIPT_NAME, ARG1]
	#define WARN2(ARG1, ARG2) LOG_OUTPUT format ["[%1] (%2) WARNING: %3 %4", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2]
	#define WARN3(ARG1, ARG2, ARG3) LOG_OUTPUT format ["[%1] (%2) WARNING: %3 %4 %5", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3]
	#define WARN4(ARG1, ARG2, ARG3, ARG4) LOG_OUTPUT format ["[%1] (%2) WARNING: %3 %4 %5 %6", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4]
	#define WARN5(ARG1, ARG2, ARG3, ARG4, ARG5) LOG_OUTPUT format ["[%1] (%2) WARNING: %3 %4 %5 %6 %7", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5]
	#define WARN6(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6) LOG_OUTPUT format ["[%1] (%2) WARNING: %3 %4 %5 %6 %7 %8", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6]
	#define WARN7(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7) LOG_OUTPUT format ["[%1] (%2) WARNING: %3 %4 %5 %6 %7 %8 %9", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7]
	#define WARN8(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8) LOG_OUTPUT format ["[%1] (%2) WARNING: %3 %4 %5 %6 %7 %8 %9 %10", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8]

#else

	#define WARN1(ARG1)
	#define WARN2(ARG1, ARG2)
	#define WARN3(ARG1, ARG2, ARG3)
	#define WARN4(ARG1, ARG2, ARG3, ARG4)
	#define WARN5(ARG1, ARG2, ARG3, ARG4, ARG5)
	#define WARN6(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6)
	#define WARN7(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7)
	#define WARN8(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8)

#endif

/**
* ERROR messages. All DBG_LEVEL
* @example : ERR3("Value for_myVar1:", _myVar1, "is illegal. Script aborted")
*/
#define ERR1(ARG1) LOG_OUTPUT format ["[%1] (%2) ERROR: %3", MISSION_NAME, SCRIPT_NAME, ARG1]
#define ERR2(ARG1, ARG2) LOG_OUTPUT format ["[%1] (%2) ERROR: %3 %4", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2]
#define ERR3(ARG1, ARG2, ARG3) LOG_OUTPUT format ["[%1] (%2) ERROR: %3 %4 %5", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3]
#define ERR4(ARG1, ARG2, ARG3, ARG4) LOG_OUTPUT format ["[%1] (%2) ERROR: %3 %4 %5 %6", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4]
#define ERR5(ARG1, ARG2, ARG3, ARG4, ARG5) LOG_OUTPUT format ["[%1] (%2) ERROR: %3 %4 %5 %6 %7", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5]
#define ERR6(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6) LOG_OUTPUT format ["[%1] (%2) ERROR: %3 %4 %5 %6 %7 %8", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6]
#define ERR7(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7) LOG_OUTPUT format ["[%1] (%2) ERROR: %3 %4 %5 %6 %7 %8 %9", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7]
#define ERR8(ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8) LOG_OUTPUT format ["[%1] (%2) ERROR: %3 %4 %5 %6 %7 %8 %9 %10", MISSION_NAME, SCRIPT_NAME, ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8]
