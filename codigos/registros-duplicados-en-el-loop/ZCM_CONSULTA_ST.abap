*&---------------------------------------------------------------------*
*& Report  ZCM_CONSULTA_ST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zcm_consulta_st.

******************************************************
* Declaro mi tabla interna y area de trabajo
******************************************************

DATA: it_consu1 TYPE STANDARD TABLE OF zcm_hrp1000, "consigo objid y nombre
      wa_consu1 LIKE LINE OF it_consu1,

      it_consu2 TYPE STANDARD TABLE OF cmacbpst, "consigo cedula y objid
      wa_consu2 LIKE LINE OF it_consu2,

      it_consu3 TYPE STANDARD TABLE OF zcm_hrp1001, "consigo otype, sclas y sobid
      wa_consu3 LIKE LINE OF it_consu3.


******************************************************
* Pantalla de selección
******************************************************

SELECTION-SCREEN BEGIN OF BLOCK consult WITH FRAME TITLE text-001.
PARAMETERS cedula TYPE cmacbpst-student12.
SELECTION-SCREEN END OF BLOCK consult.

******************************************************
* Cargo mis datos en las tablas internas
******************************************************

SELECT * FROM cmacbpst INTO TABLE it_consu2
  WHERE student12 = cedula. "Filtro la información segun la cedula seleccionada

  IF sy-subrc = 0.
    PERFORM llenado.
    ELSE.
  WRITE '*** Ingrese un número de cédula de un estudiante valido ***'.
  ENDIF.

******************************************************
* Recorro e imprimo lo que necesito
******************************************************

PERFORM llenado.

*&---------------------------------------------------------------------*
*&      Form  LLENADO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM llenado.

LOOP AT it_consu2 INTO wa_consu2.
  "Cargo la información del estudiante filtrada por la cedula
  "ingresada, al area de trabajo
ENDLOOP.

  "Filtro la info segun el stobjid de la cedula ingresada para saber el objid y nombre desde la zcm_hrp1000, 
  "tambien filtro por el otype para mostrar solo los registros de estudiantes
SELECT * FROM zcm_hrp1000 INTO TABLE it_consu1
  WHERE objid = wa_consu2-stobjid AND otype = 'ST'.   


LOOP AT it_consu1 INTO wa_consu1.
  "Cargo la información del estudiante comparada por el objid y filtrada por otype = ST
  "para traer información de objid y nombre desde la zcm_hrp1000
ENDLOOP.

SELECT * from zcm_hrp1001 into TABLE it_consu3
  WHERE objid = wa_consu2-stobjid and
  otype = 'ST'. 
  "filtro por el objid para sacar otype, sclas y sobid desde la zcm_hrp1001

  LOOP AT it_consu3 into wa_consu3.
  "Cargo la información del estudiante comparada por el objid y filtrada por objid
  "para traer otype, sclas y sobid desde la zcm_hrp1001

WRITE:/ sy-vline, wa_consu2-student12, sy-vline,
        wa_consu1-objid, sy-vline,
        wa_consu1-stext, sy-vline,
        wa_consu3-otype, '   ', sy-vline,
        wa_consu3-sclas, '   ', sy-vline,
        wa_consu3-sobid, sy-vline.
ENDLOOP.
ENDFORM.
