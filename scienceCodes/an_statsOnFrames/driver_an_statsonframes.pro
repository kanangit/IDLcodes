;v0.11
;2018.07.11 The procudure calculates the number of paricles per frame along with
;the sum area of all particles of every frames
;I need this information to estimate which frames where not illuminated
;very good.

; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, July 2018

PRO driver_an_statsonframes


leftBorder = 550.0d
rightBorder= 850.0d;
yMin = 222.0d;
yMax = 1215.0d


CD, 'F:\kananovich\OneDrive - University of Iowa\bDocs\expAnalysisBackup\c_14226_457\analysis\20180719framesAnalysis\code_an_framestats\inputs'
s = readImageJK(/lowmem)

iBegin=918
iEnd = max(s.iframe)

indROI = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin)
              
CD, '..\outputs\'              
areas = DBLARR(iEnd-iBegin+1)
nparticles = ULONARR(iEnd-iBegin+1)
frameNos = ULONARR(iEnd-iBegin+1)
ind = 0l
FOR i = iBegin, iEnd DO BEGIN
ind = WHERE(s.X LE rightBorder AND s.X GE leftBorder $
              AND s.Y LE ymax AND s.Y GE yMin $
              AND s.iFrame EQ i)            
ipartArea = TOTAL(s.area[ind])
iNparticles = N_ELEMENTS(ind)            
areas[i-iBegin] = ipartArea
nparticles[i-iBegin] = iNparticles
frameNos[i-iBegin] = i
print, 'frame = ',i
print, 'area = ', ipartArea
print, 'nparticles =', iNparticles  

END
;preparing to save the data:

;append the number of secods since January 1 1970 to make the
;filename distinguishable:
seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
fnamareas = STRCOMPRESS('areas' + seconds + '.csv',/REMOVE_ALL)
fnamnparticles = STRCOMPRESS('nparticles' + seconds + '.csv',/REMOVE_ALL)
fnamareasRelative = STRCOMPRESS('areasRelative' + seconds + '.csv',/REMOVE_ALL)
fnam4nparticlesRelative = STRCOMPRESS('nparticlesRelative' + seconds + '.csv',/REMOVE_ALL) 
z1 = print2arrays(fnamareas,frameNos,areas)
z2 = print2arrays(fnamnparticles,frameNos,nparticles)
z3 = print2arrays(fnamareasRelative,frameNos,areas*100.0d / DOUBLE(MAX(areas)))
z4 = print2arrays(fnam4nparticlesRelative,frameNos,nparticles*100.0d / DOUBLE(MAX(nparticles)))
p = plot(frameNos, nparticles/double(max(nparticles))*100.0d, color = 'blue')
p = plot(frameNos, areas/double(max(areas))*100.0d, /overplot, color = 'red')

stop
p.close
END