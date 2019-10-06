;v1.0 fuction returns the position of the center of mass
FUNCTION getCM, array
retval = 0

retval = TOTAL(array[0,*]*array[1,*]) / TOTAL(array[1,*])

return, retval

END