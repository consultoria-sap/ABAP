METHOD set_classification.
" Signature of this method
" Importing :
" IV_OBJECTKEY TYPE OBJNUM
" IV_KLART TYPE KLASSENART
" IV_ATNAM TYPE ATNAM
" IV_VALUE_NEW TYPE ATWRT
" Exporting :
" ET_RETURN TYPE BAPIRETTAB
DATA: lv_objectkey TYPE objnum, ,
lv_objecttable TYPE tabelle,
lv_classnum TYPE klasse_d,
lv_classtype TYPE klassenart.
DATA: lt_allocvaluesnum TYPE TABLE OF bapi1003_alloc_values_num,
lt_allocvalueschar TYPE TABLE OF bapi1003_alloc_values_char,
ls_allocvalueschar LIKE LINE OF lt_allocvalueschar,
lt_allocvaluescurr TYPE TABLE OF bapi1003_alloc_values_curr,
lt_return TYPE TABLE OF bapiret2.
DATA: lv_status TYPE clstatus,
lv_standardclass TYPE stdclass.
DATA: lt_allocvaluescharnew TYPE TABLE OF bapi1003_alloc_values_char,
ls_allocvaluescharnew LIKE LINE OF lt_allocvaluescharnew.
DATA: lt_allocvaluesnumnew TYPE TABLE OF bapi1003_alloc_values_num,
lt_allocvaluescurrnew TYPE TABLE OF bapi1003_alloc_values_curr.
lv_objectkey = iv_objectkey.
" Get Class Type and Object Table for this Characteristic
SELECT SINGLE klart obtab FROM tcla
INTO (lv_classtype , lv_objecttable)
WHERE klart = iv_klart.
IF sy-subrc NE 0 .
RETURN.
ENDIF.
" Get the Class Num of Characteristic
SELECT SINGLE class FROM klah
INTO lv_classnum
WHERE klart = iv_klart.
IF sy-subrc NE 0 .
RETURN.
ENDIF.
" Check if this Characteristic exist : Update or Creation ?
CALL FUNCTION 'BAPI_OBJCL_GETDETAIL'
EXPORTING
objectkey       = lv_objectkey
objecttable     = lv_objecttable
classnum        = lv_classnum
classtype       = lv_classtype
IMPORTING
status          = lv_status
standardclass   = lv_standardclass
TABLES
allocvaluesnum  = lt_allocvaluesnum
allocvalueschar = lt_allocvalueschar
allocvaluescurr = lt_allocvaluescurr
return          = lt_return.
APPEND LINES OF lt_return TO et_return. REFRESH lt_return.
SORT lt_allocvalueschar BY charact.
" fill the new Characteristic value
READ TABLE lt_allocvalueschar TRANSPORTING NO FIELDS
WITH KEY charact = iv_atnam.
IF sy-subrc = 0 .
ls_allocvaluescharnew-charact = iv_atnam.
"ls_allocvaluescharnew-value_char = iv_value_new.
CLEAR ls_allocvaluescharnew-inherited .
CLEAR ls_allocvaluescharnew-instance .
ls_allocvaluescharnew-value_neutral = iv_value_new.
CLEAR ls_allocvaluescharnew-charact_descr .
APPEND ls_allocvaluescharnew TO lt_allocvaluescharnew.
ENDIF.
LOOP AT lt_allocvalueschar INTO ls_allocvalueschar.
IF ls_allocvalueschar-charact = iv_atnam.
ls_allocvaluescharnew-charact = iv_atnam.
"ls_allocvaluescharnew-value_char = iv_value_new.
CLEAR ls_allocvaluescharnew-inherited .
CLEAR ls_allocvaluescharnew-instance .
ls_allocvaluescharnew-value_neutral = iv_value_new.
CLEAR ls_allocvaluescharnew-charact_descr .
ELSE.
MOVE-CORRESPONDING ls_allocvalueschar TO ls_allocvaluescharnew.
ENDIF.
APPEND ls_allocvaluescharnew TO lt_allocvaluescharnew.
ENDLOOP.
" Update Characteristic Value in Sap
CALL FUNCTION 'BAPI_OBJCL_CHANGE'
EXPORTING
objectkey          = lv_objectkey
objecttable        = lv_objecttable
classnum           = lv_classnum
classtype          = lv_classtype
TABLES
allocvaluesnumnew  = lt_allocvaluesnumnew
allocvaluescharnew = lt_allocvaluescharnew
allocvaluescurrnew = lt_allocvaluescurrnew
return             = lt_return.
APPEND LINES OF lt_return TO et_return. REFRESH lt_return.
" If no error occurs, commit work to Update Characteristic Value in Sap
READ TABLE et_return TRANSPORTING NO FIELDS
WITH KEY type = 'E'.
IF sy-subrc NE 0 .
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
EXPORTING
wait = 'X'.
ENDIF.
ENDMETHOD.                    "set_classification
