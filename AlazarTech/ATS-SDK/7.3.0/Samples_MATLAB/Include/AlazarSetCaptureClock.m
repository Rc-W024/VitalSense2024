function [retCode, boardHandle] = AlazarSetCaptureClock(boardHandle, sourceId, sampleRateId, edgeId, decimation)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetCaptureClock', boardHandle, sourceId, sampleRateId, edgeId, decimation);
