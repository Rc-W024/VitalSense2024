function [retCode, dspHandle] = AlazarFFTSetWindowFunction(dspHandle, samplesPerRecord, pRealWindowArray, pImagWindowArray)
[retCode, dspHandle] = calllib('ATSApi', 'AlazarFFTSetWindowFunction', dspHandle, samplesPerRecord, pRealWindowArray, pImagWindowArray);
