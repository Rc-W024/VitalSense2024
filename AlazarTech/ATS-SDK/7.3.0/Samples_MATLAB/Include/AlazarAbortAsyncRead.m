function [retCode, boardHandle] = AlazarAbortAsyncRead(boardHandle)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarAbortAsyncRead', boardHandle);
