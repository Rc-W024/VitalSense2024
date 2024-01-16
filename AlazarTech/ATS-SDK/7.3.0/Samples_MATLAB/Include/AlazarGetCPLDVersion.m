function [retCode, boardHandle, pMajorNumber, pMinorNumber] = AlazarGetCPLDVersion(boardHandle, pMajorNumber, pMinorNumber)
[retCode, boardHandle, pMajorNumber, pMinorNumber] = calllib('ATSApi', 'AlazarGetCPLDVersion', boardHandle, pMajorNumber, pMinorNumber);
