function [retCode, boardHandle] = AlazarSetTriggerOperation(boardHandle, triggerOperation, triggerEngineId1, sourceId1, slopeId1, level1, triggerEngineId2, sourceId2, slopeId2, level2)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetTriggerOperation', boardHandle, triggerOperation, triggerEngineId1, sourceId1, slopeId1, level1, triggerEngineId2, sourceId2, slopeId2, level2);
