function [retCode, boardHandle] = AlazarSetTriggerOperationForScanning(boardHandle, triggerSlopeId, triggerLevel, options)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetTriggerOperationForScanning', boardHandle, triggerSlopeId, triggerLevel, options);
