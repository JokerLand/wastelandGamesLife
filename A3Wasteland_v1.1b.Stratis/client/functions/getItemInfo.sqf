// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: getItemInfo.sqf
//	@file Author: AgentRev
//	@file Created: 12/10/2013 22:45
//	@file Args:

private ["_itemText", "_itemData", "_price", "_description", "_showAmmo", "_itemEntry", "_parentCfg", "_itemType", "_weapon"];

_itemText = _this select 0;
_itemData = _this select 1;

_parentCfg = "";
_price = 0;
_description = "";
_showAmmo = false;

if (isNil "_itemEntry") then
{
	{
		if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
		{
			_itemEntry = _x;
			_parentCfg = "CfgWeapons";
			_showAmmo = true;
		}
	} forEach (call allGunStoreFirearms);
};

if (isNil "_itemEntry") then
{
	{
		if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
		{
			_itemEntry = _x;
			_parentCfg = "CfgMagazines";
		};
	} forEach (call throwputArray);
};

if (isNil "_itemEntry") then
{
	{
		if (!isNil "_itemEntry") exitWith {};

		{
			if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
			{
				_itemEntry = _x;
				_itemType = _x select 3;

				switch (true) do
				{
					case (_itemType == "mag"):                            { _parentCfg = "CfgMagazines" };
					case (_itemType == "backpack"):                       { _parentCfg = "CfgVehicles" };
					// case (["crate", _itemType] call fn_findString != -1): { _parentCfg = "CfgVehicles" };
					default                                               { _parentCfg = "CfgWeapons" };
				};
			};
		} forEach (call _x)
	} forEach [accessoriesArray, genItemArray];
};

if (isNil "_itemEntry") then
{
	{
		if (!isNil "_itemEntry") exitWith {};

		{
			if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
			{
				_itemEntry = _x;
				_parentCfg = "CfgWeapons";
			};
		} forEach (call _x);
	} forEach [headArray, uniformArray, vestArray];
};

if (isNil "_itemEntry") then
{
	{
		if (!isNil "_itemEntry") exitWith {};

		{
			if (_itemText == _x select 0 && _itemData == _x select 1) exitWith
			{
				_itemEntry = _x;
				_parentCfg = "CfgVehicles";
			};
		} forEach (call _x);
	} forEach [backpackArray, genObjectsArray, staticGunsArray];
};

if (!isNil "_itemEntry") then
{
	_itemType = _itemEntry select 1;
	_price = _itemEntry select 2;
	_weapon = configFile >> _parentCfg >> _itemType;

	// Set custom name and/or description
	if (count _itemEntry > 3) then
	{
		switch (_itemEntry select 3) do
		{
			case "backpack":
			{
				_weapon = (configFile >> "CfgVehicles" >> _itemType);

				switch (true) do
				{
					case (_itemType isKindOf "B_Parachute"):
					{
						//_name = getText (_weapon >> "displayName");
						_description = "Le companion parfait pour les pilotes en devenir !<br/>Usage unique.";
					};
					case (["_UAV_01_backpack_", _itemType] call fn_findString != -1):
					{
						private "_uavType";

						switch (playerSide) do
						{
							case BLUFOR: { _uavType = "B_UAV_01_F" };
							case OPFOR:  { _uavType = "O_UAV_01_F" };
							default      { _uavType = "I_UAV_01_F" };
						};

						_weapon = configFile >> "CfgVehicles" >> _uavType;

						//_name = getText (_weapon >> "displayName") + " UAV";
						_description = "Quadrocoptère télécommandé pour espionner vos voisins, livré dans son emballage sac à dos.<br/>Terminal Drône vendu séparément. Pas avant 8 ans.";
					};
					case (["_Static_Designator_", _itemType] call fn_findString != -1):
					{
						_description = "Désignateur laser radiocommandé.<br/>Terminal Drône vendu séparément.";
					};
					default
					{
						//_name = _itemText;
						_description = [_itemType, "backpack"] call gearProperties;
					};
				};
			};
			case "uni":
			{
				switch (true) do
				{
					case (["Uniforme par défaut", _itemText] call fn_findString != -1):
					{
						//_name = _itemText;
						_description = "Au cas où vous perdriez vos vêtements";
					};
					case (["_GhillieSuit", _itemType] call fn_findString != -1):
					{
						//_name = _itemText;
						_description = "Déguisez vous en monstre des marais";
					};
					case (["_Wetsuit", _itemType] call fn_findString != -1):
					{
						//_name = _itemText;
						_description = "Permet de nager plus rapidement<br/>Requis pour tirer avec la SDAR sous l'eau";
					};
					default
					{
						_description = getText (_weapon >> "descriptionShort");
					};
				};

				if (_description != "") then
				{
					_description = _description + "<br/>";
				};

				_description = _description + ([_itemType, "uniform"] call gearProperties);
			};
			case "vest":
			{
				if (["_Rebreather", _itemType] call fn_findString != -1) then
				{
					_description = "Recycleur d'air";
				};

				if (_description != "") then
				{
					_description = _description + "<br/>";
				};

				_description = _description + ([_itemType, "vest"] call gearProperties);

				if (_price < 0) then
				{
					_price = [_itemType] call getCapacity;
				};
			};
			case "hat":
			{
				_description = [_itemType, "headgear"] call gearProperties;
			};
			case "gogg":
			{
				_weapon = configFile >> "CfgGlasses" >> _itemType;

				if (_itemType == "G_Diving") then
				{
					_description = "Permet de voir sous l'eau";
				};
			};
			default
			{
				switch (true) do
				{
					case (["_UavTerminal", _itemType] call fn_findString != -1):
					{
						//_name = getText (_weapon >> "displayName");
						_description = getText (_weapon >> "descriptionShort") + "<br/>Assignez sur le slot GPS.";
					};
				};
			};
		};
	};
};

if (isNil "_itemEntry") then
{
	{
		if (_itemData == _x select 1) exitWith
		{
			_itemEntry = _x;
			_description = _x select 2;
			_price = _x select 4;
		};
	} forEach (call customPlayerItems);
};

if (_description == "" && {!isNil "_weapon"} && {isClass _weapon}) then
{
	_description = getText (_weapon >> "descriptionShort");
};

// Return
[_parentCfg, _price, _description, _showAmmo]
