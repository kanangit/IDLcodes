;+
; :Description:
;      v.0.14 2018.09.18 debug
; ;    v.0.13 2018.09.18 debug
;    v.0.12
;The routine is almost identical to driver_transfShockFrameRefer.
;It is a simplification of that routine.
;It ususes the maximum of second derivative as a point used to
;align the pulses in different frames.
;
;
;
;
; :Author: Anton Kananovich
; created: 2018.07.18
;-
PRO driver_transfShockFrameRefer2ndDeriv

curDate='20180918'
;define borders of the region of interest
leftBorder = 550.0d
rightBorder= 850.0d;
yMin = 0.0d;
yMax = 1215.0d
;start and and frames
iBegin = 1000
iEnd =  1059


 
coreName = STRCOMPRESS('ff'+STRING(iBegin)+'-' + STRING(iEnd) + '_' + STRING(curDate))
aWignerZeiss = 7.191d ;Wigner-Zeiss radius in pixels
dy = 3.0d * aWignerZeiss
;dy = 14.0d
cutpulwid = dy*2.0d
nB = FLOOR((yMax - yMin)/dY); number of bins
yBins = DINDGEN(nB)*dY+yMin + dY/2
CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_fakeParticles_debug\an_transfShockFrameRefer2ndDeriv'
CD, 'inputs'
s = readImageJK(/lowmem);

CD, '..\outputs'

;we need only the data inside the region of interest
ind = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)               
arrlen = N_ELEMENTS(s.X[ind]);  
Yroi = yMax - (s.Y[ind] - yMin) ;because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
time = s.iframe[ind] ;array to track time
p = plot([0],[0]) 


sXY = {X:DBLARR(nB),Y:DBLARR(nB)}
pulseT = DBLARR(iEnd-iBegin+1);
pulsecm = DBLARR(iEnd-iBegin+1);


;-----------------------------------------------------------------------
;Calculating the maximal second derivative of the pulse in each frame:
CD, 'histograms'  
FOR i = iBegin, iEnd DO BEGIN
  print, 'frame ', i
  ;building histogram using cloud-in-cell (cic):
  indf = WHERE(time EQ i)
  Y = Yroi[indf]
  YforHist = (Y - yMin)/(yMax-yMin)*DOUBLE(nB)
  weighNumDens = DBLARR(N_ELEMENTS(YforHist))+1 ; weights for the number density
  histNumDens = CIC(weighNumDens, YforHist, nB, /ISOLATED) / dy / (rightBorder - leftBorder)
  ;WAIT, 1

  sXY.X = ybins
  sXY.Y = histNumDens
  
  sResul = findFrontMR(sXY)
   
 
  ; cutout part of the pulse
  ; near the maximum
  cmpos = sResul.X
  indcm = WHERE((yBins - cmpos)^2 LE dy^2)
  pulseT[i-iBegin] = DOUBLE(i)
  pulsecm[i-iBegin] = cmpos
  ;p = plot(resul[0,*],resul[1,*],color='blue',/overplot,thick=4)
  ;p = plot([cmpos],[histnumdens[indcm[0]]],color='red',/overplot,thick=4, symbol='+')
  
  filename = STRCOMPRESS('histo_frame'+STRING(i,FORMAT='(I04)')+'.csv')  
  z=print2arrays(filename,yBins,histNumDens)
;  p.close
;  p = PLOT(yBins,histNumDens,/OVERPLOT)
;  
;  p = plot([cmpos],[histnumdens[indcm[0]]],color='red',/overplot,thick=4, symbol='+')
  IF i EQ 800 THEN p.save, 'frame'+STRING(i)+'.png'
  IF i EQ 760 THEN p.save, 'frame'+STRING(i)+'.png'
  IF i EQ 900 THEN p.save, 'frame'+STRING(i)+'.png'
  IF i EQ 1000 THEN p.save, 'frame'+STRING(i)+'.png'
  IF i EQ 1100 THEN p.save, 'frame'+STRING(i)+'.png'  
ENDFOR
p.CLOSE
CD, '..'
;stop
;p = plot(pulseT,cmpos,symbol='.',linestyle ='none')
p = plot(pulseT,pulsecm,symbol='.',linestyle ='none')
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
IF (KEYWORD_SET(pulseEdge)) THEN $ 
fname = STRCOMPRESS(corename + '_EdgePosition_BinWidth' + STRING(dy / aWignerZeiss, format = '(D3.1)') + 'awz_time' + seconds + '.csv', /REMOVE_ALL) $
ELSE fname = STRCOMPRESS(corename + '_EdgePosition_BinWidth' + STRING(dy / aWignerZeiss, format = '(D3.1)') + 'awz_time' + seconds + '.csv', /REMOVE_ALL)
r = print2arrays(fname,pulseT,pulsecm)
;fitting with linear dependence
coeffs = POLY_FIT(pulseT,pulseCM,1,/DOUBLE)
transY = (yMax - (s.Y - yMin)) - coeffs[0] - coeffs[1]*DOUBLE(s.iFrame)
;transY = (yMax - (s.Y - yMin)) - 1000.0d - 0.040d*DOUBLE(s.iFrame)
print, 'pulse velocity = ', coeffs[1]
print, 'pulse offset = ', coeffs[0]

;-----------------------------------------------------------------------
;              Now save the transformed coordinates to a file along with
;              other parameters:
s.Y = transY;
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
fname = STRCOMPRESS(corename + '_positionTransformed' + seconds + '.txt',/REMOVE_ALL)
resSave = print6arrays(fname,s.iParticle,s.iFrame,s.area,s.X,s.Y,s.error,/firstinteger)
;stop              
;---------------------------------------------------------------------------------------------------------------------------              
;now we check if everything is allright:
newRoiind = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
              AND transY LE (yMax-yMin)/2.0d AND transY GE -(yMax-yMin)/2.0d)
transYRoi = transY[newRoiind]
time = s.iframe[newRoiind]
transyMin = MIN(transYRoi)
transyMax = MAX(transYroi)
transyBins = DINDGEN(nB)*dY+transYMin + dY/2
p.close
FOR i = iBegin, iEnd DO BEGIN
;building histogram using cloud-in-cell (cic):
indf = WHERE(time EQ i)
Y = transYRoi[indf]
YforHist = (Y - transYMin)/(transYMax-transYMin+1.0E-3)*DOUBLE(nB)
weighNumDens = DBLARR(N_ELEMENTS(YforHist))+1 ; weights for the number density
print, 'frame=',i
print, 'max y = ', max(yforhist)
histNumDens = CIC(weighNumDens, YforHist, nB, /ISOLATED)
;WAIT, 1
;p.close
p = PLOT(transyBins,histNumDens,/OVERPLOT)

ENDFOR
              
stop
p.close
END