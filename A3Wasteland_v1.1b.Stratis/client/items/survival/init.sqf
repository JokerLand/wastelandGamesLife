// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//@file Version: 1.0
//@file Name: init.sqf
//@file Author: MercyfulFate
//@file Created: 21/7/2013 16:00
//@file Description: Initialize Wasteland's Survival Items
//@file Arguments: The path to the directory holding this file.

//_this should be the path to this folder
mf_items_survival_eat = [_this, "eat.sqf"] call mf_compile;
mf_items_survival_drink = [_this, "drink.sqf"] call mf_compile;
_energy_drink = [_this, "energy_drink.sqf"] call mf_compile;
//mf_items_survival_cook = [_this, "cook.sqf"] call mf_compile;
//mf_items_survival_cook = [_this, "cookable.sqf"] call mf_compile;

//MF_ITEMS_COOKED_MEAT = "cooked_meat";
//MF_ITEMS_RAW_MEAT = "raw_meat";
MF_ITEMS_CANNED_FOOD = "cannedfood";
MF_ITEMS_WATER = "water";
MF_ITEMS_ENERGY_DRINK = "energydrink";

//[MF_ITEMS_RAW_MEAT, "Raw Meat", {[MF_ITEMS_RAW_MEAT, MF_ITEMS_COOKED_MEAT] call mf_items_survival_cook}, "Land_BakedBeans_F", "", 5];
//[MF_ITEMS_COOKED_MEAT, "Raw Meat", {50 call mf_items_survival_eat}, "Land_BakedBeans_F", "", 5];
[MF_ITEMS_CANNED_FOOD, "Boîte de Conserve", {50 call mf_items_survival_eat}, "Land_BakedBeans_F","client\icons\cannedfood.paa", 5] call mf_inventory_create;
[MF_ITEMS_WATER, "Bouteille d'Eau", {50 call mf_items_survival_drink}, "Land_BottlePlastic_V2_F","client\icons\waterbottle.paa", 5] call mf_inventory_create;
[MF_ITEMS_ENERGY_DRINK, "Boisson Energétique", _energy_drink, "Land_Can_V3_F","client\icons\energydrink.paa", 2] call mf_inventory_create;

private ["_label", "_code", "_condition"];

// Take Food from Sacks

_label = "<img image='client\icons\cannedfood.paa'/> Prendre Boîte de Conserve";
_condition = "{_x getVariable ['food', 0] >= 1} count nearestObjects [player, ['Land_Sacks_goods_F'], 3] > 0 && !(MF_ITEMS_CANNED_FOOD call mf_inventory_is_full)";
_code =
{
	_objs = nearestObjects [player, ["Land_Sacks_goods_F"], 5];

	if (count _objs > 0) then
	{
		player playMove ([player, "AmovMstpDnon_AinvMstpDnon", "putdown"] call getFullMove);

		_obj = _objs select 0;
		_obj setVariable ["food", (_obj getVariable ["food", 0]) - 1, true];
		[MF_ITEMS_CANNED_FOOD, 1] call mf_inventory_add;

		if (_obj getVariable "food" < 1) then
		{
			_obj spawn
			{
				_this setDamage 1;
				sleep 5;
				deleteVehicle _this;
			};

			["Vous avez pris de la nourriture.\nLe sac est maintenant vide", 5] call mf_notify_client;
		}
		else
		{
			[format ["Vous avez pris de la nourriture.\n(Nourriture restante: %1)", _obj getVariable "food"], 5] call mf_notify_client;
		};
	};
};

["take-food-sack", [_label, _code, [], 0, true, true, "", _condition]] call mf_player_actions_set;

// Take Water from White water container

_label = "<img image='client\icons\water.paa'/> Remplir Bouteille d'Eau";
_condition = "{_x getVariable ['water', 0] >= 1} count nearestObjects [player, ['Land_BarrelWater_F'], 3] > 0 && !(MF_ITEMS_WATER call mf_inventory_is_full)";
_code =
{
	_objs = nearestObjects [player, ["Land_BarrelWater_F"], 5];

	if (count _objs > 0) then
	{
		player playMove ([player, "AmovMstpDnon_AinvMstpDnon", "putdown"] call getFullMove);

		_obj = _objs select 0;
		_obj setVariable ["water", (_obj getVariable ["water", 0]) - 1, true];
		[MF_ITEMS_WATER, 1] call mf_inventory_add;

		if (_obj getVariable "water" < 1) then
		{
			_obj spawn
			{
				_pos = getPosATL _this;
				_vecDir = vectorDir _this;
				_vecUp = vectorUp _this;
				deleteVehicle _this;

				_obj = createVehicle ["Land_BarrelEmpty_F", _pos, [], 0, "CAN_COLLIDE"];
				_obj setVectorDirAndUp [_vecDir, _vecUp];
				_obj setDamage 1;
				sleep 5;
				deleteVehicle _obj;
			};

			["Vous avez rempli une bouteille d'eau.\nLe baril est maintenant vide", 5] call mf_notify_client;
		}
		else
		{
			[format ["Vous avez rempli une bouteille d'eau.\n(Eau restante: %1)", _obj getVariable "water"], 5] call mf_notify_client;
		};
	};
};

["take-water-barrel", [_label, _code, [], 0, true, true, "", _condition]] call mf_player_actions_set;

// Take Water from Well

_label = "<img image='client\icons\water.paa'/> Remplir Bouteille d'Eau";
_condition = "count nearestObjects [player, ['Land_StallWater_F', 'Land_Water_source_F'], 3] > 0 && !(MF_ITEMS_WATER call mf_inventory_is_full)";
_code =
{
	player playMove ([player, "AmovMstpDnon_AinvMstpDnon", "putdown"] call getFullMove);

	[MF_ITEMS_WATER, 1] call mf_inventory_add;
	["Vous avez rempli une bouteille d'eau.", 5] call mf_notify_client;
};

["take-water-well", [_label, _code, [], 0, true, true, "", _condition]] call mf_player_actions_set;
