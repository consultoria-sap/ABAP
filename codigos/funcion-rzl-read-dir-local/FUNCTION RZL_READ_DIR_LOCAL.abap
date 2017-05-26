FUNCTION RZL_READ_DIR_LOCAL.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(NAME) LIKE  SALFILE-LONGNAME
*"  TABLES
*"      FILE_TBL STRUCTURE  SALFLDIR
*"  EXCEPTIONS
*"      ARGUMENT_ERROR
*"      NOT_FOUND
*"      NO_ADMIN_AUTHORITY
*"----------------------------------------------------------------------

DATA: BEGIN OF LINE_TBL OCCURS 100.
        INCLUDE STRUCTURE SPFLIST.
DATA: END OF LINE_TBL.

DATA: LOC_NAME(200).
DATA: LOC_DIR(200).
DATA: TMP_LOC_DIR(200).
DATA: LOC_DIR_LEN TYPE I.
DATA: FULL_NAME(400).

*  Check administrator authority
  AUTHORITY-CHECK OBJECT 'S_RZL_ADM'
     ID 'ACTVT' FIELD '01'.
  IF sy-subrc <> 0.
    RAISE NO_ADMIN_AUTHORITY.
  ENDIF.


 IF NAME <> SPACE.
  LOC_NAME = NAME.
  LOC_DIR = NAME.
  SHIFT LOC_DIR LEFT BY 2 PLACES.
  LOC_DIR_LEN = STRLEN( LOC_DIR ).
  LOC_DIR_LEN = LOC_DIR_LEN - 1.
  SHIFT LOC_DIR CIRCULAR LEFT BY LOC_DIR_LEN PLACES.
  IF LOC_NAME(2) = '$(' AND LOC_DIR(1) = ')'.
   LOC_DIR(1) = SPACE.
   SHIFT LOC_DIR CIRCULAR RIGHT BY LOC_DIR_LEN PLACES.
   CALL 'C_SAPGPARAM' ID 'NAME'   FIELD LOC_DIR
                      ID 'VALUE'  FIELD LOC_DIR.

   IF SY-SUBRC =  0.
    FULL_NAME = LOC_DIR.
   ELSE.
    FULL_NAME = NAME.
   ENDIF.

  ELSE.
   FULL_NAME = NAME.
  ENDIF.

 ELSE.
  FULL_NAME = NAME.
 ENDIF.

  REFRESH LINE_TBL.

************************************************************************
*  Send Request, wait for Response
************************************************************************
  CALL 'ALERTS'  ID 'ADMODE'       FIELD  AD_RZL
                 ID  'OPCODE'       FIELD RZL_OP_RD_DIR
                 ID  'FILE_NAME'    FIELD FULL_NAME
                 ID  'DIR_TBL'      FIELD LINE_TBL-*SYS*.

  CASE SY-SUBRC.
    WHEN 0.   LOOP AT LINE_TBL.
                FILE_TBL-SIZE = LINE_TBL(11).
                FILE_TBL-NAME = LINE_TBL+12.
                APPEND FILE_TBL.
              ENDLOOP.
    WHEN OTHERS.  RAISE NOT_FOUND.
  ENDCASE.

ENDFUNCTION.
