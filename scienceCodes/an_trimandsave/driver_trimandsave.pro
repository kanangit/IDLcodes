;v.0.15 the routine seletcs the region of interest and saves as a new file. For huge files and small region of interests this could be a real time saver
PRO driver_trimandsave
curDate='20180917'
leftBorder = 550.0d
rightBorder= 850.0d;
yMin = 0.0d;
yMax = 1215.0d
iBegin=1000 
iEnd = 1250
coreName = STRCOMPRESS('ff'+STRING(iBegin)+'-' + STRING(iEnd) + '_' + STRING(curDate))

CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_14226_451\analysed\analysis20180917profilesDebug\01_code_an_trimandsave'
CD, 'inputs'

s = readImageJK(/lowmem)

;exclude all the bad elements of the data:
indGood = WHERE(FINITE(s.iparticle) AND FINITE(s.iFrame) $
 AND FINITE(s.area) AND FINITE(s.X) AND FINITE(s.Y) $
 AND FINITE(s.error))
iParticleTrim = s.iparticle[indGood]
iFrameTrim = s.iFrame[indGood]
areaTrim = s.area[indGood]
XTrim = s.X[indGood]
Ytrim = s.Y[indGood]
errorTrim = s.error[indGood]

;stop
;select the region of interest:
indROI = WHERE(XTrim LE rightBorder AND XTrim GE leftBorder AND Ytrim LE ymax AND Ytrim GE yMin AND iFrameTrim GE iBegin AND iFrameTrim LE iEnd)

Iparticle = iParticleTrim[indROI]
iFrame = iFrameTrim[indROI]
area = areaTrim[indROI]
X = XTrim[indROI]
Y = Ytrim[indROI]
error = errorTrim [indROI]
;preparing to save the data:
CD, '..\outputs'
;append the number of secods since January 1 1970 to make the
;filename distinguishable:
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
fnam = STRCOMPRESS(corename + 'positionTrimmed' + seconds + '.txt',/REMOVE_ALL) 
resSave = print6arrays(fnam,iParticle,iFrame,area,X,Y,error,/firstinteger)

END