; v.0.18. Estimation of the shock width in the frame reference of the 
;shock. The transformation to the shock frame reference was done 
;previously with the procedure driver_transfShockFrameRefer
; (I.e., the procedure can be used in any reference frame).

; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, July 2018
;           
;
;- 

PRO driver_estimShoWidth

CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_14226_451\analysed\analysis20180725profilesFP\03_code_an_estimShoWidth\inputs'
;define borders of the region of interest
iBegin=1098  
iEnd = 1104
curDate='20180726'
leftBorder = 550.0d
rightBorder= 850.0d;
yMin = -600.0d;
yMax = 600.00d
coreName = STRCOMPRESS('ff'+STRING(iBegin)+'-' + STRING(iEnd) + '_' + STRING(curDate))
aWignerZeiss = 7.191d ;Wigner-Zeiss radius in pixels
dy = 0.5d * aWignerZeiss
area = dy*(rightBorder - leftBorder)
;iBegin=759


;iEnd = iBegin + 8*4
frameStep = 6
nB = FLOOR((yMax - yMin)/dY); number of bins
yBins = DINDGEN(nB)*dY+yMin + dY/2
s = readImageJK(/lowmem);
;stop
indROI = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)
                             
arrlen = N_ELEMENTS(s.X[indROI]);
time = s.iframe[indROI]
YROI = s.Y[indROI]
;p = plot([0],[0])
;stop
;create the arrays to keep the data obtained during the FOR
;cycle below
frontT = DBLARR(iEnd-iBegin - framestep +1);
maxdenPos = DBLARR(iEnd-iBegin- framestep +1);
frontPos = DBLARR(iEnd-iBegin- framestep +1);
maxDen = DBLARR(iEnd-iBegin- framestep +1);
vicinarrS = {X:DBLARR(3),Y:DBLARR(3)}; structure used to store
;temporarily the 3 points close to the maximum for every frame
curhistS = {X:DBLARR(nB),Y:DBLARR(nB)}; structure to keep current
;  histogram data
curHistS.X = Ybins; don't be afraid, we are just using Y coordinate 
; as X-coordinate. It can be confusing, but our shock is propagating
; along the Y-axis geometrically, but in the future we are going to 
; plot number density (Y-axis) vs coordinate (X-axis, previous
;  Y-coordinate)  
;  
; reserver the names of variables for the array to 
;store both the density histograms and the date when it was taken:
denstime = 0
denscoord = 0
densamplitude = 0
timearray = DBLARR(nB); an auxiliarry array which will be used in the
; cycle  
;----------------------------------------------------------------------
CD, '..\outputs'

FOR i = iBegin, iEnd - frameStep DO BEGIN

;building histogram using cloud-in-cell (cic):
indf = WHERE(time GE i AND time LE i+frameStep)
Y = YROI[indf]
YforHist = (Y - YMin)/(YMax-YMin+1.0E-8)*DOUBLE(nB)
weighNumDens = DBLARR(N_ELEMENTS(YforHist))+1 ; weights for the number density
print, 'frame=',i
print, 'max y = ', max(yforhist)
histNumDens = CIC(weighNumDens, YforHist, nB, /ISOLATED) / area / (DOUBLE(frameStep)+1.0d)
curHistS.Y = histNumDens
maxn = MAX(histNumDens,indMaxn); ACHTUNG! THE FUNCITION CHANGES 
;THE VALUE OF THE INPUT VARIABLE indMaxn


vicinarrS.X = [yBins[indMaxn-1],yBins[indmaxn],yBins[indmaxn+1]]
vicinarrS.Y = [histnumDens[indMaxn-1],histNumDens[indMaxN],histNumDens[indMaxN+1]]
maxdens = findmaxp(vicinarrS)
front = findFrontMR(curhistS)
maxdenPos[i-iBegin] = maxdens.X
maxDen[i-iBegin] = maxn
frontPos[i-iBegin] = front.X 
frontT[i-iBegin] = DOUBLE(i)+ DOUBLE(framestep)/2.0d;
filename = STRCOMPRESS(coreName + '_density_frame'+STRING(i+ FLOOR(DOUBLE(framestep)/2.0d),FORMAT='(I04)')+'.csv')
z=print2arrays(filename,yBins,histNumDens)

;WAIT, 1
;p.close


;IF (i-iBegin) LE (iEnd-iBegin)/4 THEN $
;  p = PLOT(yBins,histNumDens,/OVERPLOT, COLOR='red')
;IF (i - iBegin) GT (iEnd-iBegin)/4  AND $
; (i-iBegin) LE 2*((iEnd-iBegin)/4) THEN $
;  p = PLOT(yBins,histNumDens,/OVERPLOT, COLOR='yellow')
;IF (i - iBegin) GT 2*(iEnd-iBegin)/4  AND $
; (i-iBegin) LE 3*((iEnd-iBegin)/4) THEN $
;  p = PLOT(yBins,histNumDens,/OVERPLOT, COLOR='green')
;IF (i - iBegin) GT 3*(iEnd-iBegin)/4  AND $
; (i-iBegin) LE 4*((iEnd-iBegin)/4) THEN $
;  p = PLOT(yBins,histNumDens,/OVERPLOT, COLOR='blue')
  
  
  
;IF i EQ 1000 THEN STOP
IF (N_ELEMENTS(denstime) EQ 1) THEN BEGIN
  denstime = timearray + DOUBLE(i)
  denscoord = Ybins
  densamplitude = histNumDens
ENDIF ELSE BEGIN
  denstime = [denstime,timearray + DOUBLE(i)]
  denscoord = [denscoord,Ybins]
  densamplitude = [densamplitude,histNumDens]
ENDELSE 
 
ENDFOR
fnamefrontPoints = STRCOMPRESS(coreName + 'front_Points.csv')
zv=print3arrays(STRCOMPRESS(coreName + 'front_Points.csv'),frontT,maxdenPos,frontPos);
zm=print3arrays(STRCOMPRESS(coreName + 'peakTimePos.csv'),frontT,maxdenPos,maxDen);
zWidth=print2arrays(STRCOMPRESS(coreName + 'width.csv'),frontT,(frontPos-maxDenPos)/aWignerZeiss);
timeAndSpace=print3arrays(STRCOMPRESS(coreName + 'timeAndSpace.csv'),densTime,denscoord,densamplitude); 
;stop
;zv=print3arrays('ff867-873_20180725front_points.csv',frontT,maxdenPos,frontPos);
;zm=print3arrays('ff867-873_20180725peakTimePos.csv',frontT,maxdenPos,maxDen);
;zWidth=print2arrays('ff867-873_20180725width.csv',frontT,(frontPos-maxDenPos)/aWignerZeiss);
;timeAndSpace=print3arrays('ff867-873_20180725timeAndSpace.csv',densTime,denscoord,densamplitude); 
;stop
;print, "shockwidth = ", MEAN((frontPos-maxDenPos)/aWignerZeiss)
END