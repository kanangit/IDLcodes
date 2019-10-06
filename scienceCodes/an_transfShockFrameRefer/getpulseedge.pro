;v0.1 the function finds the edge of the pulse (defined as the point
;where the second derivative is maximal) and returns the part of the
;input array laying wihing the halfwidth distance around this point.
;I.e., it does the same thing as GETPULSECENTER() does for the maximum
; position 

FUNCTION getpulseedge, array, halfwidth
retval = 0
indmax = 0
nelem = N_ELEMENTS(array[0,*])
;Find the position of the pulse edge.
;prepare to use the function findFrontMR():
sa = {X:DBLARR(nelem),Y:DBLARR(nelem)}
sa.X = array[0,*]
sa.Y = array[1,*]
edge = findFrontMR(sa)

;find coordinates of the points laying closer that halfwidth
;the edge:
pulseind = WHERE(array[0,*] GE edge.X - halfwidth $
  AND array[0,*] LE edge.X + halfwidth)
;cutout the part of the array with those coordinates:  
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

RETURN, retval
END