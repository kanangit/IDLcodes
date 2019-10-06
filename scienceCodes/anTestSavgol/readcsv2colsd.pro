; v1.1
;
; NAME:
;       readCsv2colsD
;
; PURPOSE:
;       This function reads a csv file consisting of two columns
;       of numerical data. It is assumbed that columns are 
;       separated by commas and arbitrary number of spaces
;       AND/OR tabs.   
;
; CALLING SEQUENCE:
;       Result = readCsv2colsD()
;
; INPUTS
;       The fuction doesn't have input variables.
;       
; OUTPUTS
;       A structure with the following tags: 
;         .X          - an array of x-coordinate of the particles
;         .Y          - an array of y-coordinate of the particles
;          
;         
;
; PROCEDURE:
;       
;
; MODIFICATION HISTORY:
;           Written by:  Anton Kananovich, April 2018
;           Modified by: Anton Kananovich, 2016.08.23. 
;-



function readCsv2colsD

GET_LUN, lun
filename = DIALOG_PICKFILE(/READ, FILTER = '*.csv')
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
returnStructur = {X:DBLARR(nelements),Y:DBLARR(nelements)}
;populating the structure fields with the fields values we read from file. again - no cycles. Cycles slow down IDL:
returnStructur.X = DOUBLE(alist[*,0])
returnStructur.Y = DOUBLE(alist[*,1])

RETURN, returnStructur ;returning the result
END

