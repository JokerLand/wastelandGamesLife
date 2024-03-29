waitUntil {!(isNull (findDisplay 46))};
disableSerialization;
/*
	File: fn_statusBar.sqf
	Author: Osef (Ported to EpochMod by piX)
	Edited by: [piX]
	Description: Puts a small bar in the bottom centre of screen to display in-game information
	
	PLEASE KEEP CREDITS - THEY ARE DUE TO THOSE WHO PUT IN THE EFFORT!

*/
_rscLayer = "StatusBar" call BIS_fnc_rscLayer;
_rscLayer cutRsc["StatusBar","PLAIN"];
systemChat format["Chargement des informations joueurs ...", _rscLayer];

[] spawn {
	sleep 5;
	_counter = 240;
	_timeSinceLastUpdate = 0;
	while {true} do
	{
		sleep 1;
		_counter = _counter - 1;
		_time = (round(360-(serverTime)/60));  //edit the '240' (60*4=240) to change the countdown timer if your server restarts are shorter or longer than 4 hour intervals
		_hours = (floor(_time/60));
		_minutes = (_time - (_hours * 60));
		
	switch(_minutes) do
	{
		case 9: {_minutes = "09"};
		case 8: {_minutes = "08"};
		case 7: {_minutes = "07"};
		case 6: {_minutes = "06"};
		case 5: {_minutes = "05"};
		case 4: {_minutes = "04"};
		case 3: {_minutes = "03"};
		case 2: {_minutes = "02"};
		case 1: {_minutes = "01"};
		case 0: {_minutes = "00"};
	};
		
		((uiNamespace getVariable "StatusBar")displayCtrl 1000)ctrlSetText format["FPS: %1 | BLUFOR %2 | OPFOR %3 | INDEP %4 | PLAYERS: %5 | RESTART IN: %6:%7", round diag_fps, west countSide playableUnits, east countSide playableUnits, indep countSide playableUnits, count playableUnits, _hours, _minutes, _counter];
	}; 
};