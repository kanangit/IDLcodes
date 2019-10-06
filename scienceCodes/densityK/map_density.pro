;; map_density, 8, 6, 1600., 1200., .014644, .016667
pro map_density, nx, ny, xsize, ysize, length_scale, time_scale
      ;;nx, ny: number of bins in x- and y-direction
      ;;xsize, ysize: length of images in x- and y-direction in pixels
      ;;v2: 4-27-15  added mapping of velocity field
stop
read_data_1, xy_t,Vxy_t,N_particles,N_frames,datafile, length_scale, time_scale;, /Scale

xbin = (xsize/float(nx));*length_scale
x = xbin*findgen(nx) + .5*xbin
ybin = (ysize/float(ny));*length_scale
y = ybin*findgen(ny) + .5*ybin

N_t = fltarr(nx,ny,N_frames)
Vavg_t = fltarr(2, nx, ny, N_frames)

for iframe=0,N_frames-1 do begin
  index1 = where(xy_t[0,*, iframe] NE 0.0 AND  xy_t[1,*, iframe] NE 0.0 $
          AND (Vxy_t[0,*, iframe] NE 0.0 OR  Vxy_t[1,*, iframe] NE 0.0), count)
  xtemp = reform(xy_t[0, index1, iframe])
  ytemp = reform(xy_t[1, index1, iframe])
  Vxytemp = reform(Vxy_t[*,index1,iframe])
  for ix=0,nx-1 do begin
    for iy=0,ny-1 do begin
      index2 = where(xtemp gt ix*xbin and xtemp le (ix+1)*xbin $
               and ytemp gt iy*ybin and ytemp le (iy+1)*ybin, countthis)
      N_t[ix,iy,iframe] = countthis
      Vavg_t[0,ix,iy,iframe] = mean(Vxytemp[0,index2])
      Vavg_t[1,ix,iy,iframe] = mean(Vxytemp[1,index2])
    endfor
  endfor
endfor

N_avg = mean(N_t, dimension=3)
Vxavg = reform(mean(Vavg_t[0,*,*,*], dimension=4))
Vyavg = reform(mean(Vavg_t[1,*,*,*], dimension=4))

contour, N_avg, x, y, nlevels=20, c_labels=[1,1,1,1,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,1], /isotropic

stop

velovect, Vxavg, Vyavg, x, y, /isotropic

stop

end