// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: can_access.sqf
//	@file Author: AgentRev
//	@file Function: mf_items_atm_can_access

#define ERR_IN_VEHICLE "Impossible de faire ça depuis un véhicule"
#define ERR_TOO_FAR "Vous êtes trop loin"

private ["_atm", "_error"];

_atm = call mf_items_atm_nearest;
_error = "failed";

switch (true) do
{
	case (isNull _atm): {};
	case (!alive player): {};

	case (player distance _atm > 3): {_error = ERR_TOO_FAR};
	case (vehicle player != player): {_error = ERR_IN_VEHICLE};

	default {_error = ""};
};

_error
