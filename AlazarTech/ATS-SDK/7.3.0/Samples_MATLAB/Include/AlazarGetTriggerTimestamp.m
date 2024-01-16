function [retCode, boardHandle, pTimestampSamples] = AlazarGetTriggerTimestamp(boardHandle, record, pTimestampSamples)
[retCode, boardHandle, pTimestampSamples] = calllib('ATSApi', 'AlazarGetTriggerTimestamp', boardHandle, record, pTimestampSamples);
