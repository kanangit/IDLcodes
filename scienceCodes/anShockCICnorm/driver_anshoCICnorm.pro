pro driver_anshoCICnorm
;nB = 40;
;;scale = 0.0339d
;scale = 0.02543d
;yMin = 0.0d;
;speed2 = 4000
;;iEquillibr = FLOOR(300.0d*6400/speed2)
;;iBegin=CEIL(350.0d*6400/speed2)
;print, 'iEuillibr=',iEquillibr
;print, 'iBegin=',iBegin
;;yMax = 896;
;yMaxCoord = 1200.0d;
;leftBorder = 600.0d
;rightBorder= 1600.0d;

nB = 40;
;scale = 0.0339d
;scale = 0.02543d
scale = 1.0d;
yMin = 0;
iBegin=41;
;yMax = 896;
yMaxCoord = 1200;
leftBorder = 550.0d
rightBorder= 850.0d;




s=readImageJK()
yMax = yMaxCoord
mFrame = MAX(s.iFrame)
dY = (yMaxCoord-yMin)/nB
yBins = DINDGEN(nB)*dY+yMin + dY/2
distInMM = yBins*scale
afreq=0.0d;


;p0=plot(afreq)
;create the arrays to store position of the shock front
;vs time:
frontT = DBLARR(mFrame+1);
frontPos = DBLARR(mFrame+1);
maxDens = DBLARR(mFrame+1);
FOR i=iBegin, mFrame DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder)
  curY = yMaxCoord - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  curYcic = curY/yMaxCoord*nB; renormalise the coordinate
  ; so that we can use it in the CIC function
  fieldOne = DBLARR(N_ELEMENTS(curY))+1 ; weights for the CIC function 
  freq = CIC(fieldOne, curYcic, nB, /ISOLATED)
; normalizing the number of particles by the bin area
; (i.e. finding number density):
; freq = freq / (yMaxCoord/nB) / (rightBorder-leftBorder)/ (scale^2) 
  p =plot(distInMM,freq, OVERPLOT = 1, YRANGE = [0,140])
  maxv=MAX(freq,maxInd);
  frontT[i] = i;
  frontPos[i] = distInMM[maxInd];
  maxDens[i] = maxv  
  print, i  
  filename = STRCOMPRESS('histo_frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,distInMM,freq)  
  p.Delete; 
  ;
ENDFOR
zv=print3arrays('frontPos.csv',frontT,frontPos,maxDens);
GET_LUN, lunMisc
fname = 'miscParams.txt'
OPENW, lunMisc, fname
PRINTF, lunMisc, 'max density = ', MAX(maxDens,maxDensFn)
PRINTF, lunMisc, 'max density frame number  = ', maxDensFn
PRINTF, lunMisc, 'max density coordinate  = ', frontPos[maxDensFn]
CLOSE, lunMisc
FREE_LUN, lunMisc
minFronWid = 0;
minFronFrame = 0;
minFronPos = 0;
;driver_anshockFront, s


END
