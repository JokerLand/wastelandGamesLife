//	@file Name: functions.sqf
//	@file Author: IvanMMM, micovery, AgentRev

private ["_perm", "_uav"];
_perm = ["A3W_uavControl", "side"] call getPublicVar;

if (_perm == "side") exitWith {};

while {true} do
{
	waitUntil {sleep 0.1; _uav = getConnectedUAV player; !isNull _uav};

	// ignore remote designators
	if !(_uav isKindOf "StaticWeapon") then
	{
		_ownerUID = _uav getVariable ["ownerUID", ""];

		if (_ownerUID == "") exitWith {}; // UAV not owned by anyone
		if (getPlayerUID player == _ownerUID) exitWith {};
		if (_perm == "group" && {{getPlayerUID _x == _ownerUID} count units player > 0}) exitWith {};

		player connectTerminalToUAV objNull;
		playSound "FD_CP_Not_Clear_F";
		["Vous ne pouvez pas connecter ce véhicule inconnu.", 5] call mf_notify_client;
	};

	waitUntil {sleep 0.1; _uav != getConnectedUAV player};
};
