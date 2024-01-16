function [retCode, boardHandle, pMajorVersion, pMinorVersion] = AlazarGetBoardRevision(boardHandle, pMajorVersion, pMinorVersion)
[retCode, boardHandle, pMajorVersion, pMinorVersion] = calllib('ATSApi', 'AlazarGetBoardRevision', boardHandle, pMajorVersion, pMinorVersion);
