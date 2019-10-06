;FitDispersion, 0.62, 628, 400, 1, 10.0   --for phonon spectra from video 2-1
;FitDispersion, 0.57, 628, 400, 1, 10.0   --for phonon spectra from video 3-24
;FitDispersion, 0.55, 628, 400, 1, 10.0   --for phonon spectra from video 2-19
Pro FitDispersion, spacing,nfreqs, nkappas, nAngles, omega0
;nfreqs: number of data points for one theoretical dispersion relation
;nkappas:  number of kappas calculated in your theoretical dispersion relation
;nAngles;  number of angles you calculated in your theoretical dispersion relation
;omega0:   initial guess of your dusty plasma frequency, e.g. 10.0
   Read_Data, nfreqs, nkappas, Dispersion_L,Dispersion_T,Data0,Data1,Lspectrum, Tspectrum, kappas,damping,angle, nAngles
   Data0[2,*] = Data0[2,*]
   Data1[2,*] = Data1[1,*]
;   stop;
   Determine_kappa, spacing,Dispersion_L, Dispersion_T, Data0, Data1, Lspectrum, Tspectrum, kappas, damping, angle, omega0, rms_L, omega_pd

   contour,rms_L^2,kappas,omega_pd,/fill,nlevels = 200,yrange = [0,200],ystyle=1,xrange=[0.1,4],xstyle=1,Zrange=[50,1000],background=255,color=254,xtitle='kappa',ytitle='omega_pd [1/s]',xgridstyle=1,TICKLEN = 0.5,ygridstyle=1,xticks=40,yticks=50
;   stop;
   mkappa = n_elements(rms_L[*,0])
   momega = n_elements(rms_L[0,*])
   openw, 11, dialog_pickfile(Title="filename for the chi sqaure:")
   for ikappa = 0, mkappa - 1 do begin
    for iomega = 0, momega - 1 do begin
       printf, 11, kappas[ikappa], omega_pd[iomega], rms_L[ikappa,iomega]
    endfor
   endfor
   close, 11
End

Pro Read_Data, nfreqs, nkappas, Dispersion_L,Dispersion_T,Data0,Data1,Lspectrum, Tspectrum, kappas, damping, angle, nAngles
    Read_Dispersion_relation, nfreqs, nkappas, Dispersion_L, kappas, mode, damping, angle, nAngles
    Read_Dispersion_relation, nfreqs, nkappas, Dispersion_T, kappas, mode, damping, angle, nAngles
  read_N_Columns, Data0, 3, 5000L,0,  dialog_pickfile(title='Experimental longitudinal dispersion:')
  read_N_Columns, Data1, 3, 5000L,0,  dialog_pickfile(title='Experimental transverse dispersion:')
  read_N_Columns, Lspectrum, 3, 50000L,1,  dialog_pickfile(title='Experimental longitudinal phonon:')
  read_N_Columns, Tspectrum, 3, 50000L,1,  dialog_pickfile(title='Experimental transverse phonon:')
End

;Determine_kappa, Dispersion_L, Dispersion_T, Data0, Data1, Lspectrum, Tspectrum, kappas, damping, angle, 10.0,rms_L,omega_pd
Pro Determine_kappa, spacing,Dispersion_L, Dispersion_T, Data0, Data1, Lspectrum, Tspectrum, kappas, damping, angle, omega0, rms_L,omega_pd

    size_dispersion = size(Dispersion_L,/dimensions)
            NKmax = size_dispersion[1] 
         N_Kappas = size_dispersion[2]
;         nAngles = size_dispersion[3]
nAngles = 1
         Dispersion = fltarr(2, NKmax, N_Kappas,2)

    ; nAngles = 7  ;;;;;;;;;;

    for iangle = 0, nAngles-1 do begin
    Dispersion[*, *, *,0] = Dispersion[*, *, *,0] + Dispersion_L[*,*,*,iangle]
    Dispersion[*, *, *,1] = Dispersion[*, *, *,1] + Dispersion_T[*,*,*,iangle]
  endfor

  Dispersion[*, *, *,*] = Dispersion[*, *, *,*]/float( nAngles)

  Minimize_dispersion, Dispersion,omega0,kappas,Data0,data1,spacing,Kappa0,0,ome_ex,rms_L,omega_pd

  ;Plot_Dispersion_relation, [30,40,48,50,52,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,72,80,90],$
   ;                         Lspectrum,Tspectrum,Dispersion,15,kappas,Data0,data1,0.4562,iKappa0,ome0
  
  print, "Fitting result:"
  print, "kappa = ", kappas[kappa0]
  print, "omega = ", omega0
  print, "min Chi-squared = ", min(rms_L[kappa0,*])

return
    window,2,xsize = 1250, ysize=950
          !P.MULTI = [0, 1, 1]

    Dispersion1 = reform(Dispersion[*,*,*,0])

    Plot_spectrum, Lspectrum, Dispersion1, omega0, kappas, kappa0, Data0, spacing
    oplot, dispersion1[0,*,kappa0],sqrt(dispersion1[1,*,kappa0]^2+ome_ex^2) * omega0,color=253
;    wait, 10
    stop
  XYOUTS, 1.5, 20,'kappa='+String(kappas[kappa0],format='(F5.2)')+'; ' ,color=253
  XYOUTS,'Ome='+String(omega0*3.714,format='(F7.2)')+';   ',color=253
  XYOUTS,'Ome_ex='+String(omega0*ome_ex,format='(F7.2)'),color=253

    oplot, dispersion_L[0,*,kappa0,0],sqrt(dispersion_L[1,*,kappa0,0]^2+ome_ex^2)* omega0,color= 254
;    wait, 10
    XYOUTS, dispersion_L[0,250,kappa0,0],dispersion_L[1,250,kappa0,0]* omega0, $
            String(Angle[0]*57.30,format='(I2)') ,color= 254

    oplot, dispersion_L[0,*,kappa0,nAngles/2],sqrt(dispersion_L[1,*,kappa0,nAngles/2]^2+ome_ex^2)* omega0,color= 254
;    wait, 10
    XYOUTS, dispersion_L[0,250,kappa0,nAngles/2],dispersion_L[1,250,kappa0,nAngles/2 ]* omega0, $
            String(Angle[nAngles/2 ]*57.30,format='(I2)') ,color= 254

    WRITE_TIFF, dialog_pickfile(Title='Save longitudinal to tif file:'), TVRD(/ORDER,TRUE=1)
    ;Dispersion1 = reform(Dispersion[*,*,*,1])
    ;Plot_spectrum, Tspectrum, Dispersion1, omega0, kappas, kappa0, Data1, 0.4562
    ;for iangle = 0, nAngles - 1 do begin
    ;    oplot, dispersion_T[0,*,kappa0,iangle],dispersion_T[1,*,kappa0,iangle]* omega0
    ;    XYOUTS, dispersion_T[0,200,kappa0,iangle],dispersion_T[1,200,kappa0,iangle]* omega0,String(Angle[iangle]*57.30,format='(F5.2)')+'; ' ,color=253
    ;endfor

    window,3,xsize = 1250, ysize=950
          !P.MULTI = [0, 1, 1]

       Dispersion1 = reform(Dispersion[*,*,*,1])

    Plot_spectrum, Tspectrum, Dispersion1, omega0, kappas, kappa0, Data1, spacing
    oplot, dispersion1[0,*,kappa0],sqrt(dispersion1[1,*,kappa0]^2+ome_ex^2) * omega0,color=253
;    wait, 10
  XYOUTS, 1.5, 20,'kappa='+String(kappas[kappa0],format='(F5.2)')+'; ' ,color=253
  XYOUTS,'Ome='+String(omega0*3.714,format='(F7.2)')+';   ',color=253
  XYOUTS,'Ome_ex='+String(omega0*ome_ex,format='(F7.2)'),color=253

    oplot, dispersion_T[0,*,kappa0,0],sqrt(dispersion_T[1,*,kappa0,0]^2+ome_ex^2)* omega0,color= 254
;    wait, 10
    XYOUTS, dispersion_T[0,250,kappa0,0],sqrt(dispersion_T[1,250,kappa0,0]^2+ome_ex^2)* omega0, $
            String(Angle[0]*57.30,format='(I2)') ,color= 254

    oplot, dispersion_T[0,*,kappa0,nAngles/2 ],sqrt(dispersion_T[1,*,kappa0,nAngles/2 ]^2+ome_ex^2)* omega0,color= 254
    wait, 10
    XYOUTS, dispersion_T[0,250,kappa0,nAngles/2],dispersion_T[1,250,kappa0,nAngles/2]* omega0, $
            String(Angle[nAngles/2 ]*57.30,format='(I2)') ,color= 254

   WRITE_TIFF, dialog_pickfile(Title='Save transverse to tif file:'), TVRD(/ORDER,TRUE=1)

   !P.MULTI = [0, 1, 1]
End

;Minimize_dispersion, Dispersion,15,kappas,Data0,data1,0.4562,Kappa0, 1,ome_ex,rms_L, omega_pd
Pro Minimize_dispersion, Dispersion0, omega0,kappas,Data0,data1,spacing,Kappa0, weight,ome_ex, rms_L, omega_pd

               pi = 3.1415926535897932384626433832795d
               endPi = 2.0d * pi
          d_omega = 0.15d

    n_wavenumbers = n_elements(Data0[0,*])
           nkappa = n_elements(kappas)
           nloops = 300L
            RMS_L = fltarr(nkappa, nloops)
         omega_pd = fltarr(nloops)
           omega1 = omega0
    Icontinue = 1

loop:  print,''
    Dispersion = Dispersion0

      nconfines = 1
        RMS_ome = fltarr(3,nconfines)
    for confine = 0, nconfines - 1 do begin

        ome_ext = float(confine) * 0.02
      ome_ext = 0.0
        Dispersion[1,*,*,*] = sqrt(Dispersion0[1,*,*,*]^2 + ome_ext^2)
           omega0 = omega1
              rms = fltarr(4,nkappa)
         rms[*,*] = 1.0E10

      for iloop = 0, nloops -1L do begin

          omega0 = omega0 + Icontinue * d_omega

        for kappa = 0, nkappa -1L do begin

            closest1 = Min(abs( Dispersion[0,*,kappa,0] - endPi), TheClosest1)
            closest2 = Min(abs(      data0[0,1:*]*spacing - endPi), TheClosest2)
              result = INTERPOL(dispersion[1, 0:TheClosest1, kappa, 0] * omega0, $
                                dispersion[0, 0:TheClosest1, kappa, 0], data0[0, 0:TheClosest2 ] * spacing)


              if(weight EQ 1)then begin
                rms0 = total( ( result[1:TheClosest2] - data0[1,1:TheClosest2] )^2  /  data0[1,1:TheClosest2]^2 )
            endif else begin
               ; print,'calculating Chi square....'
              rms0 = total( ( result[1:TheClosest2] - data0[1,1:TheClosest2] )^2 /data0[2,1:TheClosest2]^2)
            endelse



            ;if(rms0 LT rms[0,kappa])then begin
            ;      rms[0, kappa] = rms0
            ;      rms[2, kappa] = omega0
            ;endif

            Tclosest1 = Min(abs(Dispersion[0,*,kappa,1] - endPi), TheT_Closest1)
            Tclosest2 = Min(abs(     data1[0,1:*]*spacing - endPi), TheT_Closest2)
              Tresult = INTERPOL(dispersion[1, 0:TheT_Closest1, kappa, 1] * omega0, $
                                 dispersion[0, 0:TheT_Closest1, kappa, 1], data1[0,0:TheT_Closest2]*spacing)


              if(weight EQ 1)then begin
                rms1 = total( ( Tresult[1:TheT_Closest2] - data1[1,1:TheT_Closest2] )^2  /  data1[1,1:TheT_Closest2]^2 )
            endif else begin
              rms1 = total( ( Tresult[1:TheT_Closest2] - data1[1,1:TheT_Closest2] )^2 / data1[2,1:TheT_Closest2]^2 )
            endelse

            ;if(rms1 LT rms[1,kappa])then begin
            ;      rms[1, kappa] = rms1
            ;endif

                rms_L[kappa, iloop] =  rms0+rms1;
                    omega_pd[iloop] = omega0 

            if( rms0+rms1 LT rms[3,kappa]) then begin
               rms[0, kappa] = rms0
               rms[1, kappa] = rms1
               rms[2, kappa] = omega0
               rms[3,kappa] = rms0+rms1;
            endif

        endfor

      endfor
          minRMS = min(RMS[3,*],kappa0)
          rms_ome[0, confine] = minRMS
          rms_ome[1, confine] = kappa0
          rms_ome[2, confine] = rms[2,kappa0]

    endfor

    window,1,xsize = 1250, ysize=950
          !P.MULTI = [0, 1, 1]

    plot, data0[0,*]*spacing, data0[1,*], psym = 1, xrange=[0,2*pi], xstyle = 1, color=255
;    wait, 10
    oplot,data1[0,*]*spacing, data1[1,*], psym = 5
;    wait, 10

    minRMS = min(rms_ome[0,*], omeExt0)
    ome_ex = omeExt0 * 0.02
    ome_ex = 0.0
    kappa0 = rms_ome[1, omeExt0]
    omega0 = rms_ome[2, omeExt0]

    oplot, dispersion0[0,*,kappa0,0],sqrt(dispersion0[1,*,kappa0,0]^2+ome_ex^2)* omega0
;    wait, 10
  oplot, dispersion0[0,*,kappa0,1],sqrt(dispersion0[1,*,kappa0,1]^2+ome_ex^2)* omega0,color=255
  wait, 10
    print, ome_ex * omega0

    read,Icontinue
    if(abs(Icontinue) EQ 1)then goto,loop

end

Pro Read_Dispersion_relation, NKmax, N_Kappas, Dispersion, kappas,mode, damping,angle,nAngles

   project_file = dialog_pickfile(Title='Read in project file for dispersion relations:')
   openr,lun1,project_file,/get_lun

   Dispersion = fltarr(2, NKmax, N_Kappas,nAngles)
        angle = fltarr(nAngles)
       iangle = 0
   While(NOT EOF(lun1))do begin

       dispersion_data=''
       readf,lun1,dispersion_data

     openr,13,dispersion_data
     kappas = fltarr(N_kappas)
     ikappa = 0L


     While(NOT EOF(13))do begin
          readf,13, mode, angle0, kappa, damping
          angle[iangle] = angle0
          kappas[ikappa]=kappa
          for ik = 0, NKmax -1L do begin
             readf, 13, kr, omega,  omega_i
             Dispersion[0, ik, ikappa,iangle] = kr
             Dispersion[1, ik, ikappa,iangle] = omega
;           Dispersion[2, ik, ikappa] = omega_i
          endfor
          ikappa = ikappa + 1L
     endwhile


     close, 13
     iangle = iangle + 1

   endwhile
   close,lun1


End

;get_index, rms_L, 8.4, kappas,omega_pd
;window,1,xsize = 1250, ysize=950
;Visulize_transver,Dispersion_L, Dispersion_T, Data0, Data1, Lspectrum, Tspectrum, kappas, damping, angle, omega_pd, 81, 123

Pro get_index, rms_L, threshold, kappas,omega_pd
    size_rms = size(rms_L,/dimensions)
   nkappas = size_rms[0]
    nfreqs = size_rms[1]

    openw, lun, dialog_pickfile(Title='filename for Chi^2 contour data'),/get_lun
    for ifreq = 0, nfreqs - 1L do begin
        for ikappa = 0, nkappas - 1L do begin
         if(rms_L[ikappa, ifreq] lt threshold)then begin
            print, ikappa, kappas[ikappa],ifreq,omega_pd[ifreq], rms_L[ikappa, ifreq]
         endif
         printf, lun,ikappa, kappas[ikappa],ifreq,omega_pd[ifreq], rms_L[ikappa, ifreq]
      endfor
    endfor
    close,lun

End

Pro Visulize_transver,Dispersion_L, Dispersion_T, Data0, Data1, Lspectrum, Tspectrum, kappas, damping, angle, omega_pd, kappa, iome_pd0
    ome_ex = 0.0

    size_dispersion = size(Dispersion_T,/dimensions)
            NKmax = size_dispersion[1]
         N_Kappas = size_dispersion[2]
          nAngles = size_dispersion[3]

    omega1 = omega_pd[iome_pd0]/3.716
    omega0 = omega1
    kappa0 = kappa
    iome_pd = iome_pd0


try_again: print,''
    window,0,xsize = 1250, ysize=950
    Plot_spectrum, Tspectrum, Dispersion1, omega0, kappas, kappa0, Data1, spacing

    oplot, dispersion_T[0,*,kappa,0],sqrt(dispersion_T[1,*,kappa,0]^2+ome_ex^2)* omega1,color= 254
    wait, 10
    XYOUTS, dispersion_T[0,250,kappa,0],sqrt(dispersion_T[1,250,kappa,0]^2+ome_ex^2)* omega1, $
            String(Angle[0]*57.30,format='(I2)') ,color= 254

    oplot, dispersion_T[0,*,kappa,nAngles/2 ],sqrt(dispersion_T[1,*,kappa,nAngles/2 ]^2+ome_ex^2)* omega1,color= 254
    wait, 10
    XYOUTS, dispersion_T[0,250,kappa,nAngles/2],dispersion_T[1,250,kappa,nAngles/2]* omega1, $
            String(Angle[nAngles/2 ]*57.30,format='(I2)') ,color= 254

       omega0 = omega_pd[iome_pd]/3.716

  XYOUTS, 2.0, 20,'kappa='+String(kappas[kappa0],format='(F5.2)')+'; ' ,color=253
  XYOUTS,'Ome='+String(omega0*3.714,format='(F7.2)')+';   ',color=253

  XYOUTS, 2.0, 15,'kappa='+String(kappas[kappa],format='(F5.2)')+'; ' ,color=254
  XYOUTS,'Ome='+String(omega1*3.714,format='(F7.2)')+';   ',color=254

    oplot, dispersion_T[0,*,kappa0,0],sqrt(dispersion_T[1,*,kappa0,0]^2+ome_ex^2)* omega0,color= 253
    wait, 10

  ;  oplot, (dispersion_T[0,*,kappa0,0]+dispersion_T[0,*,kappa0,nAngles/2 ])/2.0,$
  ;        (sqrt(dispersion_T[1,*,kappa0,0]^2+ome_ex^2)* omega0+sqrt(dispersion_T[1,*,kappa0,nAngles/2 ]^2+ome_ex^2)* omega0)/2.0,$
  ;        color= 255

    oplot, dispersion_T[0,*,kappa0,nAngles/2 ],sqrt(dispersion_T[1,*,kappa0,nAngles/2 ]^2+ome_ex^2)* omega0,color= 253
    wait, 10

   ;WRITE_TIFF, dialog_pickfile(Title='Save transverse to tif file:'), TVRD(/ORDER,TRUE=1)

    window,1,xsize = 1250, ysize=950

    Plot_spectrum, Lspectrum, Dispersion1, omega0, kappas, kappa0, Data0, spacing

    oplot, dispersion_L[0,*,kappa0,0],sqrt(dispersion_L[1,*,kappa0,0]^2+ome_ex^2)* omega0,color= 254
    wait, 10
    XYOUTS, dispersion_L[0,250,kappa0,0],dispersion_L[1,250,kappa0,0]* omega0, $
            String(Angle[0]*57.30,format='(I2)') ,color= 254

    oplot, dispersion_L[0,*,kappa0,nAngles/2],sqrt(dispersion_L[1,*,kappa0,nAngles/2]^2+ome_ex^2)* omega0,color= 254
    wait, 10
    XYOUTS, dispersion_L[0,250,kappa0,nAngles/2],dispersion_L[1,250,kappa0,nAngles/2 ]* omega0, $
            String(Angle[nAngles/2 ]*57.30,format='(I2)') ,color= 254


    print, 'try again?'
    read, itry
    if(itry eq 1)then begin
       print,'kappa0=?','i ome_pd = ?'
       read, kappa0, iome_pd
       goto, try_again
    endif
    ;WRITE_TIFF, dialog_pickfile(Title='Save longitudinal to tif file:'), TVRD(/ORDER,TRUE=1)
    stop
End

; read_N_Columns, Data, 3, 5000L,1,  dialog_pickfile()
Pro  read_N_Columns, Data, N, MAX_rows,lines_skiped, filename

           F_xy = fltarr(N, MAX_rows)
              xys = fltarr(N)

     openr, 11, filename
     SKIP_LUN, 11, lines_skiped, /LINES
       i_row = 0L
    while(NOT EOF(11) AND i_row LT MAX_rows) do begin
           readf, 11, xys
           F_xy[*, i_row] = xys
                           i_row = i_row + 1L
    endwhile
    close, 11

               MAX_rows = i_row
               Data  = F_xy[*,0:MAX_rows - 1L]

End

Pro Plot_spectrum, Lspectrum, Dispersion, omega0, kappas, kappa0, Data0, spacing

                pi = 3.1415926535897932384626433832795
            numlev = 200

     n_wavenumbers = n_elements(Data0[0,*])
           n_freqs = n_elements(Lspectrum[0,*])/n_wavenumbers
           Lsmooth = fltarr(n_elements(Lspectrum[0,*]))
           Tsmooth = fltarr(n_elements(Lspectrum[0,*]))

    for wavenumber = 0, n_wavenumbers - 1 do begin
       Lsmooth[wavenumber*n_freqs:(wavenumber+1)*n_freqs-1L] =  $
             smooth(Lspectrum[0,wavenumber*n_freqs:(wavenumber+1)*n_freqs-1L],3)
    endfor

    plot_contour, numlev, Lsmooth, Lspectrum[2,*]*spacing, Lspectrum[1,*], $
                  max(Lspectrum[2,*]*spacing)<2.0*pi, 0.55*max(Lspectrum[1,*]),0.15*max(Lsmooth)

    oplot, data0[0,*]*spacing, data0[1,*], psym=5,color=253
    wait, 10

end

Pro Plot_Dispersion_relation, iKappa,Lspectrum,Tspectrum, Dispersion,omega0,kappas,Data0,data1,spacing,$
                              iKappa0,ome0

                pi = 3.14259267

     n_wavenumbers = n_elements(Data0[0,*])
           n_freqs = n_elements(Lspectrum[0,*])/n_wavenumbers
           Lsmooth = fltarr(n_elements(Lspectrum[0,*]))
           Tsmooth = fltarr(n_elements(Lspectrum[0,*]))
    for wavenumber = 0, n_wavenumbers - 1 do begin
       Lsmooth[wavenumber*n_freqs:(wavenumber+1)*n_freqs-1L] =  $
             smooth(Lspectrum[0,wavenumber*n_freqs:(wavenumber+1)*n_freqs-1L],7)
       Tsmooth[wavenumber*n_freqs:(wavenumber+1)*n_freqs-1L] =  $
             smooth(Tspectrum[0,wavenumber*n_freqs:(wavenumber+1)*n_freqs-1L],7)
    endfor
   Icontinue = 1.0
     d_omega = 0.3
      nkappa = n_elements(iKappa)
         rms = fltarr(4,nkappa)
    rms[*,*] = 1.0E10
      numlev = 200

    window, 1, xsize=1250, ysize=950
    !P.MULTI = [0, 2, 1]

loop:  print,''
    for iloop = 0, 200L do begin

       omega0 = omega0 + Icontinue * d_omega

        plot_contour, numlev, Lsmooth, Lspectrum[2,*]*spacing, Lspectrum[1,*], $
                      max(Lspectrum[2,*]*spacing)<2.0*pi, 0.55*max(Lspectrum[1,*]),0.25*max(Lsmooth)
        oplot, data0[0,*]*spacing, data0[1,*], psym=1
        wait, 10

      for kappa = 0, nkappa -1L do begin

          oplot, dispersion[0,*,iKappa[kappa],0],dispersion[1,*,iKappa[kappa],0]*(rms[2,kappa]<omega0)
          wait, 10

          closest = Min(abs(Dispersion[0,*,iKappa[kappa],0]- 1.5*pi), TheClosest)
          XYOUTS,Dispersion[0,TheClosest,iKappa[kappa],0], dispersion[1,TheClosest,[kappa],0]*omega0, $
                 String(kappas[ikappa[kappa]],format='(F4.2)'),color=253

          closest1 = Min(abs(Dispersion[0,*,iKappa[kappa],0] - 1.5*pi), TheClosest1)
          closest2 = Min(abs(data0[0,*]*spacing - 1.5*pi), TheClosest2)
          result = INTERPOL(dispersion[1,0:TheClosest1,iKappa[kappa],0]*omega0, dispersion[0,0:TheClosest1,iKappa[kappa],0], data0[0,0:TheClosest2]*spacing)
            rms0 = total((result - data0[1,0:TheClosest2])^2/result^2)
            if(rms0 LT rms[0,kappa])then begin
               rms[0,kappa] = rms0
               rms[2,kappa] = omega0
            endif
          XYOUTS,1.5,20+1.5*float(kappa),'kappa='+String(kappas[ikappa[kappa]],format='(F5.2)')+'; ' ,color=253
          XYOUTS,'RMS='+String(rms[0,kappa],format='(F9.2)')+'; ',color=253
          XYOUTS,'Ome='+String(rms[2,kappa]*3.714,format='(F7.2)'),color=253

      endfor


        plot_contour, numlev, Tsmooth, Tspectrum[2,*]*spacing, Tspectrum[1,*], $
                      max(Tspectrum[2,*]*spacing)<2.0*pi, 0.55*max(Tspectrum[1,*]),0.4*max(Tsmooth)
        oplot,data1[0,*]*spacing,data1[1,*],psym=2,color=255
        wait, 10

     for kappa = 0, nkappa -1L do begin

          oplot, dispersion[0,*,iKappa[kappa],1],dispersion[1,*,iKappa[kappa],1]*(rms[2,kappa]<omega0),color=255
          wait, 10

          Tclosest1 = Min(abs(Dispersion[0,*,iKappa[kappa],1] - pi), TheT_Closest1)
          Tclosest2 = Min(abs(data1[0,*]*spacing - pi), TheT_Closest2)
          Tresult = INTERPOL(dispersion[1,0:TheT_Closest1,iKappa[kappa],1]*rms[2,kappa], dispersion[0,0:TheT_Closest1,iKappa[kappa],1], data1[0,0:TheT_Closest2]*spacing)
          rms[1,kappa] = total((Tresult - data1[1,0:TheT_Closest2])^2/Tresult^2)
          rms[3,kappa] = rms[0,kappa] + rms[1,kappa]

          XYOUTS,0.1,55+1.5*float(kappa),'kappa='+String(kappas[ikappa[kappa]],format='(F5.2)')+'; ' ,color=253
          XYOUTS,'RMS='+String(rms[1,kappa],format='(F9.2)')+'; ',color=253
          XYOUTS,'RMS_tot='+String(rms[3,kappa],format='(F6.2)') ,color=253

     endfor

    endfor

    read,Icontinue

    if(abs(Icontinue) EQ 1)then goto,loop

    window, 2, xsize=1250, ysize=950
    !P.MULTI = [0, 2, 1]

    minRMS = min(RMS[3,*],kappa0)

    plot_contour, numlev, Lsmooth, Lspectrum[2,*]*spacing, Lspectrum[1,*], $
                      max(Lspectrum[2,*]*spacing)<2.0*pi, 0.55*max(Lspectrum[1,*]),0.25*max(Lsmooth)
    oplot, data0[0,*]*spacing, data0[1,*], psym=1
    wait, 10
  oplot, dispersion[0,*,iKappa[kappa0],0],dispersion[1,*,iKappa[kappa0],0]*rms[2,kappa0]
  wait, 10

    XYOUTS,1.5,20,'kappa='+String(kappas[ikappa[kappa0]],format='(F5.2)')+'; ' ,color=253
  XYOUTS,'Ome='+String(rms[2,kappa0]*3.714,format='(F7.2)'),color=253

    plot_contour, numlev, Tsmooth, Tspectrum[2,*]*spacing, Tspectrum[1,*], $
                      max(Tspectrum[2,*]*spacing)<2.0*pi, 0.55*max(Tspectrum[1,*]),0.25*max(Tsmooth)
    oplot,data1[0,*]*spacing,data1[1,*],psym=2,color=255
    wait, 10
    oplot, dispersion[0,*,iKappa[kappa0],1],dispersion[1,*,iKappa[kappa0],1]*rms[2,kappa0],color=255
    wait, 10
    ikappa0 = iKappa[kappa0]
       ome0 = rms[2,kappa0]

    window, 3, xsize=1250, ysize=950
    !P.MULTI = [0, 2, 1]

    minRMS = min(RMS[0,*],kappa0)

    plot_contour, numlev, Lsmooth, Lspectrum[2,*]*spacing, Lspectrum[1,*], $
                      max(Lspectrum[2,*]*spacing)<2.0*pi, 0.55*max(Lspectrum[1,*]),0.25*max(Lsmooth)
    oplot, data0[0,*]*spacing, data0[1,*], psym=1
    wait, 10
  oplot, dispersion[0,*,iKappa[kappa0],0],dispersion[1,*,iKappa[kappa0],0]*rms[2,kappa0]
  wait, 10

    XYOUTS,1.5,20,'kappa='+String(kappas[ikappa[kappa0]],format='(F5.2)')+'; ' ,color=253
  XYOUTS,'Ome='+String(rms[2,kappa0]*3.714,format='(F7.2)'),color=253

    plot_contour, numlev, Tsmooth, Tspectrum[2,*]*spacing, Tspectrum[1,*], $
                      max(Tspectrum[2,*]*spacing)<2.0*pi, 0.55*max(Tspectrum[1,*]),0.25*max(Tsmooth)
    oplot,data1[0,*]*spacing,data1[1,*],psym=2,color=255
    wait, 10
    oplot, dispersion[0,*,iKappa[kappa0],1],dispersion[1,*,iKappa[kappa0],1]*rms[2,kappa0],color=255
    wait, 10

end

Pro plot_contour, Z, X, Y, Xmin, Xmax, Ymin, Ymax,filename
wait, 10

    Creat_CT,R,G,B
    ; Device,Retain=2, Decomposed=0  ;important to make the display true color

          numlev = 7

       my_levels = fltarr(numlev)
    my_levels[0] = min(Z)
    my_levels[1] = min(Z) + 2.30   ;68.3%
    my_levels[2] = min(Z) + 4.61   ;90%
    my_levels[3] = min(Z) + 6.17   ;95.4%
    my_levels[4] = min(Z) + 9.21   ;99%
    my_levels[5] = min(Z) + 18.4   ;99.99%
    my_levels[6] = min(Z) + 23.0    ;99.999%

        my_color = bytarr(numlev)
     my_color[0] = 255
     my_color[1] = 50
     my_color[2] = 100
     my_color[3] = 150
     my_color[4] = 200
     my_color[5] = 253
     my_color[6] = 255

       my_labels = [1,1,1,1,1,1,1]

           index = where(Z LE my_levels[6])
            Xmin = min(X[index])
            Xmax = max(X[index])
            Ymin = min(Y[index])
            Ymax = max(Y[index])

    SET_PLOT, 'PS'
    DEVICE, FILE = filename+'.ps', /COLOR, BITS=8

    contour, Z, X, Y, /Fill,$ ;
             nlevels=numlev, C_COLOR=my_color, color=0, $
             xrange=[Xmin, Xmax], yrange=[Ymin,Ymax], xstyle=1, ystyle = 1, $
             background=255, $
             LEVELS = my_levels, Xtitle='Slope',Ytitle='Interception', XCHARSIZE = 1.25,YCHARSIZE = 1.25

    CONTOUR, Z, X, Y,C_Labels=my_labels,nlevels=numlev,  LEVELS = my_levels, /OVERPLOT
    wait, 10
    XYOUTS, Xmin+(Xmax-Xmin)/10.0,Ymin+(Ymax-Ymin)/10.0, strcompress('Min. Chi^2 = '+string(my_levels[0]) ),color=253,CHARSIZE=1.25

    DEVICE, /CLOSE
    SET_PLOT, 'WIN'

    loadct, 0

    ;99% confidence level
    index = where(Z LE my_levels[4])
     Xmin = min(X[index])
     Xmax = max(X[index])
     Ymin = min(Y[index])
     Ymax = max(Y[index])

End

Pro Creat_CT,R,G,B

;creat a 256 color table:blue --> green --> yellow -->red + black + white

R = bytarr(256)
G = bytarr(256)
B = bytarr(256)

for i=0,255 do begin

    If (i ge 0) and (i le 63) then begin
       R[i]=0
       G[i]=4*i+3
       B[i]=255
    endif
    G[0]=0

    if (i ge 64) and (i le 127) then begin
        R[i]=0
        G[i]=255
        B[i]=255-(4*(i-64)+3)
    endif

    if (i ge 128) and (i le 181) then begin
        R[i]=4*(i-128)+3
        G[i]=255
        B[i]=0
    endif

    if (i ge 182) and (i le 255) then begin
        R[i]=255
        G[i]=255-(4*(i-182)+3)
        B[i]=0
    endif
    G[253]=0

    R[254]=0
    G[254]=0
    B[254]=0

    R[255]=255
    G[255]=255
    B[255]=255
endfor
TVLCT, R, G, B

end


Pro Creat_CT_gray



R = bytarr(256)
G = bytarr(256)
B = bytarr(256)

for i=0,253 do begin

       R[i]=i
       G[i]=i
       B[i]=i

endfor

R[254]=0
G[254]=0
B[254]=0

R[255]=255
G[255]=255
B[255]=255

TVLCT, R, G, B

end