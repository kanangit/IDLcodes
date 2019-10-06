;v1.2 function calculates particles velocities by fitting

FUNCTION find_vel, input
t0 = DOUBLE(input[2,0])
dt = DOUBLE(input[2,1]) - DOUBLE(input[2,0])
dt2 = dt / 2.0d
tnew = t0 + dt2
t = DOUBLE(TRANSPOSE(input[2,*])) - t0
x = DOUBLE(TRANSPOSE(input[0,*]))
y = DOUBLE(TRANSPOSE(input[1,*]))
coeffsx = POLY_FIT(t,x,2,/DOUBLE); coeffs
coeffsy = POLY_FIT(t,y,2,/DOUBLE); coeffs


xnew = coeffsx[0]+dt2*coeffsx[1]+dt2^2*coeffsx[2]
vxnew = coeffsx[1] + dt2*coeffsx[2]
ynew = coeffsy[0]+dt2*coeffsy[1]+dt2^2*coeffsy[2]
vynew = coeffsy[1] + dt2*coeffsy[2]
retArr = [xnew,ynew,tnew,input[3,0],vxnew,vynew,coeffsx[2],coeffsy[2]]
RETURN, retArr

END