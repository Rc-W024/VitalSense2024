function [retCode, boardHandle, pMemorySizeInSamples, pBitsPerSample] = AlazarGetChannelInfo(boardHandle, pMemorySizeInSamples, pBitsPerSample)
[retCode, boardHandle, pMemorySizeInSamples, pBitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', boardHandle, pMemorySizeInSamples, pBitsPerSample);
