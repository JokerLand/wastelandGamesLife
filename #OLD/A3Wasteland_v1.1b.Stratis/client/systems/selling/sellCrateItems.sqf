// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: sellCrateItems.sqf
//	@file Author: AgentRev
//	@file Created: 31/12/2013 22:12

#define CONTAINER_SELL_PRICE 50 // price for the crate itself (do not price higher than "Empty Ammo Crate" from general store)

#include "sellIncludesStart.sqf";

storeSellingHandle = _this spawn
{
	_params = [_this, 3, [], [[]]] call BIS_fnc_param;
	_storeSellBox = [_params, 0, false, [false]] call BIS_fnc_param;
	_forceSell = [_params, 1, false, [false]] call BIS_fnc_param;
	_deleteObject = [_params, 2, false, [false]] call BIS_fnc_param;

	_crate = if (_storeSellBox) then
	{
		[_this, 0, objNull, [objNull]] call BIS_fnc_param
	}
	else
	{
		missionNamespace getVariable ["R3F_LOG_joueur_deplace_objet", objNull]
	};

	_sellValue = 0;
	_originalCargo = CARGO_STRING(_crate);

	// Get all the items
	_allCrateItems = _crate call getSellPriceList;

	_objClass = typeOf _crate;
	_objName = getText (configFile >> "CfgVehicles" >> _objClass >> "displayName");

	// Include crate in item list if it's to be deleted
	if (_deleteObject) then
	{
		_allCrateItems = [[_objClass, 1, _objName, CONTAINER_SELL_PRICE]] + _allCrateItems;
	};

	if (count _allCrateItems == 0) exitWith
	{
		if (!_forceSell) then
		{
			playSound "FD_CP_Not_Clear_F";
			[format ['"%1" ne contient pas d items valides à vendre.', _objName], "Error"] call BIS_fnc_guiMessage;
		};
	};

	// Calculate total value
	{
		if (count _x > 3) then
		{
			_sellValue = _sellValue + (_x select 3);
		};
	} forEach _allCrateItems;

	if (_forceSell) then
	{
		clearBackpackCargoGlobal _crate;
		clearMagazineCargoGlobal _crate;
		clearWeaponCargoGlobal _crate;
		clearItemCargoGlobal _crate;

		player setVariable ["cmoney", (player getVariable ["cmoney", 0]) + _sellValue, true];
		hint format [format ['Le contenu de "%1" à été vendu pour $%2', _objName, _sellValue]];
		playSound "FD_Finish_F";
	}
	else
	{
		// Add total sell value to confirm message
		_confirmMsg = format ["Vous obtiendrez $%1 pour:<br/>", [_sellValue] call fn_numbersText];

		// Add item quantities and names to confirm message
		{
			_item = _x select 0;
			_itemQty = _x select 1;

			if (_itemQty > 0 && {count _x > 2}) then
			{
				_itemName = _x select 2;
				_confirmMsg = _confirmMsg + format ["<br/><t font='EtelkaMonospaceProBold'>%1</t> x %2%3", _itemQty, _itemName, if (PRICE_DEBUGGING) then { format [" ($%1)", [_x select 3] call fn_numbersText] } else { "" }];
			};
		} forEach _allCrateItems;

		// Display confirmation
		if ([parseText _confirmMsg, "Confirmer", "Vendre", true] call BIS_fnc_guiMessage) then
		{
			// Check if somebody else manipulated the cargo since the start
			if (CARGO_STRING(_crate) == _originalCargo) then
			{
				// Have to spawn clearing commands due to mysterious game crash...
				_clearing = _crate spawn
				{
					clearBackpackCargoGlobal _this;
					clearMagazineCargoGlobal _this;
					clearWeaponCargoGlobal _this;
					clearItemCargoGlobal _this;
				};

				waitUntil {scriptDone _clearing};

				if (_deleteObject) then
				{
					if (_crate getVariable ["R3F_LOG_est_deplace_par", objNull] == player) then
					{
						[_crate, player, -1, false] execVM "addons\R3F_ARTY_AND_LOG\R3F_LOG\objet_deplacable\relacher.sqf";
						waitUntil {_crate getVariable ["R3F_LOG_est_deplace_par", objNull] != player};
					};

					if (isNull (_crate getVariable ["R3F_LOG_est_deplace_par", objNull])) then
					{
						deleteVehicle _crate;
					};
				};

				player setVariable ["cmoney", (player getVariable ["cmoney", 0]) + _sellValue, true];

				_hintMsg = if (_deleteObject) then { 'Vous avez vendu "%1" pour $%2' } else { 'Vous avez vendu le contenu de "%1" pour $%2' };
				hint format [_hintMsg, _objName, _sellValue];
				playSound "FD_Finish_F";
			}
			else
			{
				playSound "FD_CP_Not_Clear_F";
				[format ['Le contenu de "%1" à été modifié, veuillez recommencer le processus de vente.', _objName], "Error"] call BIS_fnc_guiMessage;
			};
		};
	};
};

#include "sellIncludesEnd.sqf";
