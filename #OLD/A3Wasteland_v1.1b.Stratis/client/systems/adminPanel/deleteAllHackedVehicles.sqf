// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
{ deleteVehicle (_x select 0) } forEach (call findHackedVehicles);

player commandChat "Tous les véhicules hackés ont été supprimés";

closeDialog 0;
execVM "client\systems\adminPanel\vehicleManagement.sqf";
