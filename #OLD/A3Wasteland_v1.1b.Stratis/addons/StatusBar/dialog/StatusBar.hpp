#define ST_RIGHT 0x01

class StatusBar {
	idd = -1;
	onLoad = "uiNamespace setVariable ['StatusBar', _this select 0]";
	onUnload = "uiNamespace setVariable ['StatusBar', objNull]";
	onDestroy = "uiNamespace setVariable ['StatusBar', objNull]";
	fadein = 0;
	fadeout = 0;
	duration = 10e10;
	movingEnable = 0;
	controlsBackground[] = {};
	objects[] = {};
	class controls {
		class statusBarText {
			idc = 1000;
			x = safezoneX + safezoneW - 1.80;
			y = safezoneY + safezoneH - 0.04;
			w = 1.25;
			h = 0.04;
			shadow = 1;
			colorBackground[] = { 1, 0.3, 0, 0.0 };
			font = "PuristaSemibold";
			size = 0.03;
			type = 13;
			style = 0;
			text="Chargement ...";
			class Attributes {
				align="right";
				color = "#58FA58";
			};
		};
	};
};