; v1.1
;
; NAME:
;       purgeunpositive
;
; PURPOSE:
;       This function reads an array of data and replaces all values 
;       of the array, which are less than zero with 1.   
;
; CALLING SEQUENCE:
;       Result = purgeunpositive(arr)
;
; INPUTS
;       arr - an array of data.
;       
; OUTPUTS
;       array of the same dimension as the input array
;         
;
; PROCEDURE:
;       
;
; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, March 2018
;           
;-

function purgeunpositive, arr
indus = WHERE(arr LE 0.0d)
retarr = arr
retarr[indus] = 1.0d
return, retarr;
end