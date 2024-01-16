function [retCode, boardHandle] = AlazarBeforeAsyncRead(boardHandle, channelSelect, transferOffset, samplesPerRecord, recordsPerBuffer, recordsPerAcquisition, flags)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarBeforeAsyncRead', boardHandle, channelSelect, transferOffset, samplesPerRecord, recordsPerBuffer, recordsPerAcquisition, flags);
