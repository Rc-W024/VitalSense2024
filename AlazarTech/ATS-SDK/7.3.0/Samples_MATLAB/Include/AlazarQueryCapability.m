function [retCode, boardHandle, pValue] = AlazarQueryCapability(boardHandle, capability, pValue)
[retCode, boardHandle, pValue] = calllib('ATSApi', 'AlazarQueryCapability', boardHandle, capability, pValue);
