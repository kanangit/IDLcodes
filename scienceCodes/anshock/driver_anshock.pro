pro driver_anshock
nB = 50;
;scale = 0.0339d
scale = 0.02543d
yMin = 0.0d;
iEquillibr = 343
iBegin=450;
;yMax = 896;
yMaxCoord = 1200.0d;
leftBorder = 600.0d
rightBorder= 1600.0d;


s=readImageJK()
yMax = yMaxCoord
mFrame = MAX(s.iFrame)
dY = (yMaxCoord-yMin)/nB
yBins = DINDGEN(nB)*dY+yMin + dY/2
distInMM = yBins*scale
afreq=0.0d;

FOR i=0, iEquillibr DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder)
  curY = yMax - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  afreq = HISTOGRAM(curY,NBINS = nB, MAX = yMax, MIN = yMin) +afreq  
  ;
ENDFOR
afreq=afreq/(iBegin+1)
saf = N_ELEMENTS(afreq) ; DELETE THIS STRING AFTER DEBUG
afreq[saf-1]=1 ; DELETE THIS STRING AFTER DEBUG

FOR i=iBegin, mFrame DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder)
  curY = yMaxCoord - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  freq = HISTOGRAM(curY,NBINS = nB, MAX = yMax, MIN = yMin)
  freq = freq / (yMaxCoord/nB) / (rightBorder-leftBorder)/ (scale^2)
  print, i
  p =plot(distInMM,freq, OVERPLOT = 1)
  filename = STRCOMPRESS('NONCIC_histo_frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,distInMM,freq)
  p.Delete; 
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