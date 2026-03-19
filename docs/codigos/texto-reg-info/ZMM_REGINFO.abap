*&---------------------------------------------------------------------*
*& Report  ZMM_REGINFO
*&
*----------------------------------------------------------------------*
*                     Modificaciones                                   *
*----------------------------------------------------------------------*
* Fecha        Autor         Req     Descripción                       *
*                                                                      *
*----------------------------------------------------------------------*


REPORT ZMM_REGINFO.

INCLUDE: ZMM_REGINFO_top.

INCLUDE ZMM_REGINFO_alvf01.

************************************************************************
******************** I N I T I A L I Z A T I O N ***********************
************************************************************************
INITIALIZATION.

************************************************************************
*SELECTION-SCREEN
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1.
  SELECT-OPTIONS: s_lifnr for eina-lifnr,
                  s_matnr FOR eina-matnr,
                  s_infnr FOR eina-infnr.

SELECTION-SCREEN END OF BLOCK b1.

************************************************************************
*AT SELECTION SCREEN
************************************************************************
AT SELECTION-SCREEN.

************************************************************************
***          START-OF-SELECTION
************************************************************************
START-OF-SELECTION.


    SELECT a~lifnr a~matnr a~infnr
       FROM eina AS a

      INTO CORRESPONDING FIELDS OF TABLE TI_TABLA

        WHERE a~lifnr IN s_lifnr
          AND a~matnr IN s_matnr
          AND a~infnr IN s_infnr.

** completo nombre de proveedor
SELECT lifnr name1
  FROM lfa1
  INTO CORRESPONDING FIELDS OF TABLE TI_TABLAAUX.

LOOP AT ti_tablaaux into st_tablaaux.
  st_tabla-lifnr = st_tablaaux-lifnr.
  st_tabla-name1 = st_tablaaux-name1.
  MODIFY ti_tabla
    FROM st_tabla
    TRANSPORTING name1
    WHERE lifnr = st_tablaaux-lifnr.
ENDLOOP.

IF ti_tabla[] IS NOT INITIAL.
*  * completo nombre de material
  SELECT matnr maktx
    FROM makt
    INTO CORRESPONDING FIELDS OF TABLE TI_TABLAAUX1.

  LOOP AT ti_tablaaux1 into st_tablaaux1.
    st_tabla-matnr = st_tablaaux1-matnr.
    st_tabla-maktx = st_tablaaux1-maktx.
    MODIFY ti_tabla
      FROM st_tabla
      TRANSPORTING maktx
      WHERE matnr = st_tablaaux1-matnr.
  ENDLOOP.


  LOOP AT TI_TABLA into st_tabla.

*   Busco el texto
      REFRESH lt_lines.
      CLEAR: var.
      lc_id = 'AT'. " Texto donde está el STRING buscado
      lc_object = 'EINA'. " Tabla de textos
      lc_name = st_tabla-infnr. "'5300000110'. " Respetar ceros a la izquierda (si hubiere) y entre el Pedido y la Posición
      CALL FUNCTION 'READ_TEXT'
       EXPORTING
         id = lc_id
         language = sy-langu
         name = lc_name
         object = lc_object
       TABLES
         lines = lt_lines
         EXCEPTIONS
         id = 1
         language = 2
         name = 3
         not_found = 4
         object = 5
         reference_check = 6
         wrong_access_to_archive = 7
      OTHERS = 8.

      LOOP AT lt_lines.

         st_tabla-lt_lines =  lt_lines-tdline.
         CONCATENATE var st_tabla-lt_lines  INTO var SEPARATED BY space.

      ENDLOOP.
      st_tabla-lt_lines = var.
*       quita ceros de codigo de material
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT         = st_tabla-matnr
        IMPORTING
          OUTPUT        = st_tabla-matnr.
*       quita ceros de codigo proveedor
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT         = st_tabla-lifnr
        IMPORTING
          OUTPUT        = st_tabla-lifnr.

    MODIFY TI_TABLA from st_tabla.

  ENDLOOP.

ENDIF.

SORT TI_TABLA by lifnr matnr .

PERFORM alv.
