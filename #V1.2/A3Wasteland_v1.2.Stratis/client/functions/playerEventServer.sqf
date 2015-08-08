// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: playerEventServer.sqf
//	@file Author: AgentRev

_type = [_this, 0, "", [""]] call BIS_fnc_param;

switch (toLower _type) do
{
	case "pickupmoney":
	{
		_amount = [_this, 1, 0, [0]] call BIS_fnc_param;

		if (_amount > 0) then
		{
			[format ["Vous avez ramassé $%1", [_amount] call fn_numbersText], 5] call mf_notify_client;

			if (["A3W_playerSaving"] call isConfigOn) then
			{
				[] spawn fn_savePlayerData;
			};
		};
	};

	case "transaction":
	{
		_amount = [_this, 1, 0, [0]] call BIS_fnc_param;

		if (_amount != 0) then
		{
			// temporarily offloaded to server due to negative wallet glitch
			//player setVariable ["cmoney", (player getVariable ["cmoney", 0]) - _amount, true];

			if (["A3W_playerSaving"] call isConfigOn) then
			{
				[] spawn fn_savePlayerData;
			};

			playSound "defaultNotification";
			call mf_items_warchest_refresh;
			call mf_items_cratemoney_refresh;
			true call mf_items_atm_refresh;
		}
		else
		{
			playSound "FD_CP_Not_Clear_F";
			["Transaction invalide, veuillez réessayer.", 5] call mf_notify_client;
		};
	};

	case "atmtransfersent":
	{
		_amount = [_this, 1, 0, [0]] call BIS_fnc_param;
		_name = [_this, 2, "", [""]] call BIS_fnc_param;

		if (_amount != 0) then
		{
			_message = if (isStreamFriendlyUIEnabled) then {
				"Vous avez fait un virement de $%1"
			} else {
				"Vous avez fait un virement de $%1 à %2"
			};

			playSound "defaultNotification";
			[format [_message, [_amount] call fn_numbersText, _name], 5] call mf_notify_client;
			true call mf_items_atm_refresh;
		}
		else
		{
			playSound "FD_CP_Not_Clear_F";
			["Transaction invalide, veuillez réessayer.", 5] call mf_notify_client;
			true call mf_items_atm_refresh;
		};
	};

	case "atmtransferreceived":
	{
		_amount = [_this, 1, 0, [0]] call BIS_fnc_param;
		_name = [_this, 2, "", [""]] call BIS_fnc_param;

		_message = if (isStreamFriendlyUIEnabled) then {
			"Vous avez reçu un virement de $%1"
		} else {
			"%2 vous à fait un virement de $%1 sur votre compte bancaire"
		};

		playSound "FD_Finish_F";
		[format [_message, [_amount] call fn_numbersText, _name], 5] call mf_notify_client;
		true call mf_items_atm_refresh;
	};
};
