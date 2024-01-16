function [retCode, boardHandle] = AlazarSetRecordCount(boardHandle, recordsPerCapture)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetRecordCount', boardHandle, recordsPerCapture);
