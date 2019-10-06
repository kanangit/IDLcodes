pro density1D

nB = 20;
scale = 0.0273d

s=readImageJK()
xMax = MAX(s.X)
xMin=MIN(s.X)
dX = (xMax-xMin)/nB
prav = xMin+nB*dX
mFrame = MAX(s.iFrame)
xBins = DINDGEN(nB)*dX+xMin + dX/2
distInMM = xBins*scale
freq = DBLARR(nB)
cBin=xMin+dX/2
FOR i=0, mFrame DO BEGIN
  ind=WHERE(s.iFrame EQ i)
  curX = s.X[ind]
  freq = HISTOGRAM(curX,NBINS = nB, MAX = xMax, MIN = xMin)
  print, i
  p =plot(freq, OVERPLOT = 1)
  filename = STRCOMPRESS('frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,distInMM,freq)
  ;
ENDFOR
p.Close
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

