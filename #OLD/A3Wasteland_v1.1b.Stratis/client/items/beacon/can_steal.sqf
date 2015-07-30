// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//@file Version: 1.0
//@file Name: can_steal.sqf
//@file Author: MercyfulFate
//@file Created: 21/7/2013 16:00
//@file Description: Check if is a spawn beacon that you can steal
//@file Argument: [_beacon] The (object that is a) beacon to check if its stealable
//@file Argument: [] automatically find the closest beacon to test.

#define ERR_NO_TARGET "Vous devez sélectionner un point de réapparition"
#define ERR_NOT_SPAWN_BEACON_TYPE "Ce n'est pas un point de réapparition (type invalide)"
#define ERR_IS_FRIENDLY "Vous ne pouvez pas voler un point de réapparition allié !"
#define ERR_TOO_FAR_AWAY "Vol du point de réapparition annulé ! Vous êtes trop loin pour faire ça."
private ["_beacon", "_error"];

if (count _this == 0) then {
	_beacon = [] call mf_items_spawn_beacon_nearest;
} else {
	_beacon = _this select 0;
};

_error = "failed";
switch (true) do {
	case (!alive player): {_error = " "}; // player is dead so no error msg is needed
	case (player distance _beacon > 5): {_error = ERR_TOO_FAR_AWAY};
	case (typeof _beacon != MF_ITEMS_SPAWN_BEACON_DEPLOYED_TYPE): {_error = ERR_NOT_SPAWN_BEACON_TYPE};
	case ([_beacon] call mf_items_spawn_beacon_can_use): {_error = ERR_IS_FRIENDLY};
	default {_error = ""};
};

_error;
