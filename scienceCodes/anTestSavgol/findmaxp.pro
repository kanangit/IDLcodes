; v1.1
;
; NAME:
;       findmaxp
;
; PURPOSE:
;       find a maximum of the function with higher precision
;       thant the "bin size", using the parabolic interpolation   
;
; CALLING SEQUENCE:
;       Result = findmaxp(s)
;
; INPUTS
;       s - the structure containing to arrys of data: s.X and s.Y. 
;         The arrays contain x and y coordinates of the signal to 
;         analise respectively.
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
;           Written by:  Anton Kananovich, March 2018
;           Modified by: Anton Kananovich, 2018.03.26. 
;-

FUNCTION findmaxp, s
retval = -1
nelem = 1000 ;number of elements. It has the sense of the precision of the 
             ;result
leftx = s.X[0]             
rightx = s.X(N_ELEMENTS(s.X)-1); rightmost value of x             
arr_x = DINDGEN(nelem)/(nelem-1)*(rightx-leftx)+leftx ; array of the x-values
arr_y = -1; wait for it. we will make this an arry of the y-values
;initialize the return structure
returnStructur = {X:0.0D,Y:0.0D}
             
coeffs = POLY_FIT(s.X,s.Y,2,/DOUBLE); coeffs of the fit parabola
arr_y = coeffs[0] + arr_x*coeffs[1] + arr_x^2*coeffs[2] ; populating the 
                                    ;y-values of the parabola
indMax = WHERE(arr_y EQ MAX(arr_y))
returnStructur.X  = arr_x[indMax]
returnStructur.Y = arr_y[indMax]

retval = returnStructur

RETURN, retval
END
