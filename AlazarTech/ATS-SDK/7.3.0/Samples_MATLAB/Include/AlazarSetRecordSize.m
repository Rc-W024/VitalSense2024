function [retCode, boardHandle] = AlazarSetRecordSize(boardHandle, preTriggerSamples, postTriggerSamples)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetRecordSize', boardHandle, preTriggerSamples, postTriggerSamples);
