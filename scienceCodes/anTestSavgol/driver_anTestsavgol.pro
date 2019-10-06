;+
; :Description:
;    2017.03.23. 
;     Purpose: test the IDL routine SAVGOL for smoothing and interpolation
;     of real experimental data
;
;
;
;
;
; :Author: Kananovich
;-

PRO driver_anTestsavgol
s = readCsv2colsd()
indf = findFrontMR(s)
END




