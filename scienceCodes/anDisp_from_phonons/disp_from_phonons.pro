; v3.9
;
; NAME:
;       disp_from_phonons
;
; PURPOSE:
;       This procedure gets the experimental phonon spectum 
;       from the output of the Feng's code called PhononCurrents2D.
;       The example of the output file of the PhononCurrents2D can
;       be found here:
;       D:\kananovich\personal\d\docs\forWork\forWork\plasma\IDLcodes
;       \froZach\phononSpectrum\PhononSpectrum_2D
;       \example_orbit.txt_L_current.txt_FFT
;            
;
; CALLING SEQUENCE:
;       disp_from_phonons, nw, nk, maxw, threshold0
;
; INPUTS
;       nw         - number of elements of the frequencies array. The
;                     user should determine it manually inspecting 
;                     the first column of the output file
;                     "*.txt_FFT.txt" (output file of the Fung's code
;                     PhononCurrents2D)
;       nk         - number of elements of the frequencies array. The
;                     user determines it manually inspecting the third
;                     THIRD column of the same file.
;       maxw       - is the maximum omega value that you wish to be 
;                     included in the moment calculations
;       threshold0 - is the starting threshold value...note that the 
;                     plot will always use this value even after you
;                     give a new threshold for the calculations 
;       
; OUTPUTS
;       The procedrue outputs a file with 3 columns:
;       1st column - k, wavenumbers
;       2nd column - w, omega, frequencies
;       3rd column - error in omegas 
;         
;
; PROCEDURE:
;       
;
; MODIFICATION HISTORY:
;           Written by:  Zach Haralson, 2016
;           
;           Modified: 17 Feb 2015 by Zach Haralson 
;           v2 -- 17 Feb 2015: changed so that we always
;           plot spectrum with original threshold although calculations
;           use user-modified threshold if appropriate...so we can see
;           the entire spectrum better
;           
;           Modified: 18 April 2018 by Kananovich. Minor changes.
;            Arrays of floating numbers replaced by arrays of doubles.
;            Changed the plotting.
;-



;disp_from_phonons,2191, 24, 90, 1e-7
pro disp_from_phonons, nw, nk, maxw, threshold0

;;;;nk/nw are the number of data points along those axes in the phonon sepctra
;;;; 
;;;;threshold0 

 

;;;read in the phonon spectra

phononfile = dialog_pickfile(title = 'Select the phonon spectrum file:')
;Template = ASCII_TEMPLATE(phononfile)
;openr, 11, phononfile, /get_lun

data = read_ascii(phononfile, count=N_Labels,  data_start=1, ZLOG = 1)

threshold = threshold0
rep_count = 0
jumprep:

dispersion = DBLARR(nk, nw)
k = DBLARR(nk)
w = DBLARR(nw)

for ik=0, nk-1 do begin
  k[ik] = data.FIELD1[2,long(ik)*long(nw)]
;  stop
  if ik eq 0 then begin
    for iw=0, nw-1 do begin
      w[iw] = data.FIELD1[0,iw]
      dispersion[ik,iw] = data.FIELD1[1,iw]
    endfor
  endif else begin
    for iw=0, nw-1 do begin
      dispersion[ik,iw] = data.FIELD1[1,iw+long(ik)*long(nw)]
    endfor
  endelse
  
endfor


;;;cut and threshold the data

for ik=0, nk-1 do begin
  for iw=0, nw-1 do begin
    if dispersion[ik,iw] lt threshold then dispersion[ik,iw]=0.
    
    
;    if (k[ik] le 8.18895 AND w[iw] GE (7.891844008*k[ik] +0.789184401) ) then begin    
;      dispersion[ik,iw]=0.    
;    endif
;    if (k[ik] ge 8.18895 AND k[ik] LE 14.974 AND $
;     w[iw] GE (-9.198400779*k[ik] +154.5331331)) then begin
;      dispersion[ik,iw]=0.
;    endif
;    if (k[ik] ge 17.3137 AND k[ik] LE 24.0d AND $
;     w[iw] GE (9.739242298*k[ik] -158.7496495)) then begin
;      dispersion[ik,iw]=0.
;    endif
;    if (k[ik] ge 24.00d AND k[ik] LE 31.118d AND $
;     w[iw] GE (-7.601192346*k[ik] + 254.6399436)) then begin
;      dispersion[ik,iw]=0.
;    endif

  endfor
endfor

wind = where(w le maxw)
dispersion = dispersion[*,wind]
w = w[wind]




if rep_count eq 0 then dispersion0 = dispersion

;;;calculate experimental dispersion relation
w0 = DBLARR(nk)
error = DBLARR(nk)
for iik=0, nk-1 do begin
  intP = int_tabulated(w, dispersion[iik,*])
  w0[iik] = int_tabulated(w, w*dispersion[iik,*])/intP
  error[iik] = sqrt(int_tabulated(w, (w-w0[iik])^2*dispersion[iik,*])/intP)
endfor

;;;plot and output
nlevels = 100
;r=255.0d/double(nlevels)*dindgen(nlevels)
r=Floor(255.0d - 255.0d/double(nlevels)*dindgen(nlevels))
rgb = intarr(3,nlevels)
rgb[0,0] = transpose(r)
rgb[1,0] = transpose(r)
rgb[2,0] = transpose(r)
p = contour(dispersion0,k,w,min_value = threshold0,MAX_VALUE = 1.1, ZLOG = 1,N_LEVELS = nlevels, c_lineStyle='', /fill,c_color=rgb)

P1 = ERRORPLOT(k,w0, error, OVERPLOT = 1, LINESTYLE = 6, $ 
  ERRORBAR_COLOR="blue", SYM_COLOR = "BLUE", SYMBOL = "o")

;contour, dispersion0, k, w, c_colors=[30,45,60,75,90,105,120,135,150,165,180,195,210,125,240], nlevels=15,/fill, min_value=threshold0, max_value=1e-0
;oplot, k, w0, psym=2
;oploterr, k, w0, error


print, 'Enter 0 to output dispersion relation, 1 to adjust threshold and try again:'
read, rep
if rep then begin
  rep_count++
  print, 'Enter new value of threshold:'
  read, threshold
  goto, jumprep
endif

openw, u, dialog_pickfile(title='File to write experimental dispersion relation to:'), /get_lun
for iprint=0, nk-1 do begin
  printf, u, k[iprint], ',', w0[iprint], ',', error[iprint]
endfor

free_lun, u

end