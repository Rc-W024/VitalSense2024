function [handle, boardHandle] = AlazarGetBoardBySystemHandle(boardHandle, boardId)
[handle, boardHandle] = calllib('ATSApi', 'AlazarGetBoardBySystemHandle', boardHandle, boardId);
