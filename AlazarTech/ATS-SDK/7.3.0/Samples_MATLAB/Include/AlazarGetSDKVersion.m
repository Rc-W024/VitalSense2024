function [retCode, pMajorNumber, pMinorNumber, pRevisionNumber] = AlazarGetSDKVersion(pMajorNumber, pMinorNumber, pRevisionNumber)
[retCode, pMajorNumber, pMinorNumber, pRevisionNumber] = calllib('ATSApi', 'AlazarGetSDKVersion', pMajorNumber, pMinorNumber, pRevisionNumber);
