; v1.1
;
; NAME:
;       findFrontMR
;
; PURPOSE:
;       The function takes an 2D array of a histogram and calculates the 
;       "front position" as point, which lays AFTER the maximum and
;       possesses the maximal rate of change (i.e. has the maximum 
;       second derivative). When calculating the derivative, it uses
;       the Savitsky-Golay filter, i.e. performs smoothening.
;       The goal of the function is to facilitate analysis of shock 
;       front positions for the data taken by Kananovich on 2018.03   
;
; CALLING SEQUENCE:
;       Result = findFrontMR(s)
;
; INPUTS
;       s - the structure containing to arrys of data: s.X and s.Y. 
;         The arrays contain x and y coordinates of the signal to 
;         analise respectively.
;       
; OUTPUTS
;       
;       returnStructur - the structure containing x and y coordinates
;       of the second derivative
;         
;
; PROCEDURE:
;       
;
; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, March 2018
;           Modified by: Anton Kananovich, 2018.03.26. 
;-

FUNCTION findFrontMR, s

inpSD = {X:DBLARR(3),Y:DBLARR(3)} ; structure to keep data of the
;  3-point parabola near the 2nd derivative local maximum
indlength = 10; the maximum number of indices where we shall look for 
  ;the maximum of our second derivative
dt = s.X[2]-s.X[1] ;data spacing
returnStructur = {X:0.0D,Y:0.0D} ; declare the structure where we keep
;  the return data

;find the maximum of the histogram:
maxParticles = MAX(s.Y)
indarrMaxP = WHERE(s.Y EQ maxParticles) ;find the maximum element index
indMaxP = indarrMaxP[0] ; we need this index as an integer number, not as
                     ;array of indices
rangeArray = INDGEN(N_ELEMENTS(s.X)-1) ; it is the array of indexes
  ;it serves auxiliarry role
forwardRange = WHERE(rangeArray GT indMaxP AND $ 
  rangeArray LE (indMaxP+indlength))

;now calculate the smoothed second derivative using the Savitsky-Golay
;filter:
savgolSecondFilter = SAVGOL(3, 3, 2, 4, /DOUBLE)*(FACTORIAL(2)/ (dt^2))
savgolSndDeriv = CONVOL(s.Y, savgolSecondFilter, /EDGE_TRUNCATE);
;find the index of the maximum element of the smoothed second derivative:
maxSndDeriv = MAX(savgolSndDeriv(forwardRange)) 
indarrMax2ndDeriv = WHERE(savgolSndDeriv EQ maxSndDeriv) ;find the index of
  ;the maximum element
indMax2ndDeriv = indarrMax2ndDeriv[0] ;index as an integer
inpSD.X = [s.X[indMax2ndDeriv-1],s.X[indMax2ndDeriv],s.X[indMax2ndDeriv+1]]
inpSD.Y = [savgolSndDeriv[indMax2ndDeriv-1],savgolSndDeriv[indMax2ndDeriv],savgolSndDeriv[indMax2ndDeriv+1]]
returnStructur = findmaxp(inpSD)

RETURN, returnStructur

END