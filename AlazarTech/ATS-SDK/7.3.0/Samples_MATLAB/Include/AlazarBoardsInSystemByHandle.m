function [retCode, boardHandle] = AlazarBoardsInSystemByHandle(boardHandle)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarBoardsInSystemByHandle', boardHandle);
