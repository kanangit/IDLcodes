;+
;v.0.2
;The procedure reads a folder, looks for the files in there, assumes
;that they are all outputs of imageJ macro "Particle_Identification"
;(6 columns of data) and splices them together
; :Author: Anton Kananovich
; Created: July 2018
;-

PRO driver_splice

CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_14226_442\analysis\analysis20180717timeProfile\02_code_an_splice\inputs'
paths = FILE_SEARCH('*.txt')
numPaths = N_ELEMENTS(paths)
;reserving variables to store data
iParticle = 0
iFrame = 0
area = 0
X = 0
Y = 0
error = 0
FOR i = 0L, numPaths - 1 DO BEGIN
  print, 'processing file', paths[i]
  s = readImageJK(paths[i],/lowmem)
  ;making sure we don't have garbage in the data:
  indGood = WHERE(FINITE(s.iparticle) AND FINITE(s.iFrame) $
    AND FINITE(s.area) AND FINITE(s.X) AND FINITE(s.Y) $
    AND FINITE(s.error))
  iParticleGood = s.iparticle[indGood]
  iFrameGood    = s.iFrame[indGood]
  areaGood      = s.area[indGood]
  XGood         = s.X[indGood]
  YGood         = s.Y[indGood]
  errorGood     = s.error[indGood]
;  concatenating:
  IF (N_ELEMENTS(iFrame)  EQ 1 ) THEN BEGIN
    iParticle = iParticleGood
    iFrame = iFrameGood
    area = areaGood
    X = XGood 
    Y = YGood
    error = errorGood    
  ENDIF
  IF (N_ELEMENTS(iFrame) GT 1) THEN BEGIN
    iParticle = [iParticle, iParticleGood]
    iFrame = [iFrame, iFrameGood]
    area = [area, areaGood]
    X = [X, XGood]
    Y = [Y, YGood]
    error = [error,errorGood]    
  ENDIF
  
ENDFOR
print, 'Done concatenating! Now saving the data' 
;preparing to save the data:
CD, '..\outputs'
;append the number of secods since January 1 1970 to make the
;filename distinguishable:
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
fnam = STRCOMPRESS('positionSpliced' + seconds + '.txt',/REMOVE_ALL) 
resSave = print6arrays(fnam,iParticle,iFrame,area,X,Y,error,/firstinteger)


print, 'Saved in the file ', fnam 
END
