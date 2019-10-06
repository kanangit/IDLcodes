;+
;v.0.0. The routine takes the pulse shapes and transforms them
; (by shifting and scaling) so that the pulse shape from 
; the previous frame coinsides with the next one 
; :Author: Anton Kananovich
;-
PRO driver_fitPulseShapes

file = DIALOG_PICKFILE(/READ, FILTER = '*.txt')
sdataFile = getPulseProfiles(file,7.191d, 550.0d, 850.0d, 222.00d, 1050.00d)
result = fitPulseShapes(sdataFile)

END