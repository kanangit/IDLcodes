; v0.0
;
; NAME:
;       findmaxpPolyFit
;
; PURPOSE:
;       find a maximum of the function with higher precision
;       thant the "bin size", using the polynomial interpolation   
;
; CALLING SEQUENCE:
;       Result = findmaxpPolyFit(s,order)
;
; INPUTS
;       s - the structure containing to arrys of data: s.X and s.Y. 
;         The arrays contain x and y coordinates of the signal to 
;         analise respectively.
;       order - order of the polynomial
;       
; OUTPUTS
;       
;       rs - the structure containing the x and y coordinates of the
;       maximum. rs.X - x-coordiante, rs.Y - y coordinate.
;         
;
; PROCEDURE:
;       
;
; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, August 2018
;           Modified by: Anton Kananovich, 2018.08.01. 
;-

FUNCTION findmaxpPolyFit, s, order
retval = -1
nelem = 1000 ;number of elements. It has the sense of the precision of the 
             ;result
leftx = s.X[0]             
rightx = s.X(N_ELEMENTS(s.X)-1); rightmost value of x             
arr_x = DINDGEN(nelem)/(nelem-1)*(rightx-leftx)+leftx ; array of the x-values
arr_y = DBLARR(nelem)
returnStructur = {X:0.0D,Y:0.0D}
             
coeffs = POLY_FIT(s.X,s.Y,order,/DOUBLE); coeffs of the fit parabola
arr_y = arr_y + coeffs[0]
for i = 1L, order do begin
arr_y = arr_y + arr_x^i*coeffs[i] 
endfor

indMax = WHERE(arr_y EQ MAX(arr_y))
returnStructur.X  = arr_x[indMax]
returnStructur.Y = arr_y[indMax]

retval = returnStructur

RETURN, retval
END
