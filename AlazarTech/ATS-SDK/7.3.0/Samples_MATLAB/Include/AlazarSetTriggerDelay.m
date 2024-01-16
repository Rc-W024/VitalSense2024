function [retCode, boardHandle] = AlazarSetTriggerDelay(boardHandle, value)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetTriggerDelay', boardHandle, value);
