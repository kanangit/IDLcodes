;+
;;v.0.8 2018.09.16 debug 
;;v.0.7 2018.09.14 one more bug corrected
;v.0.6 2018.19.13. Changed the iteration process for frames for the
;one more clearly understandable be an outsider
;v.0.5 The function is the descendant of getPulseProfiles, v.21
;creation date: 2018.09.11
; :Description:
;    Imports microscopic particle information and builds profiles
;
; :Params:
;    path
;    aWignerZeiss
;    leftBorder
;    rightBorder
;    yMin
;    yMax
;    framestep
;    binwAWZ
;
; :Keywords:
;    flip
;
; :Author: Anton Kananovich
;-
FUNCTION get_allprofiles, path, aWignerZeiss, leftBorder, rightBorder, yMin, yMax, framestep, binwAWZ, flip = flip

  dirpath = FILE_DIRNAME(path)
  CD, dirpath
  binWinterparticle = binwAWZ / SQRT((2.0d*!DPI/SQRT(3.0d)))
  dy = binwAWZ * aWignerZeiss
  area = dy*(rightBorder - leftBorder)
  ;iBegin=759
  ;iBegin=520
  ;iEnd = 1999
  ;iEnd = iBegin + 8*4
  ;frameStep = 1
  nB = FLOOR((yMax - yMin)/dY); number of bins
  yBins = DINDGEN(nB)*dY+yMin + dY/2
  RESTORE, path
  stop
  fularr = sAllmicro.fularr
  iBegin = MIN(fularr[2,*])
  iEnd = MAX(fularr[2,*])
  
  ;stop
  indROI = WHERE(fularr[0,*] LE rightBorder AND fularr[0,*] GE leftBorder $
    AND fularr[1,*] LE ymax AND fularr[1,*] GE yMin)
    
  arrlen = N_ELEMENTS(fularr[*,indROI]);
  time = TRANSPOSE(fularr[2,indROI])
  YROI = TRANSPOSE(fularr[1,indROI])
  ful_vx = TRANSPOSE(fularr[4,indROI])
  ful_vy = TRANSPOSE(fularr[5,indROI])
  ful_pxx_kinetic = TRANSPOSE(fularr[8,indROI])
  ful_pyy_kinetic = TRANSPOSE(fularr[9,indROI])
  ful_pxx_potential = TRANSPOSE(fularr[10,indROI])
  ful_pyy_potential = TRANSPOSE(fularr[11,indROI])
  
  
  ; reserver the names of variables for the array to
  ;store both the density histograms and the time when it was taken:
  denstime = 0
  denscoord = 0
  densamplitude = 0
  timearray = DBLARR(nB); an auxiliarry array which will be used in the
  ; cycle
  
  curhistS = {X:DBLARR(nB),Y:DBLARR(nB)}; structure to keep current
  ;  histogram data
  curHistS.X = Ybins; don't be afraid, we are just using Y coordinate
  ; as X-coordinate. It can be confusing, but our shock is propagating
  ; along the Y-axis geometrically, but in the future we are going to
  ; plot number density (Y-axis) vs coordinate (X-axis, previous
  ;  Y-coordinate)
  
  FOR i = iBegin, iEnd - FLOOR(DOUBLE(frameStep) / 2.0d) DO BEGIN
    ;building histogram using cloud-in-cell (cic):
    indf = WHERE(time GE (DOUBLE(i) - DOUBLE(framestep) / 2.0d) AND $
      time LE (DOUBLE(i) + DOUBLE(frameStep) / 2.0d) )
    Y = YROI[indf]
    YforHist = (Y - YMin)/(YMax-YMin+1.0E-8)*DOUBLE(nB)
    weighNumDens = DBLARR(N_ELEMENTS(YforHist))+1 ; weights for the number density
    
    fieldVx = ful_vx[indf]
    fieldVy = ful_vy[indf]
    fieldVx2 = fieldVx^2
    fieldVy2 = fieldVy^2
    fieldPxx = ful_pxx_potential[indf] + ful_pxx_kinetic[indf]
    fieldPyy = ful_pyy_potential[indf] + ful_pyy_kinetic[indf]
    
    histVx = CIC(fieldVx, YforHist, nB, /ISOLATED, /AVERAGE)
    histVy = CIC(fieldVy, YforHist, nB, /ISOLATED, /AVERAGE)
    histVx2 = CIC(fieldVx2, YforHist, nB, /ISOLATED, /AVERAGE)
    histVy2 =  CIC(fieldVy2, YforHist, nB, /ISOLATED, /AVERAGE)
    histTemperX = (histVx2 - (histVx)^2) / 2.0d
    histTemperY = (histVy2 - (histVy)^2) / 2.0d
    histPxx =  CIC(fieldPxx, YforHist, nB, /ISOLATED)
    histPyy =  CIC(fieldPyy, YforHist, nB, /ISOLATED)
    
    histNumDens = CIC(weighNumDens, YforHist, nB, /ISOLATED) / area / (DOUBLE(frameStep))
    curHistS.Y = histNumDens ; 2018.0914 it seems that I don't use this variable anymore
    print, 'frame=',i
    if(i EQ 1147) THEN stop
    IF (N_ELEMENTS(denstime) EQ 1) THEN BEGIN
      denstime        = timearray + DOUBLE(i)
      denscoord       = Ybins
      densamplitude   = histNumDens
      ampl_Vx          = histVx
      ampl_Vy          = histVy
      ampl_Vx2         = histVx2
      ampl_Vy2         = histVy2
      ampl_TemperX     = histTemperX
      ampl_TemperY     = histTemperY
      ampl_Pxx         = histPxx
      ampl_Pyy         = histPyy
    ENDIF ELSE BEGIN
      denstime = [denstime,timearray + DOUBLE(i)]
      denscoord = [denscoord,Ybins]
      densamplitude = [densamplitude,histNumDens]
      ampl_Vx          = [ampl_Vx,histVx]
      ampl_Vy          = [ampl_Vy,histVy]
      ampl_Vx2         = [ampl_Vx2,histVx2]
      ampl_Vy2         = [ampl_Vy2,histVy2]
      ampl_TemperX     = [ampl_TemperX,histTemperX]
      ampl_TemperY     = [ampl_TemperY,histTemperY]
      ampl_Pxx         = [ampl_Pxx,histPxx]
      ampl_Pyy         = [ampl_Pyy,histPyy]
    ENDELSE
    
  ENDFOR
;  stop
  nelemoutput = N_ELEMENTS(denstime)
  ;define the structure to return data:
  sdata = {time:DBLARR(nelemoutput),coord:DBLARR(nelemoutput),den:DBLARR(nelemoutput), $
    vX:DBLARR(nelemoutput), vY:DBLARR(nelemoutput),vX2:DBLARR(nelemoutput), $
    vY2:DBLARR(nelemoutput), Tx:DBLARR(nelemoutput), $
    Ty:DBLARR(nelemoutput), pxx:DBLARR(nelemoutput), pyy:DBLARR(nelemoutput), $
    filename:'',b:0d,frameStep:0d}
  sdata.b = binWinterparticle
  arrayData = {time:DBLARR(nelemoutput),coord:DBLARR(nelemoutput),den:DBLARR(nelemoutput), $
    vX:DBLARR(nelemoutput), vY:DBLARR(nelemoutput),vX2:DBLARR(nelemoutput), $
    vY2:DBLARR(nelemoutput), Tx:DBLARR(nelemoutput), $
    Ty:DBLARR(nelemoutput), pxx:DBLARR(nelemoutput), pyy:DBLARR(nelemoutput)}
  sdata.time = denstime
  arrayData.vX = ampl_Vx
  arrayData.vY = ampl_VY
  arrayData.vX2 = ampl_Vx2
  arrayData.vY2 = ampl_Vy2
  arrayData.Tx = ampl_TemperX
  arrayData.Ty = ampl_TemperY
  arrayData.pxx = ampl_pxx
  arrayData.pyy = ampl_pyy
  sData.vX = ampl_Vx
  sData.vY = ampl_VY
  sData.vX2 = ampl_Vx2
  sData.vY2 = ampl_Vy2
  sData.Tx = ampl_TemperX
  sData.Ty = ampl_TemperY
  sData.pxx = ampl_pxx
  sData.pyy = ampl_pyy
  IF (KEYWORD_SET(flip)) THEN BEGIN
    sdata.coord = REVERSE(Ymax + Ymin - denscoord)
    sdata.den = REVERSE(densamplitude)
    arrayData.coord = REVERSE(Ymax + Ymin - denscoord)
    arrayData.den = REVERSE(densamplitude)
    arrayData.vX = REVERSE(ampl_Vx)
    arrayData.vY = REVERSE(ampl_VY)
    arrayData.vX2 = REVERSE(ampl_Vx2)
    arrayData.vY2 = REVERSE(ampl_Vy2)
    arrayData.Tx = REVERSE(ampl_TemperX)
    arrayData.Ty = REVERSE(ampl_TemperY)
    arrayData.pxx = REVERSE(ampl_pxx)
    arrayData.pyy = REVERSE(ampl_pyy)
    sData.vX = REVERSE(ampl_Vx)
    sData.vY = REVERSE(ampl_VY)
    sData.vX2 = REVERSE(ampl_Vx2)
    sData.vY2 = REVERSE(ampl_Vy2)
    sData.Tx = REVERSE(ampl_TemperX)
    sData.Ty = REVERSE(ampl_TemperY)
    sData.pxx = REVERSE(ampl_pxx)
    sData.pyy = REVERSE(ampl_pyy)
  ENDIF ELSE BEGIN
    sdata.coord = denscoord
    sdata.den = densamplitude
    arrayData.coord = denscoord
    arrayData.den = densamplitude
    arrayData.vX = ampl_Vx
    arrayData.vY = ampl_VY
    arrayData.vX2 = ampl_Vx2
    arrayData.vY2 = ampl_Vy2
    arrayData.Tx = ampl_TemperX
    arrayData.Ty = ampl_TemperY
    arrayData.pxx = ampl_pxx
    arrayData.pyy = ampl_pyy
    sData.vX = ampl_Vx
    sData.vY = ampl_VY
    sData.vX2 = ampl_Vx2
    sData.vY2 = ampl_Vy2
    sData.Tx = ampl_TemperX
    sData.Ty = ampl_TemperY
    sData.pxx = ampl_pxx
    sData.pyy = ampl_pyy
  ENDELSE
  
  denstime = 0
  denscoord = 0
  densamplitude = 0
  
  
  
  ;save data to file:
  ;append the number of secods since January 1 1970 to make the
  ;filename distinguishable:
  seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
  fnam = STRCOMPRESS('profiles' + seconds + '.csv',/REMOVE_ALL)
  CD, STRCOMPRESS(dirpath+'\..\outputs\')
  WRITE_CSV, fnam, arrayData
  sdata.filename = FILEPATH(fnam)
  sdata.framestep = framestep
  
  RETURN, sdata
END

