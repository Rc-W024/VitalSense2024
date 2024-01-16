function text = AlazarErrorToText(retCode)
text = calllib('ATSApi', 'AlazarErrorToText', retCode);
