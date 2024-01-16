function [retCode, boardHandle] = AlazarSetExternalClockLevel(boardHandle, level_percent)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetExternalClockLevel', boardHandle, level_percent);
