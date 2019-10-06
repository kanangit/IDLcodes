; :Description:
;    v0.21.
;    2018.07.18
;    2018.07.31
;    2018.08.01
;The function builds profiles of the shock pulse 
;2018.07.25 added the flip keyword
;
;
;
; :Author: Anton Kananovich
;-
FUNCTION getPulseProfiles, path, aWignerZeiss, leftBorder, rightBorder, yMin, yMax, framestep, binwAWZ, flip = flip

dirpath = FILE_DIRNAME(path)
CD, dirpath
binWinterparticle = binwAWZ / SQRT((2.0d*!DPI/SQRT(3.0d)))
dy = binwAWZ * aWignerZeiss
area = dy*(rightBorder - leftBorder)
;iBegin=759
;iBegin=520
;iEnd = 1999
;iEnd = iBegin + 8*4
;frameStep = 1
nB = FLOOR((yMax - yMin)/dY); number of bins
yBins = DINDGEN(nB)*dY+yMin + dY/2
s = readImageJK(path, /lowmem);
iBegin = MIN(s.iframe)
iEnd = MAX(s.iframe)

;stop
indROI = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)
                             
arrlen = N_ELEMENTS(s.X[indROI]);
time = s.iframe[indROI]
YROI = s.Y[indROI]

; reserver the names of variables for the array to 
;store both the density histograms and the time when it was taken:
denstime = 0
denscoord = 0
densamplitude = 0
timearray = DBLARR(nB); an auxiliarry array which will be used in the
; cycle  

curhistS = {X:DBLARR(nB),Y:DBLARR(nB)}; structure to keep current
;  histogram data
curHistS.X = Ybins; don't be afraid, we are just using Y coordinate 
; as X-coordinate. It can be confusing, but our shock is propagating
; along the Y-axis geometrically, but in the future we are going to 
; plot number density (Y-axis) vs coordinate (X-axis, previous
;  Y-coordinate)  

FOR i = iBegin, iEnd - frameStep DO BEGIN
;building histogram using cloud-in-cell (cic):
indf = WHERE(time GE i AND time LE i+frameStep)
Y = YROI[indf]
YforHist = (Y - YMin)/(YMax-YMin+1.0E-8)*DOUBLE(nB)
weighNumDens = DBLARR(N_ELEMENTS(YforHist))+1 ; weights for the number density
histNumDens = CIC(weighNumDens, YforHist, nB, /ISOLATED) / area / (DOUBLE(frameStep)+1.0d)
curHistS.Y = histNumDens
print, 'frame=',i

IF (N_ELEMENTS(denstime) EQ 1) THEN BEGIN
  denstime = timearray + DOUBLE(i)+ DOUBLE(framestep)/2.0d
  denscoord = Ybins
  densamplitude = histNumDens
ENDIF ELSE BEGIN
  denstime = [denstime,timearray + DOUBLE(i)+DOUBLE(framestep)/2.0d]
  denscoord = [denscoord,Ybins]
  densamplitude = [densamplitude,histNumDens]
ENDELSE 

ENDFOR
nelemoutput = N_ELEMENTS(denstime)
;define the structure to return data:
sdata = {time:DBLARR(nelemoutput),coord:DBLARR(nelemoutput),den:DBLARR(nelemoutput),filename:'',b:0d,frameStep:0d}
sdata.b = binWinterparticle
arrayData = {time:DBLARR(nelemoutput),coord:DBLARR(nelemoutput),den:DBLARR(nelemoutput)}
sdata.time = denstime
arrayData.time = denstime
IF (KEYWORD_SET(flip)) THEN BEGIN 
  sdata.coord = REVERSE(Ymax + Ymin - denscoord)
  sdata.den = REVERSE(densamplitude)
  arrayData.coord = REVERSE(Ymax + Ymin - denscoord)
  arrayData.den = REVERSE(densamplitude)  
ENDIF ELSE BEGIN
  sdata.coord = denscoord
  sdata.den = densamplitude
  arrayData.coord = denscoord
  arrayData.den = densamplitude
ENDELSE

denstime = 0
denscoord = 0
densamplitude = 0



;save data to file:
;append the number of secods since January 1 1970 to make the
;filename distinguishable:
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
fnam = STRCOMPRESS('profiles' + seconds + '.csv',/REMOVE_ALL)
CD, STRCOMPRESS(dirpath+'\..\outputs\')
WRITE_CSV, fnam, arrayData
sdata.filename = FILEPATH(fnam)
sdata.framestep = framestep

RETURN, sdata
END

