function [retCode, boardHandle, filePath] = AlazarCreateStreamFile(boardHandle, filePath)
[retCode, boardHandle, filePath] = calllib('ATSApi', 'AlazarCreateStreamFile', boardHandle, filePath);
