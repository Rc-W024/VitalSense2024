function [retCode, pMajorNumber, pMinorNumber, pRevisionNumber] = AlazarGetDriverVersion(pMajorNumber, pMinorNumber, pRevisionNumber)
[retCode, pMajorNumber, pMinorNumber, pRevisionNumber] = calllib('ATSApi', 'AlazarGetDriverVersion', pMajorNumber, pMinorNumber, pRevisionNumber);
