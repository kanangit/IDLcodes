pro driver_anshoMovie
nB = 40;
scale = 0.0339d
yMin = 0;
iBegin=100;
;yMax = 896;
yMaxCoord = 896;


s=readImageJK()
yMax = MAX(s.Y)
mFrame = MAX(s.iFrame)
dY = (yMax-yMin)/nB
yBins = DINDGEN(nB)*dY+yMin + dY/2
distInMM = yBins*scale
afreq=0.0d;
FOR i=0, iBegin DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE 700 AND s.X GE 420)
  curY = yMax - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  afreq = HISTOGRAM(curY,NBINS = nB, MAX = yMax, MIN = yMin) +afreq  
  ;
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
  ind= WHERE(s.iFrame EQ i AND s.X LE 700 AND s.X GE 420)
  curY = (yMax - s.Y[ind])*scale ; because the vertical screen coordinates
  curX = s.X[ind]*scale
  ;are from top to bottom, we make this change of variables    
  ;freq=freq/afreq
  print, i  
  filename = STRCOMPRESS('frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,curX,curY) 
  ;
ENDFOR

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