// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: confirmSuicide.sqf
//	@file Author: AgentRev

if (!alive player) exitWith {};

if (["Êtes vous sûr de vouloir vous suicider ?", "Confirmer", "Oui", true] call BIS_fnc_guiMessage) then
{
	player allowDamage true;
	player setDamage 1;
};
