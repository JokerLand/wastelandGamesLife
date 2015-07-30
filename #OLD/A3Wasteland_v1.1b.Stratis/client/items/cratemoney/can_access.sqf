// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: can_access.sqf
//	@file Author: AgentRev, MercifulFate
//	@file Function: mf_items_cratemoney_can_access

#define ERR_IN_VEHICLE "Vous ne pouvez pas faire ça depuis un véhicule"
#define ERR_TOO_FAR "Vous êtes trop loin"

private ["_crate", "_error"];

_crate = call mf_items_cratemoney_nearest;
_error = "failed";

switch (true) do
{
	case (isNull _crate): {};
	case (!alive player): {};
	case (_crate getVariable ["A3W_storeSellBox", false]): {};

	case (player distance _crate > 3): {_error = ERR_TOO_FAR};
	case (vehicle player != player): {_error = ERR_IN_VEHICLE};

	default {_error = ""};
};

_error
