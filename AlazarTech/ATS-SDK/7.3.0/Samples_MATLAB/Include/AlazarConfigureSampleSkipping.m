function [retCode, boardHandle, pSampleSkippingBitmap] = AlazarConfigureSampleSkipping(boardHandle, mode, sampleClocksPerRecord, pSampleSkippingBitmap)
[retCode, boardHandle, pSampleSkippingBitmap] = calllib('ATSApi', 'AlazarConfigureSampleSkipping', boardHandle, mode, sampleClocksPerRecord, pSampleSkippingBitmap);
