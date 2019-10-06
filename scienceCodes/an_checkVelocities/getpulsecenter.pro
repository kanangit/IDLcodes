;v1.2 The function returns the center of the pulse and returns the part
; of the input array laying wihing the halfwidth distance around the 
;maximum of the pulse.

FUNCTION GETPULSECENTER, array, halfwidth
retval = 0
indmax = 0
nelem = N_ELEMENTS(array[0,*])
;find the maximum
maxY = MAX(array[1,*],indmax) ;ACHTUNG! indmax now contains
;  the index of the max element
maxX = array[0,indMax]
;find coordinates of the point laying closer that halfwidth to
;the maximum of the pulse:
pulseind = WHERE(array[0,*] GE maxX - halfwidth $
  AND array[0,*] LE maxX + halfwidth)
;cutout the part of the array containing the pulse:  
pulsex = array[0,pulseind]
pulsey = array[1,pulseind]
;as a precaution, make sure that the coordinates are ascending:
indsorted = SORT(pulsex)
pulsex = pulsex[indsorted]
pulsey = pulsey[indsorted]
retelems = N_ELEMENTS(pulsex)
retval = DBLARR(2,retelems)
retval[0,0] = TRANSPOSE(pulsex)
retval[1,0] = TRANSPOSE(pulsey)
return, retval

END