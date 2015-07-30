// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//@file Version: 1.0
//@file Name: can_syphon.sqf
//@file Author: MercyfulFate
//@file Created: 21/7/2013 16:00
//@file Description: Check if you can syphon from the nearest vehicle
//@file Argument: [_vehicle] the vehicle to test
//@file Argument: [] automatically find the nearest vehicle

#define ERR_NO_VEHICLE "Vous n'êtes pas assez proche d'un véhicule pour le siphonner"
#define ERR_IN_VEHICLE "Vous ne pouvez pas faire ça depuis un véhicule."
#define ERR_EMPTY "Ce véhicule n'a pas assez d'essence"
#define ERR_NO_JERRYCAN "Vous n'avez pas de jerrycan d'essence vide"
#define ERR_NO_SYPHON "Vous n'avez pas de tuyau de siphonnage"
#define ERR_VEHICLE_LOCKED "Le véhicule est verrouillé / neutralisé"
#define ITEM_COUNT(ITEMID) ITEMID call mf_inventory_count
private ["_vehicle", "_error"];
_vehicle = objNull;
if (count _this == 0) then { // if array empty
	_vehicle = call mf_jerrycan_nearest_vehicle;
} else {
	_vehicle = _this select 0;
};

_error = "";
switch (true) do {
	case (isNull _vehicle): {_error = ERR_NO_VEHICLE};
	case (vehicle player != player):{_error = ERR_IN_VEHICLE};
	case (player distance _vehicle > (sizeOf typeOf _vehicle / 3) max 2): {_error = ERR_NO_VEHICLE};
	case (locked _vehicle > 1): {_error = ERR_VEHICLE_LOCKED};
	case (ITEM_COUNT(MF_ITEMS_JERRYCAN_EMPTY) <= 0): {_error = ERR_NO_JERRYCAN};
	case (ITEM_COUNT(MF_ITEMS_SYPHON_HOSE) <= 0): {_error = ERR_NO_SYPHON};
	case (fuel _vehicle < ([_vehicle] call mf_jerrycan_fuel_amount)): {_error = ERR_EMPTY};
};
_error;
