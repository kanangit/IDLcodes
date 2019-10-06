PRO driver_antiff


;filename = DIALOG_PICKFILE(/READ, FILTER = '*.tif*')

;a = READ_TIFF(filename);

;help,a

A = Transpose(MAKE_ARRAY(10, 3, /INTEGER, VALUE = 5))
B = Transpose(MAKE_ARRAY(10, 8, /INTEGER, VALUE = 3))
test = [A,B]
print, Transpose(test)
stop

END