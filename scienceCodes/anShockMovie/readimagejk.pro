; v1.3
;
; NAME:
;       readImageJK
;
; PURPOSE:
;       This function reads the output file "position.txt" produced by
;       the ImageJ macros "Particle_Identification". "position.txt"
;       file must consist of the columns of data in the following 
;       order: particle number, frame label, particle area,
;       paricle x-coordinate, particle y-coordinate, slice number.
;       It is assumbed that columns are separated by commas
;       and arbitrary number of spaces AND/OR tabs.   
;
; CALLING SEQUENCE:
;       Result = readImageJK()
;
; INPUTS
;       The fuction doesn't have input variables.
;       
; OUTPUTS
;       A structure with the following tags: 
;         .iParticle  - an array of particle numbers 
;         .iFrame     - an array of frame numbers
;         .X          - an array of x-coordinate of the particles
;         .Y          - an array of y-coordinate of the particles
;         .area       - an array with area of the particles
;         .error      - an array with errors in particle positions 
;         
;
; PROCEDURE:
;       
;
; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, April 2016
;           Modified by: Anton Kananovich, 2016.08.23. The function now
;             extracts framenumber correctly from framelabels both
;             ending with file extension and not. I.e. it works correctly
;             both with framelabels like "vid008_frame0001.tiff" and
;             "vid008_frame0001". It will extract the number 
;             0001 in both cases.
;-



function readImageJKdeprecated

GET_LUN, lun
filename = DIALOG_PICKFILE(/READ, FILTER = '*.txt')
nlines = FILE_LINES(filename) ;get the number of lines in the file
sarr = STRARR(nlines) ;initializing a string array to store the data read from the file
OPENR, lun, filename 
READF, lun, sarr ;read all data at once. no cycles. in IDL it will work very fast
FREE_LUN, lun

sarr=STRCOMPRESS(sarr,/REMOVE_ALL); remove all white spaces and tabs in the strings. now the fields are separated only by commas
slist = STRSPLIT(sarr, ',', /EXTRACT); split the strings into fields using comma as a delimiter
alist = slist.ToArray() ;convert the output of the strsplit() function to array
nelements = N_ELEMENTS(slist)
;create a structure in which we store all the data our fucntion will return:
returnStructur = {iParticle:LONARR(nelements),iFrame:LONARR(nelements), $
 area:DBLARR(nelements), X:DBLARR(nelements),Y:DBLARR(nelements),error:DBLARR(nelements)}
;populating the structure fields with the fields values we read from file. again - no cycles. Cycles slow down IDL:
returnStructur.iParticle = LONG(alist[*,0]) -1l
returnStructur.area = DOUBLE(alist[*,2])
returnStructur.X = DOUBLE(alist[*,3])
returnStructur.Y = DOUBLE(alist[*,4])
returnStructur.error = DOUBLE(alist[*,5])
frameLabel = alist[*,1] ; we don't store the values of this field in the return structure,
 ;because we need to convert it first

checkExt = STRMATCH(frameLabel[0], '0')
pos = STREGEX(frameLabel[0], '([0-9]+)(\.|$)', length=len);extract the 
;  framenumber out of the frame label string using regular expressions
;  The regular expression '([0-9]+)(\.|$)' means 
;  "give me the number at the end of the string. The positions of the number is such that after it there
;  either end of string of file extension"
returnStructur.iFrame = LONG(STRMID(frameLabel,pos)) - 1l; now we are ready to pass the
  ;frame number to the corresponding field of the return structure

return, returnStructur ;returning the result
end

