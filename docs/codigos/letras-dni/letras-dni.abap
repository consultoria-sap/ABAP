DATA: gv_dni(8) TYPE c VALUE '12345678',
gv_result TYPE tline-tdline,
gv_add TYPE string,
gv_n TYPE i VALUE 8,
gv_value TYPE itcdp-tdlcount,
gv_count TYPE i.

DO gv_n TIMES.

gv_value = gv_dni+gv_count(1).

CALL FUNCTION 'CONVERT_NUMBER'
EXPORTING
tdlcount = gv_value
tdnumberin = 'LETTER'
tdupper = 'X'
tdnumfixc = '12'
tdnumoutl = '01'
IMPORTING
string = gv_result.

CONCATENATE gv_result '' INTO gv_add.
ADD 1 TO gv_count.
WRITE gv_add.
ENDDO.
