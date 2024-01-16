function [retCode, boardHandle, pTriggerAddress, pTimestampHighPart, pTimestampLowPart] = AlazarGetTriggerAddress(boardHandle, record, pTriggerAddress, pTimestampHighPart, pTimestampLowPart)
[retCode, boardHandle, pTriggerAddress, pTimestampHighPart, pTimestampLowPart] = calllib('ATSApi', 'AlazarGetTriggerAddress', boardHandle, record, pTriggerAddress, pTimestampHighPart, pTimestampLowPart);
