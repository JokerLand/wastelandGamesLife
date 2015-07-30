// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: buyGuns.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, [KoS] His_Shadow, AgentRev
//	@file Created: 20/11/2012 05:13
//	@file Args: [int (0 = buy to player 1 = buy to crate)]

if (!isNil "storePurchaseHandle" && {typeName storePurchaseHandle == "SCRIPT"} && {!scriptDone storePurchaseHandle}) exitWith {hint "Veuillez patienter, votre précédent achat est en traitement"};

#include "dialog\gunstoreDefines.sqf";

#define PURCHASED_CRATE_TYPE_AMMO 60
#define PURCHASED_CRATE_TYPE_WEAPON 61

#define GET_DISPLAY (findDisplay balca_debug_VC_IDD)
#define GET_CTRL(a) (GET_DISPLAY displayCtrl ##a)
#define GET_SELECTED_DATA(a) ([##a] call {_idc = _this select 0;_selection = (lbSelection GET_CTRL(_idc) select 0);if (isNil {_selection}) then {_selection = 0};(GET_CTRL(_idc) lbData _selection)})
#define KINDOF_ARRAY(a,b) [##a,##b] call {_veh = _this select 0;_types = _this select 1;_res = false; {if (_veh isKindOf _x) exitwith { _res = true };} forEach _types;_res}

storePurchaseHandle = _this spawn
{
	disableSerialization;

	private ["_name", "_switch", "_price", "_dialog", "_ammoList", "_playerMoneyText", "_playerMoney", "_itemIndex", "_itemText", "_itemData", "_class", "_name", "_mag", "_type", "_backpack", "_gunsList", "_weapon", "_successHint", "_requestKey"];

	//Initialize Values
	_switch = _this select 0;
	_successHint = true;

	// Grab access to the controls
	_dialog = findDisplay gunshop_DIALOG;
	_gunsList = _dialog displayCtrl gunshop_gun_list;
	_playerMoneyText = _dialog displayCtrl gunshop_money;
	_playerMoney = player getVariable ["cmoney", 0];

	_itemIndex = lbCurSel gunshop_gun_list;
	_itemText = _gunsList lbText _itemIndex;
	_itemData = _gunsList lbData _itemIndex;

	_showInsufficientFundsError =
	{
		_itemText = _this select 0;
		hint parseText format ["Argent insuffisant pour<br/>""%1""", _itemText];
		playSound "FD_CP_Not_Clear_F";
		_price = -1;
	};

	_showInsufficientSpaceError =
	{
		_itemText = _this select 0;
		hint parseText format ["Place insuffisante pour<br/>""%1""", _itemText];
		playSound "FD_CP_Not_Clear_F";
		_price = -1;
	};

	_showItemSpawnTimeoutError =
	{
		_itemText = _this select 0;
		hint parseText format ["<t color='#ffff00'>Une erreure inconnue s'est produite.</t><br/>L'achat de ""%1"" à été annulé.", _itemText];
		playSound "FD_CP_Not_Clear_F";
		_price = -1;
	};

	_showItemSpawnedOutsideMessage =
	{
		_itemText = _this select 0;
		hint format ["""%1"" à été livré dehors, devant le magasin.", _itemText];
		playSound "FD_Finish_F";
		_successHint = false;
	};

	_showAlreadyHaveTypeMessage =
	{
		_itemText = _this select 0;
		hint format ["Votre inventaire est plein, où vous avez déja une arme de ce type. Veuillez la désequiper avant d'acheter ""%1""", _itemText];
		playSound "FD_CP_Not_Clear_F";
		_price = -1;
	};

	switch (_switch) do
	{
		//Buy To Player
		case 0:
		{
			if (isNil "_price") then
			{
				{
					if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
					{
						_class = _x select 1;
						_price = _x select 2;
						_weapon = configFile >> "CfgWeapons" >> _class;

						// Ensure the player has enough money
						if (_price > _playerMoney) exitWith
						{
							[_itemText] call _showInsufficientFundsError;
						};

						if ((!([_class, 1] call isWeaponType) || primaryWeapon player == "") &&
							{!([_class, 2] call isWeaponType) || handgunWeapon player == ""} &&
							{!([_class, 4] call isWeaponType) || secondaryWeapon player == ""}) then
						{
							player addWeapon _class;
						}
						else
						{
							if !([player, _class] call addWeaponInventory) then
							{
								[_itemText] call _showInsufficientSpaceError;
							};
						};
					};
				} forEach (call allGunStoreFirearms);
			};

			if (isNil "_price") then
			{
				{
					if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
					{
						_class = _x select 1;
						_price = _x select 2;

						// Ensure the player has enough money
						if (_price > _playerMoney) exitWith
						{
							[_itemText] call _showInsufficientFundsError;
						};

						if ([player, _class] call fn_fitsInventory) then
						{
							[player, _class] call fn_forceAddItem;
						}
						else
						{
							[_itemText] call _showInsufficientSpaceError;
						};
					}
				} forEach (call throwputArray);
			};

			if (isNil "_price") then
			{
				{
					if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
					{
						_class = _x select 1;
						_price = _x select 2;

						// Ensure the player has enough money
						if (_price > _playerMoney) exitWith
						{
							[_itemText] call _showInsufficientFundsError;
						};

						switch (_x select 3) do
						{
							case "item":
							{
								if ([player, _class] call fn_fitsInventory) then
								{
									[player, _class] call fn_forceAddItem;
								}
								else
								{
									[_itemText] call _showInsufficientSpaceError;
								};
							};
						};
					};
				} forEach (call accessoriesArray);
			};

			if (isNil "_price") then
			{
				{
					if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
					{
						_class = _x select 1;
						_price = _x select 2;

						// Ensure the player has enough money
						if (_price > _playerMoney) exitWith
						{
							[_itemText] call _showInsufficientFundsError;
						};

						removeBackpack player;
						player addBackpack _class;
					};
				} forEach (call backpackArray);
			};

			if (isNil "_price") then
			{
				{
					// Exact copy of genObjectsArray call in buyItems.sqf
					if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
					{
						_class = _x select 1;
						_price = _x select 2;

						// Ensure the player has enough money
						if (_price > _playerMoney) exitWith
						{
							[_itemText] call _showInsufficientFundsError;
						};

						_requestKey = call A3W_fnc_generateKey;
						call requestStoreObject;
					};
				} forEach (call staticGunsArray);
			};
		};
	};

	if (!isNil "_price" && {_price > -1}) then
	{
		_playerMoney = player getVariable ["cmoney", 0];

		// Re-check for money after purchase
		if (_price > _playerMoney) then
		{
			if (!isNil "_requestKey" && {!isNil _requestKey}) then
			{
				deleteVehicle objectFromNetId (missionNamespace getVariable _requestKey);
			};

			[_itemText] call _showInsufficientFundsError;
		}
		else
		{
			player setVariable ["cmoney", _playerMoney - _price, true];
			_playerMoneyText ctrlSetText format ["Argent: $%1", [player getVariable ["cmoney", 0]] call fn_numbersText];
			if (_successHint) then { hint "Achat effectué !" };
			playSound "FD_Finish_F";
		};
	};

	if (!isNil "_requestKey" && {!isNil _requestKey}) then
	{
		missionNamespace setVariable [_requestKey, nil];
	};

	sleep 0.25; // double-click protection
};

if (typeName storePurchaseHandle == "SCRIPT") then
{
	private "_storePurchaseHandle";
	_storePurchaseHandle = storePurchaseHandle;
	waitUntil {scriptDone _storePurchaseHandle};
};

storePurchaseHandle = nil;
