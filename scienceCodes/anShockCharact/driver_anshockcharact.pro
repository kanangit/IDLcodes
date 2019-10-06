;+
; :Description:
;    2018.03.23. 
;     Purpose: find the front position as a point where there is a 
;     jump in density, along with other parameters. 
;     Created this procedure by modyfying driver_anshockFront.pro in
;     folder anShockFront12.
;
;
;
;
;
; :Author: Kananovich
;-
pro driver_anShockCharact, s
;nB = 50;
;scale = 0.03356d
scale = 1.0d / 7.191d ;scale in Wigner-Zeiss radii
yMin = 222.0d;
yMax = 1050.0d
dY = (1/scale)*2.0d
nB = FLOOR((yMax - yMin)/dY)
;iEquillibr = FLOOR(300.0d*6400/speed2)
;iBegin=CEIL(350.0d*6400/speed2)
iEquillibr = 767
iBegin=768
print, 'iEuillibr=',iEquillibr
print, 'iBegin=',iBegin
print, 'nB=',nB
wait, 1.0d

;yMaxCoord = 2066.0d;
leftBorder = 550.0d
rightBorder= 850.0d;


s=readImageJK()
;stop;
mFrame = MAX(s.iFrame)

yBins = DINDGEN(nB)*dY+yMin + dY/2
distInMM = yBins*scale


;create the arrays to store position of the shock front
;vs time:
frontT = DBLARR(mFrame+1);
maxdenPos = DBLARR(mFrame+1);
frontPos = DBLARR(mFrame+1);
maxDen = DBLARR(mFrame+1);
curhistS = {X:DBLARR(nB),Y:DBLARR(nB)}; structure to keep current
;  histogram data
curhistS.X = distInMM
FOR i=iBegin, mFrame DO BEGIN
  ind= WHERE(s.iFrame EQ i AND s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)
  curY = yMax - s.Y[ind] ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  curYcic = curY/yMax*nB; renormalise the coordinate
  ; so that we can use it in the CIC function
  fieldOne = DBLARR(N_ELEMENTS(curY))+1 ; weights for the CIC function 
  freq = CIC(fieldOne, curYcic, nB, /ISOLATED)
  curhistS.Y = freq
  
  p =plot(distInMM,freq, OVERPLOT = 1, YRANGE = [0,160], XRANGE = [0,yMax*scale])
; now we are going to find the approximate position of the shock front:

  maxn=MAX(freq);
  indarrMaxn = WHERE(freq EQ maxn); find the index of the max density
  indMaxn = indarrMaxn[0]; index as an integer number, not array
  vicinarrS = {X:DBLARR(3),Y:DBLARR(3)}
  vicinarrS.X = [distInMM[indMaxn-1],distInMM[indMaxn],distInMM[indMaxn+1]]
  vicinarrS.Y = [freq[indMaxn-1],freq[indMaxn],freq[indMaxn+1]]

  maxdens = findmaxp(vicinarrS)
  front = findFrontMR(curhistS)


  
  maxdenPos[i] = maxdens.X
  maxDen[i] = maxn
  frontPos[i] = front.X 
  frontT[i] = i;


  
  print, "frame number =", i 
  

  filename = STRCOMPRESS('histo_frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,distInMM,freq)   
;  p.Delete;
;  p1.Delete;

  ;
ENDFOR
zv=print3arrays('front_points.csv',frontT,maxdenPos,frontPos);
zm=print3arrays('peakTimePos.csv',frontT,maxdenPos,maxDen);



END
