/*
 * Author: Ruthberg
 * Generates the Kestrel 4500 output text.
 *
 * Arguments:
 * Nothing
 *
 * Return Value:
 * [top <STRING>, centerBig <STRING>, CenterLine1Left <STRING>, CenterLine2Left <STRING>, CenterLine3Left <STRING>, CenterLine1Right <STRING>, CenterLine2Right <STRING>, CenterLine3Right <STRING>, InfoLine1 <STRING>, InfoLine2 <STRING>]
 *
 * Example:
 *
 * Public: No
 */
#include "script_component.hpp"
#include "defines.h"

private ["_playerDir", "_textTop", "_textCenterBig", "_textCenterLine1Left", "_textCenterLine2Left", "_textCenterLine3Left", "_textCenterLine1Right", "_textCenterLine2Right", "_textCenterLine3Right", "_textInfoLine1", "_textInfoLine2", "_temperature", "_humidity", "_windSpeed", "_windDir", "_newWindSpeed", "_windSource", "_height"];

if (isNil QUOTE(EGVAR(weather,Altitude))) then {EGVAR(weather,Altitude) = 0};

[] call FUNC(collectData);

_textTop = GVAR(Menus) select GVAR(Menu);
_textCenterBig = "";

_textCenterLine1Left = "";
_textCenterLine2Left = "";
_textCenterLine3Left = "";
_textCenterLine1Right = "";
_textCenterLine2Right = "";
_textCenterLine3Right = "";

_textInfoLine1 = "";
_textInfoLine2 = "";

_windSpeed = vectorMagnitude ACE_wind;
_windDir = (ACE_wind select 0) atan2 (ACE_wind select 1);

_temperature = GET_TEMPERATURE_AT_HEIGHT((getPosASL ACE_player) select 2);
_humidity = EGVAR(weather,currentHumidity);

_playerDir = getDir ACE_player;

if (missionNamespace getVariable [QEGVAR(advanced_ballistics,enabled), false]) then {
    _windSpeed = (eyePos ACE_player) call EFUNC(advanced_ballistics,calculateWindSpeed);
    _windSpeed = abs(cos(_playerDir - _windDir)) * _windSpeed;
};

if (_windSpeed > 0.3) then {
    GVAR(MeasuredWindSpeed) = _windSpeed;
} else {
    GVAR(MeasuredWindSpeed) = GVAR(MeasuredWindSpeed) * 0.99;
    if (GVAR(MeasuredWindSpeed) < 0.05) then {
        GVAR(MeasuredWindSpeed) = 0;
    };
};

GVAR(WheelState) = GVAR(WheelState) + (ceil(GVAR(MeasuredWindSpeed)) min 1) max GVAR(MeasuredWindSpeed);
if (GVAR(WheelState) > 1000) then { GVAR(WheelState) = 0 };

GVAR(Direction) = 4 * floor(_playerDir / 90);
if (_playerDir % 90 > 10) then { GVAR(Direction) = GVAR(Direction) + 1};
if (_playerDir % 90 > 35) then { GVAR(Direction) = GVAR(Direction) + 1};
if (_playerDir % 90 > 55) then { GVAR(Direction) = GVAR(Direction) + 1};
if (_playerDir % 90 > 80) then { GVAR(Direction) = GVAR(Direction) + 1};
GVAR(Direction) = GVAR(Direction) % 16;

switch (GVAR(Menu)) do {
    case 0: { // Direction
        if (!GVAR(MinAvgMax)) then {
            _textCenterBig = format["%1", format["%1 %2", GVAR(Directions) select GVAR(Direction), round(_playerDir)]];
        } else {
            _textCenterLine1Left = "Min";
            _textCenterLine2Left = "Avg";
            _textCenterLine3Left = "Max";
            _textCenterLine1Right = "N/A";
            _textCenterLine2Right = "N/A";
            _textCenterLine3Right = "N/A";			
        };
    };
    case 1: { // Wind SPD
        if (!GVAR(MinAvgMax)) then {
            _textCenterBig = Str(round(abs(GVAR(MeasuredWindSpeed)) * 10) / 10);
        } else {
            _textCenterLine1Left = "Max";
            _textCenterLine2Left = "Avg";
            switch (GVAR(MinAvgMaxMode)) do {
                case 0: {
                    _textCenterLine1Right = "--. -";
                    _textCenterLine2Right = "--. -";
                    _textInfoLine2 = "- average";
                };
                case 1: {
                    _textCenterLine1Right = Str(round((GVAR(Max) select 1) * 10) / 10);
                    _textCenterLine2Right = Str(round((GVAR(Total) select 1) / (GVAR(Entries) select 1) * 10) / 10);
                    _textInfoLine2 = "- stop";
                };
                case 2: {
                    _textCenterLine1Right = Str(round((GVAR(Max) select 1) * 10) / 10);
                    _textCenterLine2Right = Str(round((GVAR(Total) select 1) / (GVAR(Entries) select 1) * 10) / 10);
                    _textInfoLine2 = "- clear";
                };
            };
        };
    };
    case 2: { // CROSSWIND
        if (!GVAR(MinAvgMax)) then {
            if (missionNamespace getVariable [QEGVAR(advanced_ballistics,enabled), false]) then {
                _textCenterBig = Str(round(abs(sin(GVAR(RefHeading) - _playerDir) * GVAR(MeasuredWindSpeed)) * 10) / 10);
                _textInfoLine1 = format["%1 m/s @ %2", round((cos(_playerDir - _windDir) * GVAR(MeasuredWindSpeed)) * 10) / 10, round(_playerDir)];
            } else {
                _textCenterBig = Str(round(abs(sin(GVAR(RefHeading)) * GVAR(MeasuredWindSpeed)) * 10) / 10);
                _textInfoLine1 = format["%1 m/s @ %2", round(GVAR(MeasuredWindSpeed) * 10) / 10, round(_windDir)];
            };
            _textInfoLine2 = "- set heading";
        } else {
            _textCenterLine1Left = "Max";
            _textCenterLine2Left = "Avg";
            switch (GVAR(MinAvgMax)Mode) do {
                case 0: {
                    _textCenterLine1Right = "--. -";
                    _textCenterLine2Right = "--. -";
                    _textInfoLine2 = "- average";
                };
                case 1: {
                    _textCenterLine1Right = Str(round((GVAR(Max) select 2) * 10) / 10);
                    _textCenterLine2Right = Str(round((GVAR(Total) select 2) / (GVAR(Entries) select 2) * 10) / 10);
                    _textInfoLine2 = "- stop";
                };
                case 2: {
                    _textCenterLine1Right = Str(round((GVAR(Max) select 2) * 10) / 10);
                    _textCenterLine2Right = Str(round((GVAR(Total) select 2) / (GVAR(Entries) select 2) * 10) / 10);
                    _textInfoLine2 = "- clear";
                };
            };
        };
    };
    case 3: { // HEADWIND
        if (!GVAR(MinAvgMax)) then {
            if (missionNamespace getVariable [QEGVAR(advanced_ballistics,enabled), false]) then {
                _textCenterBig = Str(round(abs(cos(GVAR(RefHeading) - _playerDir) * GVAR(MeasuredWindSpeed)) * 10) / 10);
                _textInfoLine1 = format["%1 m/s @ %2", round((cos(_playerDir - _windDir) * GVAR(MeasuredWindSpeed)) * 10) / 10, round(_playerDir)];
            } else {
                _textCenterBig = Str(round(abs(cos(GVAR(RefHeading)) * GVAR(MeasuredWindSpeed)) * 10) / 10);
                _textInfoLine1 = format["%1 m/s @ %2", round(GVAR(MeasuredWindSpeed) * 10) / 10, round(_windDir)];
            };
            _textInfoLine2 = "- set heading";
        } else {
            _textCenterLine1Left = "Max";
            _textCenterLine2Left = "Avg";
            switch (GVAR(MinAvgMax)Mode) do {
                case 0: {
                    _textCenterLine1Right = "--. -";
                    _textCenterLine2Right = "--. -";
                    _textInfoLine2 = "- average";
                };
                case 1: {
                    _textCenterLine1Right = Str(round((GVAR(Max) select 3) * 10) / 10);
                    _textCenterLine2Right = Str(round((GVAR(Total) select 3) / (GVAR(Entries) select 3) * 10) / 10);
                    _textInfoLine2 = "- stop";
                };
                case 2: {
                    _textCenterLine1Right = Str(round((GVAR(Max) select 3) * 10) / 10);
                    _textCenterLine2Right = Str(round((GVAR(Total) select 3) / (GVAR(Entries) select 3) * 10) / 10);
                    _textInfoLine2 = "- clear";
                };
            };
        };
    };
    case 4: { // TEMP
        if (!GVAR(MinAvgMax)) then {
            _textCenterBig = Str(round(_temperature * 10) / 10);
        } else {
            _textCenterLine1Left = "Min";
            _textCenterLine2Left = "Avg";
            _textCenterLine3Left = "Max";
            _textCenterLine1Right = Str(round((GVAR(Min) select 4) * 10) / 10);
            _textCenterLine2Right = Str(round((GVAR(Total) select 4) / (GVAR(Entries) select 4) * 10) / 10);
            _textCenterLine3Right = Str(round((GVAR(Max) select 4) * 10) / 10);
        };
    };
    case 5: { // HUMIDITY
        if (!GVAR(MinAvgMax)) then {
            _textCenterBig = Str(round(_humidity * 100 * 10) / 10);
        } else {
            _textCenterLine1Left = "Min";
            _textCenterLine2Left = "Avg";
            _textCenterLine3Left = "Max";
            _textCenterLine1Right = Str(round((GVAR(Min) select 5) * 10) / 10);
            _textCenterLine2Right = Str(round((GVAR(Total) select 5) / (GVAR(Entries) select 5) * 10) / 10);
            _textCenterLine3Right = Str(round((GVAR(Max) select 5) * 10) / 10);
        };
    };
    case 6: { // BARO
        if (!GVAR(MinAvgMax)) then {
            _textCenterBig = Str(round((1013.25 * exp(-(EGVAR(weather,Altitude) + ((getPosASL ACE_player) select 2)) / 7990) - 10 * overcast) * 10) / 10);
        } else {
            _textCenterLine1Left = "Min";
            _textCenterLine2Left = "Avg";
            _textCenterLine3Left = "Max";
            _textCenterLine1Right = Str(round((GVAR(Min) select 6) * 10) / 10);
            _textCenterLine2Right = Str(round((GVAR(Total) select 6) / (GVAR(Entries) select 6) * 10) / 10);
            _textCenterLine3Right = Str(round((GVAR(Max) select 6) * 10) / 10);
        };
    };
    case 7: { // ALTITUDE
        if (!GVAR(MinAvgMax)) then {
            _textCenterBig = Str(round(EGVAR(weather,Altitude) + ((getPosASL ACE_player) select 2)));
        } else {
            _textCenterLine1Left = "Min";
            _textCenterLine2Left = "Avg";
            _textCenterLine3Left = "Max";
            _textCenterLine1Right = Str(round(GVAR(Min) select 7));
            _textCenterLine2Right = Str(round((GVAR(Total) select 7) / (GVAR(Entries) select 7)));
            _textCenterLine3Right = Str(round(GVAR(Max) select 7));
        };
    };
    case 8: { // User Screen 1
        _textCenterLine1Left = Str(round(_playerDir));
        _textCenterLine2Left = Str(round(EGVAR(weather,Altitude) + ((getPosASL ACE_player) select 2)));
        _textCenterLine3Left = Str(round(abs(GVAR(MeasuredWindSpeed)) * 10) / 10);
        _textCenterLine1Right = GVAR(Directions) select GVAR(Direction);
        _textCenterLine2Right = "m";
        _textCenterLine3Right = "m/s";
    };
    case 9: { // User Screen 2
        _textCenterLine1Left = Str(round(_temperature * 10) / 10);
        _textCenterLine2Left = Str(round(_humidity * 100 * 10) / 10);
        _textCenterLine3Left = Str(round((1013.25 * exp(-(EGVAR(weather,Altitude) + ((getPosASL ACE_player) select 2)) / 7990) - 10 * overcast) * 10) / 10);
        _textCenterLine1Right = "C";
        _textCenterLine2Right = "%";
        _textCenterLine3Right = "hPA";
    };
};

[_textTop, _textCenterBig, _textCenterLine1Left, _textCenterLine2Left, _textCenterLine3Left, _textCenterLine1Right, _textCenterLine2Right, _textCenterLine3Right, _textInfoLine1, _textInfoLine2]
