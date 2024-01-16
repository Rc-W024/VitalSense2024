function [retCode, boardHandle, pFileName, pError] = AlazarOEMDownLoadFPGA(boardHandle, pFileName, pError)
[retCode, boardHandle, pFileName, pError] = calllib('ATSApi', 'AlazarOEMDownLoadFPGA', boardHandle, pFileName, pError);
