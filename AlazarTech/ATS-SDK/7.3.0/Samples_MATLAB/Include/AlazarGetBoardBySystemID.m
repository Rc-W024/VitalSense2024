function handle = AlazarGetBoardBySystemID(systemId, boardId)
handle = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
