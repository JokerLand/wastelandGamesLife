// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//@file Version: 1.0
//@file Name: drink.sqf
//@file Author: MercyfulFate
//@file Created: 21/7/2013 16:00
//@file Description: Drink, and replenish your stamina

#define ERR_CANCELLED "Vous avez arrêté de boire";
#define ANIMATION "AinvPknlMstpSnonWnonDnon_healed_1"
private ["_checks", "_hasFailed"];
_hasFailed = {
	private ["_progress","_failed", "_text"];
	_progress = _this select 0;
	_text = "";
	_failed = true;
	switch (true) do {
		case (!alive player) : {}; // player is dead, not need for a error message
		case (doCancelAction): {doCancelAction = false; _text = ERR_CANCELLED;};
		default {
			_failed = false;
			_text = format["Vous avez bu %1%2", round(100*_progress), "%"];
		};
	};
	[_failed, _text];
};

_success = [5, ANIMATION, _hasFailed, []] call a3w_actions_start;
if (_success) then
{
	[] spawn
	{
		if (["A3W_unlimitedStamina"] call isConfigOn) then
		{
			["La boisson énergetique n'a eu aucun effet sur votre stamina surhumaine.", 5] call mf_notify_client;
		}
		else
		{
			player enableFatigue false;
			player setVariable ["energy_drink_active", true];
			["Vous avez une stamina illimitée pendant 5 minutes", 5] call mf_notify_client;

			sleep (5*60);

			player enableFatigue true;
			player setVariable ["energy_drink_active", false];
			["Les effets de la boisson énergetique se dissipent", 5] call mf_notify_client;
		};
	};
};

_success
