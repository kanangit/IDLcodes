PRO driver_anmake4cols

pos = readimagejk4Feng()
maxFr = MIN(pos.iFrame)-1
pos.iFrame = pos.iFrame-maxFr
p4cols = print4arrays('position4.csv',pos.iParticle,pos.iFrame,pos.X,pos.Y);

pos = 0

END