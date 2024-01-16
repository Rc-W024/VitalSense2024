function [retCode, boardHandle] = AlazarForceTriggerEnable(boardHandle)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarForceTriggerEnable', boardHandle);
