; v1.0
;
; NAME:
;       readImageJK4feng;
;works exactly as readImageJK, but tailored for Feng's code

;-



function readImageJK4Feng

GET_LUN, lun
filename = DIALOG_PICKFILE(/READ, FILTER = '*.txt')
nlines = FILE_LINES(filename) ;get the number of lines in the file
sarr = STRARR(nlines) ;initializing a string array to store the data read from the file
OPENR, lun, filename 
READF, lun, sarr ;read all data at once. no cycles. in IDL it will work very fast
FREE_LUN, lun
sarr=STRCOMPRESS(temporary(sarr),/REMOVE_ALL); remove all white spaces and tabs in the strings. now the fields are separated only by commas
slist = STRSPLIT(temporary(sarr), ',', /EXTRACT); split the strings into fields using comma as a delimiter
nelements = N_ELEMENTS(slist)
removed = slist.Remove(nelements-1)
removed = slist.Remove(nelements-2)
nelements = nelements - 2
alist = slist.ToArray() ;convert the output of the strsplit() function to array
slist = 0; free the memory


;create a structure in which we store all the data our fucntion will return:
returnStructur = {iParticle:LONARR(nelements),iFrame:LONARR(nelements), $
 area:DBLARR(nelements), X:DBLARR(nelements),Y:DBLARR(nelements),error:DBLARR(nelements)}
;populating the structure fields with the fields values we read from file. again - no cycles. Cycles slow down IDL:
returnStructur.iParticle = LONG(alist[*,0])
returnStructur.area = DOUBLE(alist[*,2])
returnStructur.X = DOUBLE(alist[*,3])
returnStructur.Y = DOUBLE(alist[*,4])
returnStructur.error = DOUBLE(alist[*,5])
frameLabel = alist[*,1] ; we don't store the values of this field in the return structure,
 ;because we need to convert it first


pos = STREGEX(frameLabel[0], '([0-9]+)(\.|$)', length=len) ;extract the

  ;framenumber out of the frame label string using regular expressions
  ;The regular expression '[0-9]+$' means 
  ;"give me the end of the string, which contains digits only"

  
returnStructur.iFrame = LONG(STRMID(frameLabel,pos,len-1)) - 1l; now we are ready to pass the
  ;frame number to the corresponding field of the return structure

return, returnStructur ;returning the result
end

