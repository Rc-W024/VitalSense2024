function [retCode, boardHandle] = AlazarConfigureRecordAverage(boardHandle, mode, samplesPerRecord, recordsPerAverage, options)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarConfigureRecordAverage', boardHandle, mode, samplesPerRecord, recordsPerAverage, options);
