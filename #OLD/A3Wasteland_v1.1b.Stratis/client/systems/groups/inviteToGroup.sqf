// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: inviteToGroup.sqf
//	@file Author: [404] Deadbeat
//	@file Created: 20/11/2012 05:19

if(player != leader group player) exitWith {player globalChat format["Vous n'êtes pas le leadeur, et ne pouvez pas inviter d'autres joueurs"];};

#define groupManagementDialog 55510
#define groupManagementPlayerList 55511

disableSerialization;

private["_dialog","_playerListBox","_groupInvite","_target","_index","_playerData","_check","_unitCount","_hasInvite"];

_dialog = findDisplay groupManagementDialog;
_playerListBox = _dialog displayCtrl groupManagementPlayerList;

_index = lbCurSel _playerListBox;
_playerData = _playerListBox lbData _index;
_hasInvite = false;

//Check selected data is valid
{ if (getPlayerUID _x == _playerData) exitWith { _target = _x } } forEach (call allPlayers);

diag_log "Invite to group: Before the checks";

//Checks
if(isNil "_target") exitWith {player globalChat "Vous devez d'abord sélectionner quelqu'un à inviter"};
if(_target == player) exitWith {player globalChat "Vous ne pouvez pas vous inviter vous même"};
if((count units group _target) > 1) exitWith {player globalChat "Ce joueur est déja dans un groupe"};

{ if (_x select 1 == getPlayerUID _target) then { _hasInvite = true } } forEach currentInvites;
if(_hasInvite) exitWith {player globalChat "Ce joueur à déja une invitation en attente"};

diag_log "Invite to group: After the checks";

//currentInvites pushBack [getPlayerUID player, getPlayerUID _target];
//publicVariable "currentInvites";

pvar_processGroupInvite = ["send", player, _target];
publicVariableServer "pvar_processGroupInvite";

//[format ["You have been invited to join %1's group", name player], "A3W_fnc_titleTextMessage", _target, false] call A3W_fnc_MP;

player globalChat format["Vous avez invité %1 à rejoindre le groupe", name _target];

player setVariable ["currentGroupRestore", group player, true];
player setVariable ["currentGroupIsLeader", true, true];
