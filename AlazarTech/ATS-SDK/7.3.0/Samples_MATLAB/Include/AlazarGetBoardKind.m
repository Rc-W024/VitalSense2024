function [kind, boardHandle] = AlazarGetBoardKind(boardHandle)
[kind, boardHandle] = calllib('ATSApi', 'AlazarGetBoardKind', boardHandle);
