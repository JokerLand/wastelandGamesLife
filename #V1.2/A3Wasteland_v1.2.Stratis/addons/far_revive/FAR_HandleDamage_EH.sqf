// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: FAR_HandleDamage_EH.sqf
//	@file Author: Farooq, AgentRev

#include "FAR_defines.sqf"
#include "gui_defines.hpp"

//private ["_unit", "_selection", "_damage", "_source", "_dead", "_killerVehicle", "_oldDamage"];

_unit = _this select 0;
//_selection = _this select 1;
//_damage = _this select 2;
_source = _this select 3;
_ammo = _this select 4;

_criticalHit = (_selection in ["","body","head"]);
_dead = (_damage >= 1 && alive _unit && _criticalHit);

// Find suspects
if (((_dead && !isNull _source) || (_criticalHit && UNCONSCIOUS(_unit))) && isNil {_unit getVariable "FAR_killerVehicle"}) then
{
	[_unit, _source, _ammo] call FAR_setKillerInfo;
};

if (UNCONSCIOUS(_unit)) then
{
	//if (_selection != "?") then
	//{
		_oldDamage = if (_selection == "") then { damage _unit } else { _unit getHit _selection };

		if (!isNil "_oldDamage") then
		{
			// Apply part of the damage without multiplier when below the stabilization threshold of 50% damage
			if (STABILIZED(_unit) && {_criticalHit && FAR_DamageMultiplier < 1}) then
			{
				_oldDamage = _damage min 0.5;
			};

			_damage = ((_damage - _oldDamage) * FAR_DamageMultiplier) + _oldDamage;

			if (_criticalHit) then
			{
				_unit setDamage _damage;
			};
		};

		if (_damage >= 1 && _criticalHit) then
		{
			diag_log format ["MORT par [%1] avec [%2]", _source, _ammo];
		};
	//};
}
else
{
	// Allow revive if unit is dead and not in exploded vehicle
	if (_dead && alive vehicle _unit) then
	{
		_unit setVariable ["FAR_isUnconscious", 1, true];
		[] spawn fn_deletePlayerData;

		_unit allowDamage false;
		//if (vehicle _unit == _unit) then { [_unit, "AinjPpneMstpSnonWrflDnon"] call switchMoveGlobal };
		_unit enableFatigue true;
		_unit setFatigue 1;

		if (!isNil "FAR_Player_Unconscious_thread" && {typeName FAR_Player_Unconscious_thread == "SCRIPT" && {!scriptDone FAR_Player_Unconscious_thread}}) then
		{
			terminate FAR_Player_Unconscious_thread;
		};

		closeDialog ReviveBlankGUI_IDD;
		closeDialog ReviveGUI_IDD;

		FAR_Player_Unconscious_thread = [_unit, _source] spawn FAR_Player_Unconscious;

		_damage = 0.5;

		diag_log format ["NEUTRALISÉ par [%1] avec [%2]", _source, _ammo];
	};
};

//_damage
