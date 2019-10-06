
;v0.14
;2018.09.05 created
; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, September 2017
;           Modified:    Anton Kananovich, May 2018.
;           Modified:    Anton Kananovich, 10 September, 2018. Version 0.11
;           Replaced the find_vel() function with the find_velo().
;           Made necessery adjustments to the code. Corrected a bug
;           (duplicate records in the array)
;
;-

PRO driver_an_ovitoPrep

  curDate='20180910'
  myFrame = 1143d
  iBegin=1133
  iEnd = 1153;
  leftBorder = 550.0d
  rightBorder= 850.0d;
  yMin = 222.0d;
  yMax = 1050.0d
  
  framestepOver2 = 5
  awzPixel = 7.191d ;Wigner-Zeiss radius in pixels
  bWidth = 5.0d * awzpixel ;
  coreName = STRCOMPRESS(curDate+'partiles_'+'_ff'+STRING(myFrame))
  CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_14226_456\analysis\analysis20180906ovitoPrep\05_an_ovitoprep\inputs'
  
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
  ncols = 3
  s = readImageJK(/lowmem);
  CD, '..\outputs'
  
  ;iBegin = MIN(s.iFrame)
  
  ;we need only the data inside the region of interest PLUS fat border
  ;width. We need the particles inside the border in order to calculate
  ;the potential part of the pxx and pyy. We will get rid of the
  ;excessive particles later, after we calculate pxx and pyy.
  ind = WHERE(s.X LE rightBorder - bWidth AND s.X GE leftBorder + bWidth $
    AND s.Y LE ymax + bWidth AND s.Y GE yMin - bWidth )
;  prepare the array with a structure compatible to that of the
;  the Crokcer's track() function input array:
  arrlen = N_ELEMENTS(s.X[ind]);
  trackArr = DBLARR(ncols,arrlen)
  trackArr[0,0] = TRANSPOSE(s.X[ind])
  trackArr[1,0] = TRANSPOSE(yMax - (s.Y[ind] - yMin)) ;because the
  ;vertical screen coordinates ;are from top to bottom, we make this
  ; change of variables
  trackArr[2,0] = TRANSPOSE(s.iFrame[ind])
  s = 0; ;save the memory
  
  FOR i=iBegin + framestepOver2, iEnd - framestepOver2 - 1 DO BEGIN
    fuli = get_all_f_vels(trackArr, i, framestepOver2)
    IF (flag_mexist EQ 1)THEN fularr = [[fularr],[fuli]]
    if (flag_mexist EQ 0) then begin
      fularr = fuli
      flag_mexist = 1
    endif
    
  ENDFOR
  stop
  ;find the points in time (i.e. frames), contained in the final array of data:
  times = fularr[2,UNIQ(fularr[2,*], SORT(fularr[2,*]))] ; we don't use it YET
  
  ;select the data containing only the specific frame
  indMyFrame = WHERE(fularr[2,*] EQ myFrame)
  arrMyFrame = fularr[*,indMyFrame]
  
  
  
  
  x_c = TRANSPOSE(arrMyFrame[0,*])
  y_c = TRANSPOSE(arrMyFrame[1,*])
  z_c = DBLARR(N_ELEMENTS(y_c))
  t_c = TRANSPOSE(arrMyFrame[2,*])
  name_c = TRANSPOSE(arrMyFrame[3,*])
  vx_c = TRANSPOSE(arrMyFrame[4,*])
  vy_c = TRANSPOSE(arrMyFrame[5,*])
  ax_c = TRANSPOSE(arrMyFrame[6,*])
  ay_c = TRANSPOSE(arrMyFrame[7,*])
  name = STRCOMPRESS(coreName+'.xyz')
  name = STRCOMPRESS(name)
  fnameparam = STRCOMPRESS(coreName+'_params.csv')
  no_particles = N_ELEMENTS(y_c)
  zero = print8xyz(name,'no comments', no_particles, x_c, y_c, z_c, name_c, vx_c, vy_c, ax_c, ay_c)
  print, 'no_particles =',no_particles
  
  sumBulkVel = TOTAL(vy_c)
  WRITE_CSV, fnameparam, [no_particles,sumBulkVel]
  
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
  retArr = [xFit,yFit,t0,dataArr[3,0],vxFit,vyFit,coeffsx[2]*2.0d,coeffsy[2]*2.0d]
  RETURN, retArr
END

FUNCTION get_all_f_vels, trackArr, frame, halfInterval
  ; trackarr - input array consistion of columns of date in the following
  ;order: x-coordinate, y-coordinate, framenumber
  ;frame - current frame we are getting velocities in
  ;half-interval - number of frames on the left and right of the frame
  ;used in interpolation (see function find_velInterp).  
  
  indf = WHERE(trackArr[2,*] GE frame - halfInterval AND trackArr[2,*] LE frame + halfInterval)
  curArr = trackArr[*,indf]
  res = track(curArr,4.0d)
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