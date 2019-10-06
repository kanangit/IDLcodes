 

;+
; :Description:
;    2016.09.14. 
;     Purpose: find the front position as a point where there is a 
;     jump in density. 
;     Created this procedure by modyfying driver_anshoCICnorm.pro in
;     folder anShockCICnorm04.
;
;
;
;
;
; :Author: Kananovich
;-
pro driver_anshockFront, s
nB = 50;
;scale = 0.0339d
scale = 0.03356d
yMin = 222.0d;
yMax = 1050.0d
speed2 = 4000
;iEquillibr = FLOOR(300.0d*6400/speed2)
;iBegin=CEIL(350.0d*6400/speed2)
iEquillibr = 41
iBegin=42
print, 'iEuillibr=',iEquillibr
print, 'iBegin=',iBegin
wait, 1.0d

yMaxCoord = 2066.0d;
leftBorder = 550.0d
rightBorder= 850.0d;


s=readImageJK()
stop;
mFrame = MAX(s.iFrame)
dY = (yMax-yMin)/nB
yBins = DINDGEN(nB)*dY+yMin + dY/2
distInMM = yBins*scale
afreq=0.0d;

;find the average number density in the equillibrium state
;(before the shock arrives. iBegin is selected such, that 
;there is no shock up untill this frame number):
FOR i=iEquillibr, iEquillibr DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)
  curY = yMax - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  curYcic = curY/yMax*nB; renormalise the coordinate
  ; so that we can use it in the CIC function
  fieldOne = DBLARR(N_ELEMENTS(curY))+1.0d ; weights for the CIC function 
  onefreq = CIC(fieldOne, curYcic, nB, /ISOLATED)
  ;scale so that the result is number density in particles per mm^2:
  onefreq = onefreq / (yMax/nB) / (rightBorder-leftBorder)/ (scale^2)
  afreq = afreq + onefreq 
ENDFOR
;afreq=afreq/(iEquillibr+1)
mAfreq = MEDIAN(afreq)


print, 'mAfreq=', mAfreq


;create the arrays to store position of the shock front
;vs time:
frontT = DBLARR(mFrame+1);
frontPos = DBLARR(mFrame+1);
frontWid = DBLARR(mFrame+1);
frontBinNum = DBLARR(mFrame+1);
FOR i=iBegin, mFrame DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)
  curY = yMax - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  curYcic = curY/yMax*nB; renormalise the coordinate
  ; so that we can use it in the CIC function
  fieldOne = DBLARR(N_ELEMENTS(curY))+1 ; weights for the CIC function 
  freq = CIC(fieldOne, curYcic, nB, /ISOLATED)
; normalizing the number of particles by the bin area
; (i.e. finding number density):
;  freq = freq / (yMax/nB) / (rightBorder-leftBorder)/ (scale^2)
;  freq=freq/afreq
;  p =plot(distInMM,freq, OVERPLOT = 1,YRANGE = [0,40])
  p =plot(distInMM,freq, OVERPLOT = 1, YRANGE = [0,160], XRANGE = [0,yMax*scale])
; now we are going to find the approximate position of the shock front:
; within the precision posPrec
  maxn=MAX(freq,maxInd);
  posPrec = maxn / 20.0d
  mFreq = MEDIAN(freq) ; median number density 
  halfMax = (maxn + mFreq) / 2 ; half maximum
  frontInd = findFrontPos(freq,halfMax,posPrec); here, we found it!  
  print, "frontInd=", frontInd   
  frontT[i] = i;
  frontBinNum[i]=frontInd;
  frontPos[i] = distInMM[frontInd];
  frontWid[i]= (distInMM[frontInd]-distInMM[maxInd])*2 
  print, "frame number =", i 
  p1 =plot([distInMM[frontInd]],[freq[frontInd]], OVERPLOT = 1, SYMBOL='+', COLOR='red', LINESTYLE='none', THICK=10, XRANGE = [0,yMax*scale], YRANGE = [0,160])
  filename = 'junk.csv'
  filename = STRCOMPRESS('histo_frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,distInMM,freq)   
;  p.Delete;
;  p1.Delete;

  ;
ENDFOR

zv=print3arrays('edge_frontPos.csv',frontT,frontPos,frontWid);
seekMinWidthArrayInd = WHERE((frontT GT iBegin) AND (frontT LT (mFrame-5)) AND (frontWid GT 0.0d))
seekMinWidthArray = frontWid[seekMinWidthArrayInd]
minFronWid = MIN(seekMinWidthArray,minFrontFn)
minFronFrame = seekMinWidthArrayInd[minFrontFn]
minFronPos = frontPos[minFronFrame] 

GET_LUN, lunMisc
fname = 'miscParamsWid.txt'
OPENW, lunMisc, fname
PRINTF, lunMisc, 'min front width  = ', minFronWid
PRINTF, lunMisc, 'min front frame number  = ', minFronFrame
PRINTF, lunMisc, 'min front position  = ', minFronPos
CLOSE, lunMisc
FREE_LUN, lunMisc
END
