;read_data_particles, xy_t, Vxy_t, N_particles, 0, N_frames, filename, length_scale,time_scale, /Scale
Pro read_data_particles, xy_t, Vxy_t, N_particles, max_particles, N_frames, filename,$
                         length_scale, time_scale, Scale = Scale

     if (filename eq ' ')then filename = dialog_pickfile()

     GET_LUN, U
     openr, U, filename

     readf, U, N_particles,  N_frames

     if (max_particles eq 0)then max_particles = N_Particles

            xy_t = fltarr(2, max_particles, N_frames )
           Vxy_t = fltarr(2, max_particles, N_frames)

       iparticle = 0
          jframe = 0
       while(not EOF(U) )do begin

            readf, U, x, y, vx, vy, jframe, iparticle
            if(iparticle ge max_particles) then goto, jump1
            if(jframe ge N_Frames) then goto, jump1
            xy_t[0, iparticle, jframe] = x
            xy_t[1, iparticle, jframe] = y
           Vxy_t[0, iparticle, jframe] = vx
           Vxy_t[1, iparticle, jframe] = vy

       ;    if(iparticle MOD 50 eq 0 AND jframe eq 0)then print,'particle#:',iparticle

       endwhile

jump1: print, iparticle, 'particles have been read in'
       N_Particles = iparticle

       FREE_LUN, U

      if Keyword_set(Scale)then begin
         scale_to_physical_units,  xy_t, length_scale, time_scale, /Position
         scale_to_physical_units, Vxy_t, length_scale, time_scale, /Velo
      endif

return
End




Pro scale_to_physical_units, Data_array, length_scale, time_scale, Position = Position, Velo = Velo, Time = Time

    velocity_scale = length_scale / time_scale

    if keyword_set(Position)then Data_array = Data_array * length_scale
    if keyword_set(    Velo)then Data_array = Data_array * velocity_scale
    if keyword_set(    Time)then Data_array = Data_array * time_scale

end