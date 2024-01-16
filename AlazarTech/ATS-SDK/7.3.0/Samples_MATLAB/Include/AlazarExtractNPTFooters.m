function [retCode, buffer, footersArray] = AlazarExtractNPTFooters(buffer, recordSize_bytes, bufferSize_bytes, footersArray, numFootersToExtract)
[retCode, buffer, footersArray] = calllib('ATSApi', 'AlazarExtractNPTFooters', buffer, recordSize_bytes, bufferSize_bytes, footersArray, numFootersToExtract);
