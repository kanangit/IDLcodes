;+
; :Description:
; ; v.0.21
; v.0.20
; v.0.19 2018.09.17 Added the flip keyword
; v.0.18 2018.09.17 debug
; v.0.17 debug
; v.0.16
; v.15 Serious bug corrected
; v.14 sAllmicro is a anonimous structure again
; v.10
; v.09 Added name allmicro to the definition of the sAllmicro structure
; (before it was anonimous)
; v.08 Expanded Corename variable
;v0.07 Bug in the border definition corrected
;v0.06 I am not sure if there is no error in pxx and pyy estimation
;(especially the potential parts)
;code descended from the driver_an_ovitoPrep v 0.14 on 2018.09.10
;the main data container of the procedure is the array fularr.
;It has all the microscopic (per particle) information.
;The procedure populates the columns of the array and saves
;it in a file .sav
;Currently (2018.09.10) the array fularr has 12 columns and contains
;the following data:
;fularr[0,*] - x
;fularr[1,*] - y
;fularr[2,*] - frame number
;fularr[3,*] - particle identifier (number). Should be unique for a
; given frame
;fularr[4,*] - vx
;fularr[5,*] - vy
;fularr[6,*] - ax
;fularr[7,*] - ay
;fularr[8,*] - pxx kinetic part
;fularr[9,*] - pyy kinetic part
;fularr[10,*] - pxx potential part
;fularr[11,*] - pyy potential part
;
;
;
;
; :Author: Anton Kananovich
;-
PRO driver_allMicro, flip = flip
  curDate='20180917'
  iBegin=1000
  iEnd = 1060;
  leftBorder = 550.0d
  rightBorder= 850.0d;
;    yMin = -600.0d;
;    yMax = 600.0d
;  yMin = 0.0d;
;  yMax = 1250.0d
  yMin = -600.0d;
  yMax = 600.0d
  framestepOver2 = 5
  awzPixel = 7.191d ;Wigner-Zeiss radius in pixels
  kappaPixel = awzpixel / SQRT(2.0d * !DPI / SQRT(3.0d))
  bWidth = awzPixel*5.0d
  scaleMeters = (1.0d / 29.790d) / 1000.0d
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
  coreName = STRCOMPRESS(curDate+'allmicro_'+'ff_'+STRING(iBegin+framestepOver2)+'-'+STRING(iEnd-framestepOver2)+'_', /REMOVE_ALL)
  CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_fakeParticles_debug\04_an_allMicro'
  CD, 'inputs'
  
  ;variables used later:
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
  ncols_initial = 3
  ncols = 12
  s = readImageJK(/lowmem);
  CD, '..\outputs'
  
  ;iBegin = MIN(s.iFrame)
  
  ;we need only the data inside the region of interest PLUS fat border
  ;width. We need the particles inside the border in order to calculate
  ;the potential part of the pxx and pyy. We will get rid of the
  ;excessive particles later, after we calculate pxx and pyy.
  ind = WHERE(s.X LE rightBorder + bWidth AND s.X GE leftBorder - bWidth $
    AND s.Y LE ymax + bWidth AND s.Y GE yMin - bWidth )
;    stop
  ;  prepare the array with a structure compatible to that of the
  ;  the Crokcer's track() function input array:
  arrlen = N_ELEMENTS(s.X[ind]);
  trackArr = DBLARR(ncols_initial,arrlen)
  trackArr[0,0] = TRANSPOSE(s.X[ind])
  IF KEYWORD_SET(flip) THEN BEGIN
    trackArr[1,0] = TRANSPOSE(yMax - (s.Y[ind] - yMin)) ;because the
  ;vertical screen coordinates ;are from top to bottom, we make this
  ; change of variables
  set = 1
;  stop
  ENDIF ELSE BEGIN
    trackArr[1,0] = TRANSPOSE(s.Y[ind])
    set = 0
;    stop
  ENDELSE
  trackArr[2,0] = TRANSPOSE(s.iFrame[ind])
  s = 0; ;save the memory
  
  FOR i=iBegin + framestepOver2, iEnd - framestepOver2 - 2 DO BEGIN
    print, 'Frame No', i
;    stop
    fuli = get_all_f_vels(trackArr, i, framestepOver2,ncols)
    ;    fuli = get_all_f_ptensor(TEMPORARY(fuli), i, bWidth, scaleMeters, m, Lambda, kQ2)
    IF (flag_mexist EQ 1)THEN fularr = [[fularr],[fuli]]
    if (flag_mexist EQ 0) then begin
      fularr = fuli
      flag_mexist = 1
    endif
;   stop 
  ENDFOR
  ;  STOP
  
  ;  Now that the potential parts of the pxx and pyy found, we can get rid
  ;  of the particles laying on the border:
  
  indstripped = WHERE(fularr[0,*] LE rightBorder AND $
    fularr[0,*] GE leftBorder AND fularr[1,*] LE ymax $
    AND fularr[1,*] GE yMin)
  fularr = TEMPORARY(fularr[*,indstripped])
  
  ;Prepare to save the obtained data to a file:
  ;append the number of secods since January 1 1970 to make the
  ;filename distinguishable:
  seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
  fnam = STRCOMPRESS(corename+seconds + '.sav',/REMOVE_ALL)
  ;  Create structure sAllmicro, where we will store all the data
  
  
  sAllmicro = {date:'',filename:'',halfinterval:0d,fularr:TEMPORARY(fularr)}
  sAllmicro.date = curDate
  sAllmicro.filename = fnam
  sAllmicro.halfinterval = framestepOver2
  ;  stop
  SAVE, sAllmicro, filename = fnam
  stop
END

FUNCTION find_velInterp, dataArr, t0

  t = DOUBLE(TRANSPOSE(dataArr[2,*])) - t0
  x = DOUBLE(TRANSPOSE(dataArr[0,*]))
  y = DOUBLE(TRANSPOSE(dataArr[1,*]))
  coeffsx = POLY_FIT(t,x,2,/DOUBLE); coeffs
  coeffsy = POLY_FIT(t,y,2,/DOUBLE); coeffs
  xFit = coeffsx[0]
  vxFit = coeffsx[1]
  yFit = coeffsy[0]
  vyFit = coeffsy[1]
  
  ;building the output array
  
  dimen = SIZE(dataArr)
  ;t0 row:
  indT0 = WHERE(dataArr[2,*] EQ t0)
  ;Check if two dimensional.
  IF dimen[0] NE 2 THEN $
    MESSAGE, 'Incorrect array size!'
  ;Get number of columns
  arrCols = dimen[1]
  retArr = DBLARR(arrCols)
  FOR iter = 8, arrCols - 1 DO BEGIN
    retArr[iter] = dataArr[iter,indT0]
  ENDFOR
  
  retArr[0] = xFit
  retArr[1] = yFit
  retArr[2] = t0
  retArr[3] = dataArr[3,0]
  retArr[4] = vxFit
  retArr[5] = vyFit
  retArr[6] = coeffsx[2]*2.0d
  retArr[7] = coeffsy[2]*2.0d
  
  RETURN, retArr
END

FUNCTION get_all_f_vels, trackArr, frame, halfInterval, outputArrayDimension
  ; trackarr - input array consistion of columns of date in the following
  ;order: x-coordinate, y-coordinate, framenumber
  ;frame - current frame we are getting velocities in
  ;half-interval - number of frames on the left and right of the frame
  ;used in interpolation (see function find_velInterp).

  indf = WHERE(trackArr[2,*] GE frame - halfInterval AND trackArr[2,*] LE frame + halfInterval)
  curArr = trackArr[*,indf]
  resTrack = track(curArr,4.0d)
  
  ;building the output array with the given number of columns:
  nelem = N_ELEMENTS(resTrack[0,*])
  res = DBLARR(outputArrayDimension,nelem)
  dimen = SIZE(resTrack)
  ;Check if two dimensional.
  IF dimen[0] NE 2 THEN $
    MESSAGE, 'Incorrect array size!'
  ;Get number of columns
  trackCols = dimen[1]
  FOR iter = 0, trackCols - 1 DO BEGIN
    res[iter,0] = resTrack[iter,*]
  ENDFOR
  
  resTrack = 0 ; save the memory
  ; get minimal and maximal index ("name") of a particle in the frame:
  minpindex = MIN(res[3,*])
  maxpindex = MAX(res[3,*])
  flag_exist = 0
  fuli = 0
  ;  cycle through all particles and  calculate velocities, accelerations
  ;  (we don't need accelerations, but let them be) and store all
  ;  information in a single array fuli
  FOR index = minpindex, maxpindex DO BEGIN
    indp = WHERE(res[3,*] EQ index )
    ;find_velInterp() only can calculate the velocity of particles
    ; tracked for at least 3 frames:
    IF (N_ELEMENTS(indp) GE 3) THEN BEGIN
      ;    select the part of the array containing only the track of the current
      ;    particle:
      resp = res[*,indp]
      resvelp = find_velInterp(resp,frame)
      IF (flag_exist EQ 1)THEN fuli = [[fuli],[resvelp]]
      IF (flag_exist EQ 0) THEN BEGIN
        fuli = resvelp
        flag_exist = 1
      ENDIF
    ENDIF
  ENDFOR
  
  RETURN, fuli
END


FUNCTION get_all_f_ptensor, trackArr, frame, bWidth, scaleMeters, m, Lambda, kQ2, NOFRAMESELECTION = NOFRAMESELECTION
  ;calculate data for pxx and pxy
  ;distances to the  closest neighbours:
  ;
  ;If the user doesn't want the function to select only the given frame date,
  ;she can set the key word NOFRAMESELECTION
  IF (KEYWORD_SET(NOFRAMESELECTION)) THEN BEGIN
    curArr = TEMPORARY(trackArr)
  ENDIF ELSE BEGIN
    indf = WHERE(trackArr[2,*] EQ frame)
    curArr = TEMPORARY(trackArr[*,indf])
  ENDELSE
  ; k is the unique particle name (nuber) within the current frame
  kmax = MAX(curArr[3,*])
  kmin = MIN(curArr[3,*])
  FOR k = kmin, kmax DO BEGIN
    k_inda = WHERE(curArr[3,*] EQ k)
    IF N_ELEMENTS(k_inda) NE 1 THEN BEGIN
      print, 'ERROR! multiple records for the same particle!'
      stop
    ENDIF ELSE BEGIN
      k_ind = TEMPORARY(k_inda[0])
    ENDELSE
    xk = curArr[0,k_ind]
    yk = curArr[1,k_ind]
    indNeighb = WHERE(curArr[2,*] EQ frame $
      AND (xk - curArr[0,*])^2 + (yk - curArr[1,*])^2  LE bWidth^2 $
      AND  (xk - curArr[0,*])^2 + (yk - curArr[1,*])^2 GT 0.0d )
    xDisArr          = curArr[0,indNeighb] - xk
    yDisArr          = curArr[1,indNeighb] - yk
    RDisArr          = sqrt((xDisArr)^2+(yDisArr)^2)
    curArr[8,k_ind]  = m*(scaleMeters * curArr[4,k_ind])^2
    curArr[9,k_ind]  = m*(scaleMeters * curArr[5,k_ind])^2
    curArr[10,k_ind] = TOTAL(-kQ2/2.0d*RdisArr*(1.0d/lambda+1.0d/RdisArr)*exp(-RdisArr/Lambda)*xDisArr^2/RDisArr)
    curArr[11,k_ind] = TOTAL(-kQ2/2.0d*RdisArr*(1.0d/lambda+1.0d/RdisArr)*exp(-RdisArr/Lambda)*yDisArr^2/RDisArr)
  ENDFOR
  RETURN, curArr
END