function [retCode, boardHandle] = AlazarSetTriggerTimeOut(boardHandle, timeoutTicks)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetTriggerTimeOut', boardHandle, timeoutTicks);
