*&---------------------------------------------------------------------*
*& Report  ZCM_CONSULTA_ST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zcm_consulta_st.

TYPES: BEGIN OF st_1000,
        short TYPE zcm_hrp1000-short,
        objid TYPE zcm_hrp1000-objid,
        stext TYPE zcm_hrp1000-stext,
        otype TYPE zcm_hrp1000-otype,
  END OF st_1000.

TYPES: BEGIN OF st_1001,
        sclas TYPE zcm_hrp1001-sclas,
        sobid TYPE zcm_hrp1001-sobid,
  END OF st_1001.

TYPES: BEGIN OF st_salida,
        short TYPE zcm_hrp1000-short,
        objid TYPE zcm_hrp1000-objid,
        stext TYPE zcm_hrp1000-stext,
        otype TYPE zcm_hrp1000-otype,
        sclas TYPE zcm_hrp1001-sclas,
        sobid TYPE zcm_hrp1001-sobid,
  END OF st_salida.

******************************************************
* Declaro mi tabla interna y area de trabajo
******************************************************

DATA: it_1000 TYPE STANDARD TABLE OF st_1000,
      wa_1000 LIKE LINE OF it_1000,

      it_1001 TYPE STANDARD TABLE OF st_1001,
      wa_1001 LIKE LINE OF it_1001,

      it_salida TYPE STANDARD TABLE OF st_salida,
      wa_salida LIKE LINE OF it_salida,

      it_salida_aux TYPE STANDARD TABLE OF st_salida,
      wa_salida_aux LIKE LINE OF it_salida_aux,          "Tabla interna auxiliar para copiar un BU.

      lin_ini TYPE i,
      lin_fin TYPE i,
      lin_resul TYPE i.

******************************************************
* Pantalla de selección
******************************************************

SELECTION-SCREEN BEGIN OF BLOCK consult WITH FRAME TITLE text-001.
PARAMETERS cedula TYPE cmacbpst-student12.
SELECTION-SCREEN END OF BLOCK consult.

******************************************************
* Cargo mis datos en las tablas internas
******************************************************

SELECT  short
        objid
        stext
        otype FROM zcm_hrp1000 INTO TABLE it_1000 WHERE short = cedula
          AND otype = 'ST'.

IF sy-subrc = 0.
  PERFORM llenado.
  PERFORM salida.
  ELSE.
    WRITE '*** Debe ingresar un número de cédula valido de un estudiante ***'.
ENDIF.


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

LOOP AT it_1000 INTO wa_1000.
  ENDLOOP.

SELECT  sclas
        sobid FROM zcm_hrp1001 INTO TABLE it_1001 WHERE objid = wa_1000-objid
          AND otype = 'ST'.

LOOP AT it_1001 INTO wa_1001.
        MOVE-CORRESPONDING wa_1000 TO wa_salida.
        MOVE-CORRESPONDING wa_1001 TO wa_salida.
        APPEND wa_salida TO it_salida.
ENDLOOP.

SORT it_salida BY sobid.

******************** BORRO DUPLICADOS Y LOS CUENTO ********************

DESCRIBE TABLE it_salida LINES lin_ini. "Contar lineas de la tabla interna.

it_salida_aux[] = it_salida[]. "Hago un BU en mi tabla auxiliar de la original antes de borrar registros.

DELETE ADJACENT DUPLICATES FROM it_salida_aux. "Elimino los registros repetidos de la auxiliar.

DESCRIBE TABLE it_salida_aux LINES lin_fin. "Contar lineas de la tabla interna sin duplicados.

lin_resul = lin_ini - lin_fin. "Contar lo registros duplicados eliminados.

ENDFORM.

FORM salida.

WRITE: 'El número de registros originales era:', lin_ini,/
       'El número de registros duplicados eliminados es:', lin_resul,/
       'El número de registros sin duplicados es:', lin_fin.
SKIP.

LOOP AT it_salida_aux INTO wa_salida.
  WRITE:/ 'Cédula:  ',wa_salida-short,sy-vline,
          'Objid:  ',wa_salida-objid,sy-vline,
          'Nombre:  ',wa_salida-stext,sy-vline,
          'Otype:  ',wa_salida-otype,sy-vline,
          'Sclas:  ',wa_salida-sclas,sy-vline,
          'Sobid:  ',wa_salida-sobid,sy-vline.
ENDLOOP.

ENDFORM.
