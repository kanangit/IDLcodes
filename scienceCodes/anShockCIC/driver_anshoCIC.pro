pro driver_anshoCIC
;nB = 40;
;;scale = 0.0339d
;;scale = 0.02543d
;scale = 1.0d;
;yMin = 0;
;iBegin=41;
;;yMax = 896;
;yMaxCoord = 1200;
;leftBorder = 550.0d
;rightBorder= 850.0d;

nB = 10;
;scale = 0.0339d
;scale = 0.02543d
scale = 1.0d;
yMin = 288.0d;
iBegin=42;
iEquillibr = 41;
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
FOR i=0, iBegin DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder)
  curY = yMaxCoord - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  afreq = HISTOGRAM(curY,NBINS = nB, MAX = yMaxCoord, MIN = yMin) +afreq   ;
ENDFOR
afreq=afreq/(iBegin+1)
saf = N_ELEMENTS(afreq) ; DELETE THIS STRING AFTER DEBUG
afreq[saf-1]=1 ; DELETE THIS STRING AFTER DEBUG
;p0=plot(afreq)
;create the arrays to store position of the shock front
;vs time:
frontT = DBLARR(mFrame+1);
frontPos = DBLARR(mFrame+1);
FOR i=iBegin, mFrame DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder)
  curY = yMaxCoord - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  curYcic = curY/yMaxCoord*nB; renormalise the coordinate
  ; so that we can use it in the CIC function
  fieldOne = DBLARR(N_ELEMENTS(curY))+1 ; weights for the CIC function 
  freq = CIC(fieldOne, curYcic, nB, /ISOLATED)
  maxv=MAX(freq,maxInd);
  frontT[i] = i;
  frontPos[i] = distInMM[maxInd];
    
  ;freq=freq/afreq
  print, i
  p =plot(distInMM,freq, OVERPLOT = 1)
  filename = STRCOMPRESS('frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,distInMM,freq) 
  ;
ENDFOR
zv=print2arrays('frontPos.csv',frontT,frontPos);
END

function print2arrays, filename, x, y
nelemx = N_ELEMENTS(x)
nelemy = N_ELEMENTS(y)
nelem = MIN([nelemx,nelemy])
GET_LUN, lun
OPENW, lun, filename
FOR i=0, nelem -1 DO BEGIN
PRINTF, lun, x[i],',',y[i]
ENDFOR
CLOSE, lun
FREE_LUN, lun

RETURN, 0
END