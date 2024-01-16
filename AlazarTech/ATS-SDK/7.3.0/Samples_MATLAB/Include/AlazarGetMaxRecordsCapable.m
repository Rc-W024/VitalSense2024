function [retCode, handle, pMaxRecordsPerCapture] = AlazarGetMaxRecordsCapable(handle, samplesPerRecord, pMaxRecordsPerCapture)
[retCode, handle, pMaxRecordsPerCapture] = calllib('ATSApi', 'AlazarGetMaxRecordsCapable', handle, samplesPerRecord, pMaxRecordsPerCapture);
