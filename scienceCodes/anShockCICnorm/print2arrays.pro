function print2arrays, filename, x, y
nelemx = N_ELEMENTS(x)
nelemy = N_ELEMENTS(y)
nelem = MIN([nelemx,nelemy])
GET_LUN, lun
OPENW, lun, filename
FOR i=0, nelem -1 DO BEGIN
PRINTF, lun, x[i],',',y[i]
ENDFOR
CLOSE, lun
FREE_LUN, lun
RETURN, 0
END