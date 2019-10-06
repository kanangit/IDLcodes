pro driver_trimimagej
startframe = 1000
endframe = 1100
full = readImageJk(/lowmem)
ind = where(full.iFrame GE startframe AND full.iFrame LE endframe)
resultat = print6arrays('positionDebug100frames.txt',full.iParticle[ind],full.iFrame[ind],full.area[ind],full.X[ind],full.Y[ind],full.error[ind])
end