;descendant of an_allprofiles and an_getGraphsForPap

;+
;v.0.9 2018.09.17 debug
;v.0.8 2018.09.16 debug
; :Description:
;    Describe the procedure.
;
;
;
;
;
; :Author: Breckenridge4 Cyrill
;-
PRO driver_allprofilesOneFrame
curDate='20180917'
aWignerZeiss = 7.191d
leftBorder = 550.0d
rightBorder = 850.0d
;rightBorder = 750.0d
yMin = 0.00d
yMax = 1250.00d
;yMin = -600.00d
;yMax = 600.00d
;b = 0.25d
b = 2.0d

binwAWZ = b * SQRT((2.0d*!DPI/SQRT(3.0d)))

;framestep = 50
framestep = 1

;coreName = STRCOMPRESS(curDate + 'hists_' + '_ff'+STRING(iBegin)+'-' + STRING(iEnd))


myframe = 959
sgLeft  = 2
sgRight = 2
sgOrder = 4
;sgLeft  = 14
;sgRight = 14
;sgOrder = 4


CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_14226_451\analysed\analysis20180917profilesDebug\07_an_allprofilesOneFrame'
CD, 'inputs'
file = DIALOG_PICKFILE(/READ, FILTER = '*.sav')
sdataFile = get_allprofiles(file, aWignerZeiss, leftBorder, rightBorder, yMin, yMax, framestep, binwAWZ)

CD, '..\outputs'

iwant = where(sdatafile.time eq myframe)
x = sdatafile.coord[iwant]
y = sdatafile.den[iwant]
ty = sdatafile.ty[iwant]
vy = sdatafile.vy[iwant]

dt = x[1]-x[0]
savgolFilter = SAVGOL(sgLeft, sgRight, 0, sgOrder, /DOUBLE)
savgolSecondFilter = SAVGOL(sgLeft, sgRight, 2, sgOrder, /DOUBLE)*(FACTORIAL(2)/ (dt^2))
savgolFirstFilter = SAVGOL(sgLeft, sgRight, 1, sgOrder, /DOUBLE)*(FACTORIAL(1)/ (dt^2))
Yfiltered = CONVOL(Y, savgolFilter, /EDGE_TRUNCATE);
Tyfiltered = CONVOL(tY, savgolFilter, /EDGE_TRUNCATE);
vyfiltered = CONVOL(vY, savgolFilter, /EDGE_TRUNCATE);
;x = TEMPORARY(x) - 1200.0d
;x = REVERSE(TEMPORARY(x))
p = plot(x,yfiltered/max(yfiltered),color = 'black',/overplot)
p2 = plot(x,tyfiltered/max(tyfiltered),color = 'red',/overplot)
p3 = plot(x,vyfiltered/max(vyfiltered),color = 'blue',/overplot)

stop
END