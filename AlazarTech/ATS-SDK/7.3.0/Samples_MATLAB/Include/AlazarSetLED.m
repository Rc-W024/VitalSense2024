function [retCode, boardHandle] = AlazarSetLED(boardHandle, ledOn)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetLED', boardHandle, ledOn);
