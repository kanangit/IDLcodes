;+
; :Description:
; Function return the index of the array which lays in between the
; maximum array and the number mAfreq IN FRONT 
; of the maximum of the array.
; I used it to find the shock front posion.
; If it can't find it within the given precision posPrec, 
; it returns 0. 
; :Author: Kananovich
;-

function findFrontPos, valuesArray, mAfreq, posPrec
frontInd = 0

maxn=MAX(valuesArray,maxInd); first find the maximum value of the number density
;  it should be behind the shock front. The index value store in the variable
;  maxInd
; Now, if the front width is nonzero, the front position is where the 
; value of number density would be half of the difference between the 
; maxn and the equillibrium number density value:
; we could find it with some precision posPrec:  
; there could be not one such value, but several. Find them and store 
; their indices in frontCandInd
  frontCandInd = WHERE( ABS((maxn + mAfreq)/2 - valuesArray) LE posPrec)
;  make sure that these values are IN FRONT of the shock:
  IF (MEAN(frontCandInd) NE -1) THEN BEGIN
    indFrontInd = WHERE(frontCAndInd GT maxInd)
    IF (MEAN(indFrontInd) NE -1) THEN BEGIN
      frontCandInd = frontCandInd[indFrontInd]
;     finally, if there are more than 1 candidates for the front position,
;     return the median value:
      frontInd = MEDIAN(frontCandInd); 
    ENDIF
  ENDIF
  

return, frontInd

end