// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: loadServerAdministratorMenu.sqf
//	@file Author: [404] Deadbeat
//	@file Created: 20/11/2012 05:19
//	@file Args:

#define adminMenu_option 50001
disableSerialization;

private ["_start","_panelOptions","_displayAdmin","_adminSelect"];
_uid = getPlayerUID player;
if ([_uid, 3] call isAdmin) then {
	_start = createDialog "AdminMenu";

	_displayAdmin = uiNamespace getVariable "AdminMenu";
	_adminSelect = _displayAdmin displayCtrl adminMenu_option;

	_panelOptions = ["Gestion Joueurs",
					"Gestion Véhicules",
					"Marqueurs Joueurs",
					"Téléporter",
	                "Argent",
	                "Menu Débug",
					"Chercher Objet",
	                "God Mode"
	];

	{
		_adminSelect lbAdd _x;
	} forEach _panelOptions;
};
