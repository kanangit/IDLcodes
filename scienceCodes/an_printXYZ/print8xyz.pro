FUNCTION print8xyz, filename, comment, no_particles, x, y, z, za, zb, zc, zd, ze, firstinteger = firstinteger
nelemx = N_ELEMENTS(x)
nelemy = N_ELEMENTS(y)
nelemz = N_ELEMENTS(z)
nelemza = N_ELEMENTS(za)
nelemzb = N_ELEMENTS(zb)
nelemzc = N_ELEMENTS(zc)
nelemzd = N_ELEMENTS(zd)
nelemze = N_ELEMENTS(ze)
nelem = MIN([nelemx,nelemy,nelemz,nelemza,nelemzb,nelemzc,nelemzd,nelemze])
comma = ' '
GET_LUN, lun
OPENW, lun, filename
printf, lun, no_particles
printf, lun, comment
if (KEYWORD_SET(firstinteger)) then begin
  FOR i=0, nelem -1 DO BEGIN
    PRINTF, lun,format = '(I18,A1,I18,A1,E18.10,A1,E18.10,A1,E18.10,A1,E18.10,A1,E18.10,A1,E18.10)',x[i],comma,y[i],comma,z[i],comma,za[i],comma,zb[i],comma,zc[i],comma,zd[i],comma,ze[i]
  ENDFOR
endif  else begin
  FOR i=0, nelem -1 DO BEGIN
    PRINTF, lun,format = '(E18.10,A1,E18.10,A1,E18.10,A1,E18.10,A1,E18.10,A1,E18.10,A1,E18.10,A1,E18.10)',x[i],comma,y[i],comma,z[i],comma,za[i],comma,zb[i],comma,zc[i],comma,zd[i],comma,ze[i]
  ENDFOR
endelse
CLOSE, lun
FREE_LUN, lun
RETURN, 0
END