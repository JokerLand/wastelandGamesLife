// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//@file Version: 1.0
//@file Name: syphon.sqf
//@file Author: MercyfulFate
//@file Created: 21/7/2013 16:00
//@file Description: Syphon fuel from the closest Vehicle
//@file Argument: [player, player, _actionid, []] the standard "called by an action" values

#define DURATION 15 // seconds
#define ANIMATION "AinvPknlMstpSlayWrflDnon_medic"
#define ERR_IN_VEHICLE "Siphonnage échoué! Vous ne pouvez pas faire ça depuis un véhicule"
#define ERR_TOO_FAR_AWAY "Siphonnage échoué! Vous êtes parti trop loin du véhicule"
#define ERR_CANCELLED "Siphonnage annulé"

private ["_vehicle", "_error"];
_vehicle = call mf_jerrycan_nearest_vehicle;
_error = [_vehicle] call mf_jerrycan_can_syphon;
if (_error != "") exitWith {[_error, 5] call mf_notify_client; false;};

_checks = {
	private ["_progress","_vehicle","_failed", "_text"];
	_progress = _this select 0;
	_vehicle = _this select 1;
	_text = "";
	_failed = true;
	switch (true) do {
		case (!alive player): {}; //player is dead, no need for a notification
		case (vehicle player != player): {_text = ERR_IN_VEHICLE};
		case (player distance _vehicle > (sizeOf typeOf _vehicle / 3) max 2): {_text = ERR_TOO_FAR_AWAY};
		case (doCancelAction): {_text = ERR_CANCELLED; doCancelAction = false;};
		default {
			_text = format["Siphonnage %1%2 terminé", round(100 * _progress), "%"];
			_failed = false;
	    };
	};
	[_failed, _text];
};
_success = [DURATION, ANIMATION, _checks, [_vehicle]] call a3w_actions_start;
if (_success) then {
	// the fuel qty is handled by mf_remote_refuel.
	// will execute locally if _currVehicle is local
	[[netId _vehicle], "mf_remote_syphon", _vehicle] call A3W_fnc_MP;
	[MF_ITEMS_JERRYCAN_EMPTY, 1] call mf_inventory_remove;
	[MF_ITEMS_JERRYCAN_FULL, 1] call mf_inventory_add;
	["Siphonnage terminé !", 5] call mf_notify_client;
};
false;
