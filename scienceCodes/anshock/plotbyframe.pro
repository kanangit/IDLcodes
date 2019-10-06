PRO plotByFrame

;scale = 0.02543d
scale = 1.0d;
yMaxCoord = 1200;



s=readImageJK()
yMax = MAX(s.Y)
yMin = MIN(s.Y);
minFrame=MIN(s.iFrame);
maxFrame = MAX(s.iFrame)

FOR i=minFrame, maxFrame DO BEGIN
  ind= WHERE(s.iFrame EQ i)
  curX = scale*s.X[ind]
  curY = scale*(yMaxCoord - s.Y[ind]) ; because the vertical screen coordinates
  ;are from top to bottom, we make this change of variables  
  print, i  
  p =plot(curX, curY, SYMBOL='dot', OVERPLOT = 1, XRANGE=[0,1600], YRANGE = [0,1200], LINESTYLE = 'none')
 ; wait,1 
  
  filename = STRCOMPRESS('frame'+STRING(i,FORMAT='(I04)')+'.csv')
  z=print2arrays(filename,curX,curY)
  p.Delete 
  ;
ENDFOR

END