
;+
; :Description:
;   2018.09.19
;
;
;
;
;
; :Author: kanton
;-
pro test20180918b
  path = '\\128.255.35.174\expAnalysisBackup\test\20180919testImageCoordConv'
  curDate='20180918'
  coreName = STRCOMPRESS(curDate + 'fake_image_')
  seconds = STRING(SYSTIME(/seconds),FORMAT='(I18)')
  ;  SAVE, sdataFile, filename = STRCOMPRESS(coreName+ seconds+ '.sav')
  imalen = 480L
  imawid = 640d
  intensity = 5000d
  maxIntensity = 2.0d^16 - 1d
  Radius=1.5d

  xx = [0d, 320.0d, 100.0d]
  yy = [0d, 240.0d, 100.0d]



  CD, path
  CD, 'outputs'
  arrMyimage = dindgen(imawid,imalen) * maxIntensity / DOUBLE(imalen) / DOUBLE(imawid)
  
  fulimage = MAKE_ARRAY(imaWid, imaLen, /DOUBLE, VALUE = 0)

  
  
  FOR k = 0L, N_ELEMENTS(xx) DO BEGIN
  ima = MAKE_ARRAY(imaWid, imaLen, /DOUBLE, VALUE = 0)
  ii = 0L
  jj = 0L

  for ii = 0L, imawid - 1L do begin
    for jj = 0L, imalen - 1L do begin
      ima[ii,jj] = (erf((double(ii)+0.5d - xx)/Radius)-erf((double(ii)-0.5d - xx)/Radius))*(erf((double(jj)+0.5d - yy)/Radius)-erf((double(jj)-0.5d - yy)/Radius))
      ima[ii,jj] = (intensity*1.0d)*Radius*Radius*!DPI*ima(ii,jj)
    endfor
  endfor
  fulimage = fulimage + ima
  ENDFOR

  p1 = contour(fulimage, c_lineStyle='', /fill, N_LEVELS = nlevels)
  p1.save, 'fulimage.tiff'
  stop

  ;print, arrMyimage
  filename = STRCOMPRESS(coreName+ seconds+ '.tiff', /REMOVE_ALL)
  WRITE_TIFF, filename, fulimage, /short

  nlevels = 100
  ;r=255.0d/double(nlevels)*dindgen(nlevels)
  r=Floor(255.0d - 255.0d/double(nlevels)*dindgen(nlevels))
  rgb = intarr(3,nlevels)
  rgb[0,0] = transpose(r)
  rgb[1,0] = transpose(r)
  rgb[2,0] = transpose(r)
  ;  p = contour(arrMyimage,min_value =0,MAX_VALUE = 2.0d^16, ZLOG = 1,N_LEVELS = nlevels, c_lineStyle='', /fill,c_color=rgb)
  p = contour(arrMyimage, c_lineStyle='', /fill)
  stop
end

