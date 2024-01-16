function [retCode, boardHandle, fileName] = AlazarCoprocessorDownload(boardHandle, fileName, options)
[retCode, boardHandle, fileName] = calllib('ATSApi', 'AlazarCoprocessorDownload', boardHandle, fileName, options);
