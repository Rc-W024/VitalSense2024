function [retCode, boardHandle] = AlazarForceTrigger(boardHandle)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarForceTrigger', boardHandle);
