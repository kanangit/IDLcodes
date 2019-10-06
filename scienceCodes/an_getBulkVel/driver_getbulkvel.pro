;v.0.04 2018.09.17
;v.0.03 2018.09.17 debug on the claster
;2018.09.12. Estimate sum bulk velocity to get the idia how much energy
;gives the pistion to the particle cloud
PRO driver_getBulkVel, path, aWignerZeiss, leftBorder, rightBorder, yMin, yMax, framestep, binwAWZ, flip = flip
  curDate='20180914'
  aWignerZeiss = 7.191d
  leftBorder = 0.0d
  rightBorder = 1368.0d
  ;  leftBorder = 550.0d
  ;  rightBorder = 850.0d
  myFrame = 1143d
  yMin = 0.00d
  yMax = 1250.0d
  b = 0.25d
  
  
  
  framestep = 1
  ;  coreName = STRCOMPRESS(curDate + 'bulkVel' + '_ff'+STRING(iBegin)+'-' + STRING(iEnd))
  coreName = STRCOMPRESS(curDate+'partiles_'+'_ff'+STRING(myFrame))
  pistonStopFrame = 917
  CD, 'D:\kananovich\expAnalysis\analysis20180913bulkVel\03_an_getBulkVel\'
  CD, 'inputs'
  path = DIALOG_PICKFILE(/READ, FILTER = '*.sav')
  
  
  
  dirpath = FILE_DIRNAME(path)
  CD, dirpath
  
  
  RESTORE, path
  CD, '..\outputs'
  fularr = sAllmicro.fularr
  iBegin = MIN(fularr[2,*])
  iEnd = MAX(fularr[2,*])
  
  ;stop
  indROI = WHERE(fularr[0,*] LE rightBorder AND fularr[0,*] GE leftBorder $
    AND fularr[1,*] LE ymax AND fularr[1,*] GE yMin)
    
    
  ful_vy = TRANSPOSE(fularr[5,indROI])
  ful_times =  TRANSPOSE(fularr[2,indROI])
  
  bulk_vy = DBLARR(iEnd-iBegin)
  bulk_vyNorm = DBLARR(iEnd-iBegin)
  frame = DBLARR(iEnd-iBegin)
  arr_nparticles = DBLARR(iEnd-iBegin)
  
  
  FOR i = iBegin, iEnd - frameStep DO BEGIN
    ;building histogram using cloud-in-cell (cic):
    indf = WHERE(ful_times GE i AND ful_times LE i+frameStep-1)
    roi_vy = ful_vy[indf]
    roi_times = ful_times[indf]
    nparticles = N_ELEMENTS(roi_vy)
    arr_nparticles[i-iBegin] = nparticles
    bulk_vy[i-iBegin] = TOTAL(roi_vy)
    bulk_vyNorm[i-iBegin] = TOTAL(roi_vy) / DOUBLE(nparticles)   
    frame[i-iBegin] = i - pistonStopFrame
    print, 'frame = ', i
    
  ENDFOR
  ;save data to file:
  arrayData = {frame:TEMPORARY(frame), nparticles:TEMPORARY(arr_nparticles), bulk_vy:TEMPORARY(bulk_vy), bulk_vyNorm:TEMPORARY(bulk_vyNorm)}
  ;append the number of secods since January 1 1970 to make the
  ;filename distinguishable:
  seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
  fnam = STRCOMPRESS('bulk_times' + seconds + '.csv',/REMOVE_ALL)
  fnamSav = STRCOMPRESS('bulk_times' + seconds + '.sav',/REMOVE_ALL)
  CD, STRCOMPRESS(dirpath+'\..\outputs\')
  WRITE_CSV, fnam, arrayData
  SAVE, arrayData, Filename = fnamSav
  
  stop
  
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
  print, [no_particles,sumBulkVel]
  stop
END

