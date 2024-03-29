// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: salvage.sqf
//	@file Author: Wiking, AgentRev
//	@file Created: 27/07/2014 13:04

// Salvaging of vehicle wrecks

#define GET_ONE_TENTH_PRICE(PRICE) ((ceil (((PRICE) / 10) / 5)) * 5)

// Check if mutex lock is active.
if (mutexScriptInProgress) exitWith
{
	["You are already performing another action.", 5] call mf_notify_client;
};

private ["_vehicle", "_vehClass", "_checks", "_firstCheck", "_time", "_money", "_success"];

_vehicle = cursorTarget;
_vehClass = typeOf _vehicle;

if (isNull _vehicle) exitWith {};

_checks =
{
	private ["_progress", "_object", "_failed", "_text"];
	_progress = _this select 0;
	_object = _this select 1;
	_failed = true;

	switch (true) do
	{
		case (!alive player): { _text = "" };
		case (vehicle player != player): { _text = "Opération échouée! Vous ne pouvez pas faire ça depuis un véhicule." };
		case (player distance _object > (sizeOf typeOf _object / 3) max 2): { _text = "Opération écohuée! Vous êtes trop loin de l'objet" };

		case (isNull _object): { _text = "Cet objet n'existe plus" };
		case (alive _object || {alive _x} count crew _object > 0): { _text = "Opération échouée! Vous ne pouvez pas recycler cet objet" };
		case (!isNull (_object getVariable ["R3F_LOG_est_deplace_par", objNull])): { _text = "Opération échouée! Quelqu'un à déplacé cet objet" };
		case (!isNull (_object getVariable ["R3F_LOG_est_transporte_par", objNull])): { _text = "Opération échouée! Quelqu'un à chargé ou attaché cet objet" };
		case (doCancelAction): { doCancelAction = false; _text = "Salvaging cancelled" };
		default
		{
			_failed = false;
			_text = format ["Recyclage %1%2 terminé", floor (_progress * 100), "%"];
		};
	};

	[_failed, _text];
};

_firstCheck = [0, _vehicle] call _checks;

if (_firstCheck select 0) exitWith
{
	[_firstCheck select 1, 5] call mf_notify_client;
};

mutexScriptInProgress = true;

// Salvage time and default money reward according to vehicle type
switch (true) do
{
	case (_vehClass isKindOf "Plane_Base_F"): // Planes (UAV_02 is not in Plane_Base_F)
	{
		_time = 30;
		_money = 3000;
	};
	case (_vehClass isKindOf "Tank"): // Tanks & IFVs
	{
		_time = 30;
		_money = 2000;
	};
	case (_vehClass isKindOf "Helicopter_Base_F" && !(_vehClass isKindOf "UAV_01_base_F")): // Helicopters (except UAV_01)
	{
		_time = 25;
		_money = 1750;
	};
	case (_vehClass isKindOf "Wheeled_APC_F"): // Wheeled APCs
	{
		_time = 20;
		_money = 1500;
	};
	case (_vehClass isKindOf "Truck_F" && !(_vehClass isKindOf "Van_01_base_F")): // Trucks (except Vans)
	{
		_time = 20;
		_money = 1000;
	};
	case ({_vehClass isKindOf _x} count ["MRAP_01_base_F", "MRAP_02_base_F", "MRAP_03_base_F", "UAV_02_base_F"] > 0): // MRAPs and UAV_02
	{
		_time = 15;
		_money = 750;
	};
	case (_vehClass isKindOf "Boat_Armed_01_base_F"): // Speedboats
	{
		_time = 10;
		_money = 500;
	};
	case ({_vehClass isKindOf _x} count ["Quadbike_01_base_F", "Kart_01_Base_F", "Rubber_duck_base_F", "UAV_01_base_F"] > 0): // Quadbikes, karts, rubber boats, UAV_01
	{
		_time = 3;
		_money = 50;
	};
	default // Everything else
	{
		_time = 5;
		_money = 100;
	};
};

// Final money reward is decided from vehicle store price
{
	if (_x select 1 == _vehClass) exitWith
	{
		_money = GET_ONE_TENTH_PRICE(_x select 2);
	};
} forEach call allVehStoreVehicles;

mutexScriptInProgress = true;

_success = [_time, format ["AinvPknlMstpSlayW%1Dnon_medic", [player, true] call getMoveWeapon], _checks, [_vehicle]] call a3w_actions_start;

mutexScriptInProgress = false;

if (_success) then
{
	deleteVehicle _vehicle;
	player setVariable ["cmoney", (player getVariable ["cmoney", 0]) + _money, true];
	[format ["Vous avez obtenu $%1 du recyclage", [_money] call fn_numbersText], 5] call mf_notify_client;
};
