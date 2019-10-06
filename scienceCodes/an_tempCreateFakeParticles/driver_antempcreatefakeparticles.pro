;v.0.5 2018.09.17 create facke particles for debug purposes
;v.0.5 2018.09.17 create facke particles for debug purposes
;v.0.1 2018.09.17 create facke particles for debug purposes

PRO driver_anTempCreateFakeParticles
curDate='20180917'

CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_fakeParticles_debug\01_code_an_tempCreateFakeParticles'

CD, 'outputs'
  treckLen = 60
  noPart = 5
  startFrame = 1000
  
  coreName = STRCOMPRESS('positionsFake_ff'+STRING(startFrame)+'-' + STRING(startFrame + treckLen) + '_' + STRING(curDate), /REMOVE_ALL)
  
  
  startXPositions = DINDGEN(noPart) + 600
  startYPositions = DINDGEN(noPart) + 700
  startVx = DINDGEN(noPart)/10.0d
  startVy = -2* DINDGEN(noPart)/10.0d
  fakeParticles = DBLARR(6,treckLen * noPart)
  stop
  index = 0
  FOR i = 0, treckLen - 1 DO BEGIN
    FOR j = 0, noPart - 1 DO BEGIN
    
      fakeParticles[0,index] = j
      fakeParticles[1,index] = startFrame + i
      fakeParticles[2,index] = 1
      fakeParticles[3,index] = startXPositions[j] + $
        startVx[j] * (fakeParticles[1,index] - startFrame )
      fakeParticles[4,index] = startYPositions[j] + startVy[j] * (fakeParticles[1,index] - startFrame )
      fakeParticles[2,index] = 1
      print, fakeparticles[*,0:(index)]
      index = index + 1
;      stop
    ENDFOR
  ENDFOR
  ;append the number of secods since January 1 1970 to make the
;filename distinguishable:
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
fnam = STRCOMPRESS(corename + '_' + seconds + '.txt',/REMOVE_ALL) 
WRITE_CSV, fnam, fakeParticles
END