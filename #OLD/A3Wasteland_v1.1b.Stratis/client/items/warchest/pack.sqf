// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
#include "mutex.sqf"
#define ANIM "AinvPknlMstpSlayWrflDnon_medic"
#define DURATION MF_ITEMS_WARCHEST_PACK_DURATION
#define ERR_CANCELLED "Démontage du coffre annulé"
#define ERR_IN_VEHICLE "Démontage du coffre échoué: Vous ne pouvez pas faire ça depuis un véhicule."
#define ERR_TOO_FAR_AWAY "Démontage du coffre échoué: Vous êtes parti trop loin."
#define ERR_SOMEONE_ELSE "Démontage du coffre échoué: Quelqu'un l'a déja fait."
private ["_warchest", "_error", "_success"];
_warchest = [] call mf_items_warchest_nearest;
_error = [] call mf_items_warchest_can_pack;
if (_error != "") exitWith {[_error, 5] call mf_notify_client};

private "_hasFailed";
_hasFailed = {
	private ["_progress", "_warchest", "_failed", "_text"];
	_progress = _this select 0;
	_warchest = _this select 1;
	_text = "";
	_failed = true;
	switch (true) do {
		case (!alive player): {}; // player dead, no error msg needed
		case (vehicle player != player): {_text = ERR_IN_VEHICLE};
		case (isNull _warchest): {_text = ERR_SOMEONE_ELSE};
		case (player distance _warchest > 5): {_text = ERR_TOO_FAR_AWAY};
		case (doCancelAction): {doCancelAction = false; _text = ERR_CANCELLED};
		default {
			_text = format["Coffre %1%2 démonté", round(_progress*100), "%"];
			_failed = false;
		};
	};
	[_failed, _text];
};

private "_success";
_success =  [DURATION, ANIM, _hasFailed, [_warchest]] call a3w_actions_start;
MUTEX_UNLOCK;

if (_success) then {
	pvar_manualObjectDelete = [netId _warchest, _warchest getVariable "A3W_objectID"];
	publicVariableServer "pvar_manualObjectDelete";
	deleteVehicle _warchest;
	[MF_ITEMS_WARCHEST, 1] call mf_inventory_add;
	["Vous avez démonté le coffre", 5] call mf_notify_client;
};
