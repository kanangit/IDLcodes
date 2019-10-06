; v1.19 Estimate the quality of velocities calculation using 
; the continuity equation. Transformed the coordinates to pixels

PRO driver_an_checkvelocities

;define borders of the region of interest
leftBorder = 550.0d
rightBorder= 850.0d;
yMin = -828.0d;
yMax = 828.0d

framestep = 8 ;number of frames to skip
frameRate = 800;
awzPixel = 7.191d ;Wigner-Zeiss radius in pixels
kappaPixel = awzpixel / SQRT(2.0d * !DPI / SQRT(3.0d))
scale = 1.0d
;scale = 1.0d / awzpixel ;scale in Wigner-Zeiss radii
bWidth = 5.0d * awzpixel ; border width along the region of interest.
;It Used in calculating pressure pxx and pyy
scaleMeters = (1.0d / 29.790d) / 1000.0d
scaleMM = scaleMeters * 1000.0d
lambda = scaleMeters * awzPixel / kappaPixel ; screening length
m = DOUBLE(5.188e-13); kg
kB = DOUBLE(1.38e-23);J/K
Q = DOUBLE(14974.3d * 1.60217E-19) ;charge
clight = DOUBLE(2.9979E8) ;light speed
eps0 = DOUBLE(1.0E7/4.0d/!DPI/clight^2) ; dielectric permittivity
;  of vacuum
kconst = 1.0d / 4.0d / !DPI / eps0 ; coefficient of proportionality
;  in the Coulomb law
kQ2 = kconst * Q^2; define this constant so that we don't
;  recalculate it in the cycles
potEnergy = kQ2/(awzPixel*scaleMeters)
potEnergyInDegrees = potEnergy / kB


dt = DOUBLE(framestep) / DOUBLE(framerate)
;dY = (1/scale)*2.0d
dY = (1/scale)*2.0d*awzPixel
nB = FLOOR((yMax - yMin)/dY);

iEquillibr = 767
iBegin=958
iEnd = 1240
yBins = DINDGEN(nB)*dY+yMin + dY/2

cutpulwid = 100.0d

;variable to store array dimension value:
arrlen = 0
ncols = 3 ;number of columns in the array which stores all the data  
distInMM = yBins*scale; x coordinate in physical units

;input the data generated by the imageJ
s = readImageJK(/lowmem);
stop
;iBegin = MIN(s.iFrame)
;mFrame = MAX(s.iFrame)
mFrame = iEnd
;we need only the data inside the region of interest
ind = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)               
arrlen = N_ELEMENTS(s.X[ind]);              

;prepare the input array to use with the Crokcer's track() function:

trackArr = DBLARR(ncols,arrlen)

trackArr[0,0] = TRANSPOSE(s.X[ind])

;trackArr[1,0] = TRANSPOSE(yMax - (s.Y[ind] - yMin)) ;because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables
  
trackArr[1,0] = TRANSPOSE(s.Y[ind]) ; we are now using transformed
;  coordinates, so no need to transform them

trackArr[2,0] = TRANSPOSE(s.iFrame[ind])

s = 0; ;save the memory

;indf = WHERE(trackArr[2,*] GE 999 AND trackArr[2,*] LE 1004)
;curArr = trackArr[*,indf]
;stop
;res = track(curArr,4.0d)
;indOne = WHERE(res[3,*] EQ 0)
;resOne = res[*,indOne]
;res = find_vel(resOne)


;indSpec = WHERE(res[2,*] EQ 999)
;frameSpec = res[*,indSpec]
;x = TRANSPOSE(frameSpec[0,*])
;y = TRANSPOSE(frameSpec[1,*])
;p1 = PLOT(y,x, LINESTYLE = 'none', SYMBOL = 'o', XTickLen=1.0, YTickLen=0 , XGridStyle=1, XMinor=0, YMinor=0)

fularr = 0
fuli = 0
flag_exist = 0
flag_mexist = 0
iterCounter = 0
nplus1 = 0
nminus1 = 0
n = 0
nvplus1 = 0
nvminus1 = 0
nv = 0
p4 = Plot([0],[0])
FOR i=iBegin, mFrame -framestep-2 DO BEGIN
indf = WHERE(trackArr[2,*] GE i AND trackArr[2,*] LE i+frameStep)
curArr = trackArr[*,indf]
res = track(curArr,4.0d)

minpindex = MIN(res[3,*])
maxpindex = MAX(res[3,*])
for index = minpindex, maxpindex do begin
  indp = WHERE(res[3,*] EQ index )
  if (N_ELEMENTS(indp) GE 3) then begin
    resp = res[*,indp]
    resvelp = find_vel(resp)
    IF (flag_exist EQ 1)THEN fuli = [[fuli],[resvelp]]
    if (flag_exist EQ 0) then begin
      fuli = resvelp
      flag_exist = 1
    endif
  endif  
endfor

IF (flag_mexist EQ 1)THEN fularr = [[fularr],[fuli]]
if (flag_mexist EQ 0) then begin
   fularr = fuli
   flag_mexist = 1
endif
;building histogram using cloud-in-cell (cic):
YforHist = TRANSPOSE(fuli[1,*] - yMin)/(yMax-yMin)*nB
weighNumDens = DBLARR(N_ELEMENTS(YforHist))+1 ; weights for the number density

fieldVy = TRANSPOSE(fuli[5,*]) * scaleMM
histNumDens = CIC(weighNumDens, YforHist, nB, /ISOLATED)
histVy = CIC(fieldVy, YforHist, nB, /ISOLATED, /AVERAGE)
;p =plot(distInMM,histVy, OVERPLOT = 1, XRANGE = [0,120])
;p =plot(distInMM,histVy, OVERPLOT = 1)
;p2 = plot(distInMM,histNumDens)
itercounter++
nminus1 = n
n = nplus1
nplus1 = histNumDens
dndt = (nplus1 - nminus1) / 2.0d
nvminus1 = nv
nv = nvplus1
nvplus1 = histNumDens * histVy
IF (itercounter GE 3) THEN BEGIN
dnvdx = DERIV(distInMM,nv)
savgolFirstFilter = SAVGOL(1, 1, 1, 2, /DOUBLE) ; savgol filter for
; Savitsky-golay filer for 1st derivative, 3rd order polynomial
;and 3 point before and 3 points after for smoothening
savgolFirstDeriv = CONVOL(nv, savgolFirstFilter, /EDGE_TRUNCATE)
;calculating the time derivtive using Savitsky-Golay:
dndtSavgol = DBLARR(N_ELEMENTS(n))
for index = 0L, N_ELEMENTS(n)-1 do begin
  nimin1 = nminus1[index]
  ni = n[index]
  niplu1 = n[index]
  savgolTimeDer = CONVOL([nimin1,ni,niplu1],savgolFirstFilter, /EDGE_TRUNCATE)
  dndti = savgolTimeDer[1]
  dndtSavgol[index] = dndti
;  stop
endfor

;p1 = plot(distInMM,-dnvdx, OVERPLOT = 1, Color = 'red')
;p2 = plot(distInMM,dndt, OVERPLOT = 1, Color = 'blue')
;p3 = plot(distInMM,-savgolFirstDeriv, OVERPLOT = 1, Color = 'yellow')
;p4 = plot(distInMM,dndtSavgol, OVERPLOT = 1, Color = 'black')
p4.close
p4 = plot(distInMM,n, OVERPLOT = 1, Color = 'black', XRANGE = [220,1050])
testa = DBLARR(2,N_ELEMENTS(n))
testa[0,0] = TRANSPOSE(distinmm[*])
testa[1,0] = TRANSPOSE(n[*])
resul = getpulsecenter(testa,cutpulwid)
p4 = plot(resul[0,*],resul[1,*],color='blue',/overplot,thick=4)

print, " "
print, ''
print,'frame = ',i
print, ''

ENDIF

fuli = 0;
flag_exist = 0

ENDFOR

stop
END