;+
;v.0.23
;2018.07.25
;;2018.07.27
;2018.07.31
;2018.08.01
; :Description:
;    Describe the procedure.
;
;
;
;
;
; :Author: Anton Kananovich
;-
PRO driver_getPulseProfiles
curDate='20180904'
aWignerZeiss = 7.191d
leftBorder = 550.0d
rightBorder = 850.0d
yMin = -600.00d
yMax = 600.00d
b = 0.25d

binwAWZ = b * SQRT((2.0d*!DPI/SQRT(3.0d)))
iBegin=1093 
iEnd = 1157
framestep = 50
coreName = STRCOMPRESS(curDate + 'hists_' + '_ff'+STRING(iBegin)+'-' + STRING(iEnd))
CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_14226_457\analysis\20180904profilesFPsavgol\03_code_an_getPulseProfiles\inputs'
file = DIALOG_PICKFILE(/READ, FILTER = '*.txt')
sdataFile = getPulseProfiles(file, aWignerZeiss, leftBorder, rightBorder, yMin, yMax, framestep, binwAWZ)
CD, '..\outputs'
maxTime = MAX(sdataFile.time)
minTime = MIN(sdataFile.time)

seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
SAVE, sdataFile, filename = STRCOMPRESS(coreName+ seconds+ '.sav')

savgolFilter = SAVGOL(3, 3, 0, 4, /DOUBLE)
FOR i = minTime, maxTime DO BEGIN
curInd = WHERE(sdataFile.time EQ i)
X = sdataFile.coord[curind]
Y = sdataFile.den[curind]
Yfiltered = CONVOL(Y, savgolFilter, /EDGE_TRUNCATE);
p=plot(x,y,linestyle='',symbol='+')
p = plot(x,yfiltered,color='blue',/overplot)

p.close
;if (i LE minTime + 20) then p = plot(X,Y, /overplot)
;if (i LE minTime + 40 AND i GE minTime + 20) then p = plot(X, Y, /overplot, color = 'blue')
;if (i LE minTime + 60 AND i GE minTime + 40) then p = plot(X, Y, /overplot, color = 'green')
;if (i LE minTime + 80 AND i GE minTime + 60) then p = plot(X, Y, /overplot, color = 'yellow')
;if (i LE minTime + 100 AND i GE minTime + 80) then p = plot(X, Y, /overplot, color = 'yellow')




ENDFOR

stop
END


