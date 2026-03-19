method set_classification.

" Signature of this method 
" Importing : 
" 	IV_OBJECTKEY	TYPE OBJNUM
"	IV_KLART	TYPE KLASSENART
"	IV_ATNAM	TYPE ATNAM
"	IV_VALUE_NEW	TYPE ATWRT
" Exporting :
"   ET_RETURN	TYPE BAPIRETTAB


  data: lv_objectkey        type objnum, ,
        lv_objecttable      type tabelle,
        lv_classnum         type klasse_d,
        lv_classtype        type klassenart.

  data: lt_allocvaluesnum	type table of	bapi1003_alloc_values_num,
        lt_allocvalueschar  type table of bapi1003_alloc_values_char,
        ls_allocvalueschar  like line of  lt_allocvalueschar,
        lt_allocvaluescurr  type table of bapi1003_alloc_values_curr,
        lt_return	        type table of	bapiret2.

  data: lv_status           type clstatus, 
        lv_standardclass    type stdclass. 


  data: lt_allocvaluescharnew type table of  bapi1003_alloc_values_char,
        ls_allocvaluescharnew like line of   lt_allocvaluescharnew.

  data: lt_allocvaluesnumnew  type table of bapi1003_alloc_values_num,
        lt_allocvaluescurrnew	type table of	bapi1003_alloc_values_curr.


  lv_objectkey = iv_objectkey.
  
  " Get Class Type and Object Table for this Characteristic
  select single klart obtab from tcla
    into (lv_classtype , lv_objecttable)
    where klart = iv_klart.
  if sy-subrc ne 0 .
    return.
  endif.
 
  " Get the Class Num of Characteristic
  select single class from klah
    into lv_classnum
    where klart = iv_klart.
  if sy-subrc ne 0 .
    return.
  endif.

  " Check if this Characteristic exist : Update or Creation ?
  call function 'BAPI_OBJCL_GETDETAIL'
    exporting
      objectkey              = lv_objectkey
      objecttable            = lv_objecttable
      classnum               = lv_classnum
      classtype              = lv_classtype
*     KEYDATE                = SY-DATUM
*     UNVALUATED_CHARS       = ' '
*     LANGUAGE               = SY-LANGU
   importing
     status                 = lv_status
     standardclass          = lv_standardclass
    tables
      allocvaluesnum         = lt_allocvaluesnum
      allocvalueschar        = lt_allocvalueschar
      allocvaluescurr        = lt_allocvaluescurr
      return                 = lt_return.

  append lines of lt_return to et_return. refresh lt_return.
  sort lt_allocvalueschar by charact.
	
  " fill the new Characteristic value 
  loop at lt_allocvalueschar into ls_allocvalueschar.
    if ls_allocvalueschar-charact = iv_atnam.
      ls_allocvaluescharnew-charact = iv_atnam.
      ls_allocvaluescharnew-value_char = iv_value_new.
      clear ls_allocvaluescharnew-inherited .
      clear ls_allocvaluescharnew-instance .
      ls_allocvaluescharnew-value_neutral = iv_value_new.
      clear ls_allocvaluescharnew-charact_descr .
    else.
      move-corresponding ls_allocvalueschar to ls_allocvaluescharnew.
    endif.

    append ls_allocvaluescharnew to lt_allocvaluescharnew.
  endloop.

  " Update Characteristic
  call function 'BAPI_OBJCL_CHANGE'
    exporting
      objectkey          = lv_objectkey
      objecttable        = lv_objecttable
      classnum           = lv_classnum
      classtype          = lv_classtype
    tables
      allocvaluesnumnew  = lt_allocvaluesnumnew
      allocvaluescharnew = lt_allocvaluescharnew
      allocvaluescurrnew = lt_allocvaluescurrnew
      return             = lt_return.

  append lines of lt_return to et_return. refresh lt_return.
  
  " If no error occurs, commit work
  read table et_return transporting no fields
  with key type = 'E'.
  if sy-subrc ne 0 .
    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait = 'X'.
  endif.

endmethod.
