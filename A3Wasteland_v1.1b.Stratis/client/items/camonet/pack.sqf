// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//@file Version: 1.0
//@file Name: pack.sqf
//@file Author: MercyfulFate
//@file Created: 23/7/2013 16:00
//@file Description: Pack the nearest Camouflage Netting
//@file Argument: [player, player, _action, []] the standard "called by an action" values

#include "mutex.sqf"
#define ANIM "AinvPknlMstpSlayWrflDnon_medic"
#define DURATION 15
#define ERR_TOO_FAR_AWAY "Repliage du Filet de Camouflage échoué. Vous êtes parti trop loin"
#define ERR_ALREADY_TAKEN "Repliage du Filet de Camouflage échoué. Il à déja été replié."
#define ERR_IN_VEHICLE "Repliage du Filet de Camouflage échoué. Vous ne pouvez pas faire ça depuis un véhicule."
#define ERR_CANCELLED "Repliage du Filet de Camouflage annulé"

private ["_beacon", "_error", "_hasFailed", "_success"];
_netting = [] call mf_items_camo_net_nearest;
_error = [_netting] call mf_items_camo_net_can_pack;
if (_error != "") exitWith {[_error, 5] call mf_notify_client};

_hasFailed = {
	private ["_progress", "_netting", "_caller", "_failed", "_text"];
	_progress = _this select 0;
	_netting = _this select 1;
	_text = "";
	_failed = true;
	switch (true) do {
		case (!alive player): {}; // player dead, no error msg needed
		case (isNull _netting): {_text = ERR_ALREADY_TAKEN}; //someone has already taken it.
		case (vehicle player != player): {_text = ERR_IN_VEHICLE};
		case (player distance _netting > 5): {_text = ERR_TOO_FAR_AWAY};
		case (doCancelAction): {doCancelAction = false; _text = ERR_CANCELLED};
		default {
			_text = format["Filet de Camouflage %1%2 replié", round(_progress*100), "%"];
			_failed = false;
		};
	};
	[_failed, _text];
};

MUTEX_LOCK_OR_FAIL;
_success =  [DURATION, ANIM, _hasFailed, [_netting]] call a3w_actions_start;
MUTEX_UNLOCK;

if (_success) then {
	deleteVehicle _netting;
	[MF_ITEMS_CAMO_NET, 1] call mf_inventory_add;
	["Vous avez replié le filet de camouflage", 5] call mf_notify_client;
};
