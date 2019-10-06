;    read_data1,xy_t,Vxy_t,N_particles,N_frames,filename, 0.01845, 0.018, /Scale
Pro read_data_1,xy_t,Vxy_t,N_particles,N_frames,filename, length_scale, time_scale, Scale = Scale
;==============================================================================
;read data (in Samsonov file format) into array xy_t[4,N_particles,N_frames]
;-------------------------------------------------------------------------------

;filename=dialog_pickfile()

GET_LUN, U

openr,U,filename

readf,U,N_particles,N_frames


N_particles = N_particles + 1 ; this line is used when working with the output of Feng's threading code

 xy_t = fltarr(2,N_particles,N_frames)
Vxy_t = fltarr(2,N_particles,N_frames)

while(not EOF(U) )do begin
    x=0.0
    y=0.0
    vx=0.0
    vy=0.0
    jframe=0
    iparticle=0
    readf,U,x,y,vx,vy,jframe,iparticle
    if(jframe ge N_Frames) then goto, jump1
    xy_t(0,iparticle,jframe)=x
    xy_t(1,iparticle,jframe)=y
    Vxy_t(0,iparticle,jframe)=vx
    Vxy_t(1,iparticle,jframe)=vy
endwhile
jump1: print, N_particles, ' particles and ', N_Frames, ' frames has been read.'

FREE_LUN, U

if Keyword_set(Scale)then begin
    scale_to_physical_units,  xy_t, length_scale, time_scale, /Position
    scale_to_physical_units, Vxy_t, length_scale, time_scale, /Velo
    print, 'Data were scaled to physical units: [mm] and [s].'
endif

return
End

