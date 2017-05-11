TABLES: BKPF, LIPS, VTTK, VFKP, VFKK, EKKO, VFKN, VTTP, LFA1, BSIS, BSEG, FAGL_SEGMT, TVROT, MARM, ESSR, TVTFT, VFSI.

DATA: BEGIN OF PAGO OCCURS 0,
      WERKS TYPE LIPS-WERKS, 
      VTWEG TYPE LIPS-VTWEG, 
      INCO1 TYPE LIKP-INCO1, 
      SHTYP TYPE VTTK-SHTYP, 
      TDLNR TYPE VTTK-TDLNR, 
      NAME1 TYPE LFA1-NAME1,
      ROUTE TYPE VTTK-ROUTE, 
      BEZEI TYPE TVROT-BEZEI, 
      AUGBL TYPE BSEG-AUGBL, 
      AUGDT TYPE BSEG-AUGDT, 
      FKNUM TYPE VFKK-FKNUM, 
      FKART TYPE TVTFT-BEZEI,
      EBELN TYPE EKKO-EBELN,
      DMBTR TYPE BSIS-DMBTR, 
      SEGMENT TYPE FAGL_SEGMT-SEGMENT, 
      LFIMG TYPE LIPS-LFIMG, 
      HKONT TYPE BSIS-HKONT, 
      BELNR TYPE BKPF-BELNR, 
      XBLNR TYPE BKPF-XBLNR, 
      KOSTL TYPE VFKN-KOSTL, 
      NTGEW TYPE LIPS-NTGEW, 
      SGTXT TYPE BSIS-SGTXT. 
DATA: END OF PAGO.

DATA : BEGIN OF t OCCURS 10.
        INCLUDE STRUCTURE bdcdata.
DATA : END OF t.

DATA: BEGIN OF t_msg OCCURS 0.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA: END OF t_msg.

DATA: NETO TYPE LIPS-NTGEW,
      LFIMG TYPE LIPS-LFIMG,
      MENGE TYPE MENGE_D.

*ESTRUCTURAS ALV
TYPE-POOLS: slis.

DATA: it_fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      it_sortcat TYPE slis_t_sortinfo_alv,
      it_Sfieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE, "Catalogo de parámetros
      itS_sortcat TYPE slis_t_sortinfo_alv,
      D_LAYCAT TYPE SLIS_LAYOUT_ALV.
*****************

INITIALIZATION.
*  PERFORM INICIALIZAR.

  SELECTION-SCREEN BEGIN OF BLOCK PRINCIPAL WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS: FECHA FOR SY-DATUM DEFAULT SY-DATUM TO SY-DATUM OBLIGATORY,
                  KOSTL FOR VFKN-KOSTL,
                  TDLNR FOR VTTK-TDLNR,
                  WERKS FOR LIPS-WERKS,
                  VTWEG FOR LIPS-VTWEG,
                  ROUTE FOR VTTK-ROUTE,
                  SEGMENT FOR FAGL_SEGMT-SEGMENT.
  PARAMETERS: SAKTO TYPE BSIS-HKONT DEFAULT '52355002100' OBLIGATORY.

  SELECTION-SCREEN END OF BLOCK PRINCIPAL.

START-OF-SELECTION.
  PERFORM SELECCIONAR_DATOS.
  PERFORM CAMPOS_ALV.
  PERFORM ORDENAR_ALV.
  PERFORM LAYOUT.
  PERFORM MOSTRAR_ALV.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  SELECCIONAR_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECCIONAR_DATOS .
  SELECT BELNR SGTXT DMBTR WERKS KOSTL SEGMENT BUZID SHKZG XOPVW BLART XBLNR HKONT BUZEI
    INTO (PAGO-BELNR, PAGO-SGTXT, PAGO-DMBTR, PAGO-WERKS, PAGO-KOSTL, BSIS-SEGMENT, BSIS-BUZID, BSIS-SHKZG, BSIS-XOPVW, BSIS-BLART, PAGO-XBLNR, PAGO-HKONT, BSIS-BUZEI)
    FROM BSIS
    WHERE BUKRS = '100'
      AND HKONT EQ SAKTO
      AND GJAHR EQ FECHA-LOW(4)
      AND BUDAT IN FECHA
      AND KOSTL IN KOSTL
      AND WERKS IN WERKS
      AND SEGMENT IN SEGMENT.
    PAGO-EBELN = ''.
    PAGO-TDLNR = ''.
    PAGO-FKNUM = ''.
    PAGO-FKART = ''.
    PAGO-ROUTE = ''.
    PAGO-BEZEI = ''.
    PAGO-LFIMG = ''.
    PAGO-INCO1 = ''.
    PAGO-VTWEG = ''.
    IF PAGO-DMBTR NE 0.
      IF BSIS-SHKZG = 'H'.
        PAGO-DMBTR = - PAGO-DMBTR.
      ENDIF.
      "NOMBRE SEGMENTO
      SELECT SINGLE NAME
        INTO PAGO-SEGMENT
        FROM FAGL_SEGMT
        WHERE LANGU = 'S'
        AND SEGMENT = BSIS-SEGMENT.
      "SALIDAS DE MERCANCIA
      IF BSIS-BLART EQ 'WE'.
        SELECT SINGLE EBELN LIFNR
        INTO (PAGO-EBELN, PAGO-TDLNR)
        FROM BSEG
        WHERE BUKRS = '100'
        AND BELNR = PAGO-BELNR
        AND GJAHR EQ FECHA-LOW(4).
        IF PAGO-EBELN(2) = '34'. 
          SELECT SINGLE NAME1
               INTO PAGO-NAME1
               FROM LFA1
               WHERE LIFNR EQ PAGO-TDLNR.

          APPEND PAGO.
        ELSE. "SELECCIONAR LOS TRANSPORTES
          SELECT SINGLE SHTYP ROUTE TDLNR
            INTO (VTTK-SHTYP, VTTK-ROUTE, VTTK-TDLNR)
            FROM VTTK
            WHERE TKNUM EQ PAGO-SGTXT
              AND TDLNR IN TDLNR
              AND ROUTE IN ROUTE.
          IF VTTK-SHTYP NE SPACE.
            PAGO-SHTYP = VTTK-SHTYP.
            PAGO-ROUTE = VTTK-ROUTE.
            "NOMBRE RUTA
            PAGO-BEZEI = ''.
            SELECT BEZEI
              INTO PAGO-BEZEI
              FROM TVROT
              WHERE SPRAS = 'S'
                AND ROUTE = VTTK-ROUTE.
            PAGO-TDLNR = VTTK-TDLNR.
            PAGO-NAME1 = ''.
            SELECT SINGLE NAME1
              INTO PAGO-NAME1
              FROM LFA1
              WHERE LIFNR EQ VTTK-TDLNR.
           ENDSELECT.
          ENDIF.
          SELECT VBELN
            INTO VTTP-VBELN
            FROM VTTP
            WHERE TKNUM EQ PAGO-SGTXT.
            NETO = 0.
            LFIMG = 0.
            PAGO-INCO1 = ''.
            SELECT SINGLE INCO1
              INTO PAGO-INCO1
              FROM LIKP
              WHERE VBELN = VTTP-VBELN.
            PAGO-VTWEG = SPACE.

          
            SELECT NETWR POSNR
              INTO (VFSI-NETWR, VFSI-POSNR)
              FROM VFSI
              WHERE VBELN EQ VTTP-VBELN
                AND NETWR EQ PAGO-DMBTR.
            ENDSELECT.
            MENGE = 0.
            NETO = 0.
            LFIMG = 0.
            SELECT NTGEW LFIMG MEINS VRKME MATNR VTWEG POSNR
              INTO (LIPS-NTGEW, LIPS-LFIMG, LIPS-MEINS, LIPS-VRKME, LIPS-MATNR, PAGO-VTWEG, LIPS-POSNR)
              FROM LIPS
              WHERE VBELN = VTTP-VBELN
                AND VTWEG IN VTWEG
                AND POSNR EQ VFSI-POSNR.

              NETO = NETO + LIPS-NTGEW.

              IF LIPS-MATNR(3) EQ '550'.
                MENGE = LIPS-LFIMG.
                CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                  EXPORTING
                    i_matnr              = LIPS-MATNR  " Número de Material
                    i_in_me              = LIPS-VRKME  " Unidad de Medida Origen
                    i_out_me             = 'Q'         " Unidad de Medida Salida
                    i_menge              = MENGE " Cantidad en medida Origen
                  IMPORTING
                    e_menge              = MENGE " Cantidad en medida Salida
                  EXCEPTIONS
                    error_in_application = 1
                    error                = 2
                    OTHERS               = 3.
                IF SY-SUBRC = 0.
                  LFIMG = LFIMG + MENGE.
                ENDIF.
              ENDIF.
            ENDSELECT.
          ENDSELECT.
          PAGO-LFIMG = LFIMG.
          PAGO-NTGEW = NETO.
          PAGO-FKNUM = ''.
          SELECT SINGLE FKNUM
            INTO PAGO-FKNUM
            FROM VFKP
            WHERE BUKRS = '100'
              AND FKPOS EQ '1'
              AND ( POSTX EQ PAGO-XBLNR OR POSTX EQ PAGO-SGTXT ).
          SELECT SINGLE  FKART
            INTO VFKK-FKART
            FROM VFKK
            WHERE FKNUM EQ PAGO-FKNUM
            AND VBTYP EQ 'A'.
          PAGO-FKART = ''.
          SELECT SINGLE BEZEI
            INTO PAGO-FKART
            FROM TVTFT
            WHERE FKART EQ VFKK-FKART
              AND SPRAS EQ 'S'.
          APPEND PAGO.
        ENDIF.

        "FACTURAS
      ELSEIF BSIS-BLART EQ 'RN'.
        PAGO-AUGBL = ''.
        PAGO-AUGDT = ''.
        SELECT SINGLE AUGBL AUGDT LIFNR SHKZG EBELN EBELP
          INTO (PAGO-AUGBL, PAGO-AUGDT, BSEG-LIFNR, BSEG-SHKZG, BSEG-EBELN, BSEG-EBELP)
          FROM BSEG
          WHERE BUKRS = '0100'
            AND BELNR EQ PAGO-BELNR
            AND GJAHR EQ FECHA-LOW(4)  
            AND BUZEI EQ BSIS-BUZEI
            AND LIFNR IN TDLNR.
        PAGO-EBELN = BSEG-EBELN.
        PAGO-NAME1 = SPACE.
        PAGO-TDLNR = SPACE.
        SELECT SINGLE LIFNR
          INTO PAGO-TDLNR
          FROM EKKO
          WHERE EBELN EQ BSEG-EBELN.

        SELECT SINGLE NAME1
          INTO PAGO-NAME1
          FROM LFA1
          WHERE LIFNR EQ PAGO-TDLNR.
        PAGO-XBLNR = ''.
        SELECT SINGLE XBLNR FKNUM TXZ01
          INTO (PAGO-XBLNR,PAGO-FKNUM, ESSR-TXZ01)
          FROM ESSR
          WHERE EBELN EQ BSEG-EBELN.

        SELECT SINGLE VBELN
          INTO VTTP-VBELN
          FROM VTTP
          WHERE TKNUM EQ PAGO-XBLNR.
        PAGO-INCO1 = ''.
        SELECT SINGLE INCO1 ROUTE
          INTO (PAGO-INCO1, PAGO-ROUTE)
          FROM LIKP
          WHERE VBELN = VTTP-VBELN.
        "NOMBRE RUTA
        PAGO-BEZEI = ''.
        SELECT SINGLE BEZEI
          INTO PAGO-BEZEI
          FROM TVROT
          WHERE SPRAS = 'S'
            AND ROUTE = VTTK-ROUTE.
        PAGO-FKNUM = ''.
        SELECT SINGLE FKNUM
          INTO PAGO-FKNUM
          FROM VFKP
          WHERE BUKRS = '0100'
            AND EBELN EQ BSEG-EBELN
            AND EBELP EQ BSEG-EBELP
            AND POSTX EQ PAGO-XBLNR.
        SELECT SINGLE FKART
          INTO VFKK-FKART
          FROM VFKK
          WHERE FKNUM EQ PAGO-FKNUM.
        PAGO-FKART = ''.
        SELECT SINGLE BEZEI
          INTO PAGO-FKART
          FROM TVTFT
          WHERE FKART EQ VFKK-FKART
            AND SPRAS EQ 'S'.
        APPEND PAGO.

      ELSEIF BSIS-BLART EQ 'KG'.
        SELECT SINGLE AUGBL AUGDT LIFNR SHKZG
          INTO (PAGO-AUGBL, PAGO-AUGDT, PAGO-TDLNR, BSEG-SHKZG)
          FROM BSEG
          WHERE BUKRS = '0100'
            AND BELNR EQ PAGO-BELNR
            AND GJAHR EQ FECHA-LOW(4)
            AND LIFNR IN TDLNR.
        SELECT SINGLE NAME1
          INTO PAGO-NAME1
          FROM LFA1
          WHERE LIFNR EQ PAGO-TDLNR.
        APPEND PAGO.
      ELSE.
        APPEND PAGO.
      ENDIF.
    ENDIF.
  ENDSELECT.
  SORT PAGO BY WERKS TDLNR BELNR SEGMENT.
ENDFORM.                    " SELECCIONAR_DATOS
*&---------------------------------------------------------------------*
*&      Form  CAMPOS_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CAMPOS_ALV .
  REFRESH it_fieldcat.
*CAMPOS A MOSTRAR EN EL REPORTE

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'WERKS' .
  it_fieldcat-ref_fieldname = 'WERKS' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-outputlen    = '6'.
  IT_FIELDCAT-SELTEXT_L    = 'CENTRO'.
  IT_FIELDCAT-SELTEXT_M    = 'CENTRO'.
  IT_FIELDCAT-SELTEXT_S    = 'CENTRO'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'VTWEG' .
  it_fieldcat-ref_fieldname = 'VTWEG' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-outputlen    = '5'.
  IT_FIELDCAT-SELTEXT_L    = 'CANAL'.
  IT_FIELDCAT-SELTEXT_M    = 'CANAL'.
  IT_FIELDCAT-SELTEXT_S    = 'CANAL'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'INCO1' .
  it_fieldcat-ref_fieldname = 'INCO1' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-outputlen    = '4'.
  IT_FIELDCAT-SELTEXT_L    = 'INCOTERM'.
  IT_FIELDCAT-SELTEXT_M    = 'INCOTERM'.
  IT_FIELDCAT-SELTEXT_S    = 'INCOTERM'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'TDLNR' .
  it_fieldcat-ref_fieldname = 'TDLNR' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'COD. TRANSPORTADOR'.
  IT_FIELDCAT-SELTEXT_M    = 'COD. TRANSPORTADOR'.
  IT_FIELDCAT-SELTEXT_S    = 'COD. TRANSPORTADOR'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'NAME1' .
  it_fieldcat-ref_fieldname = 'NAME1' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'NOMBRE TRANPORTADOR'.
  IT_FIELDCAT-SELTEXT_M    = 'NOMBRE TRANPORTADOR'.
  IT_FIELDCAT-SELTEXT_S    = 'NOMBRE TRANPORTADOR'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'ROUTE' .
  it_fieldcat-ref_fieldname = 'ROUTE' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'RUTA'.
  IT_FIELDCAT-SELTEXT_M    = 'RUTA'.
  IT_FIELDCAT-SELTEXT_S    = 'RUTA'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'BEZEI' .
  it_fieldcat-ref_fieldname = 'BEZEI' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'DESC.RUTA'.
  IT_FIELDCAT-SELTEXT_M    = 'DESC.RUTA'.
  IT_FIELDCAT-SELTEXT_S    = 'DESC.RUTA'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'AUGDT' .
  it_fieldcat-ref_fieldname = 'AUGDT' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'FECHA COMPENSACIÓN'.
  IT_FIELDCAT-SELTEXT_M    = 'FECHA COMPENSACIÓN'.
  IT_FIELDCAT-SELTEXT_S    = 'FECHA COMPENSACIÓN'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'FKNUM' .
  it_fieldcat-ref_fieldname = 'FKNUM' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'GASTO DE TRANSPORTE'.
  IT_FIELDCAT-SELTEXT_M    = 'GASTO DE TRANSPORTE'.
  IT_FIELDCAT-SELTEXT_S    = 'GASTO DE TRANSPORTE'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'FKART' .
  it_fieldcat-ref_fieldname = 'FKART' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'TIPO GASTO'.
  IT_FIELDCAT-SELTEXT_M    = 'TIPO GASTO'.
  IT_FIELDCAT-SELTEXT_S    = 'TIPO GASTO'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'EBELN' .
  it_fieldcat-ref_fieldname = 'EBELN' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'PEDIDO SERVICIO'.
  IT_FIELDCAT-SELTEXT_M    = 'PEDIDO SERVICIO'.
  IT_FIELDCAT-SELTEXT_S    = 'PEDIDO SERVICIO'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'DMBTR' .
  it_fieldcat-ref_fieldname = 'DMBTR' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-DO_SUM       = 'X'.
  IT_FIELDCAT-JUST      = 'R'.
  IT_FIELDCAT-DATATYPE     = 'CURR'.
  IT_FIELDCAT-DECIMALS_OUT = '0'.
  IT_FIELDCAT-NO_ZERO      = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'VALOR IMPUTADO'.
  IT_FIELDCAT-SELTEXT_M    = 'VALOR IMPUTADO'.
  IT_FIELDCAT-SELTEXT_S    = 'VALOR IMPUTADO'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'SEGMENT' .
  it_fieldcat-ref_fieldname = 'SEGMENT' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'SEGMENTO'.
  IT_FIELDCAT-SELTEXT_M    = 'SEGMENTO'.
  IT_FIELDCAT-SELTEXT_S    = 'SEGMENTO'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'NTGEW' .
  it_fieldcat-ref_fieldname = 'NTGEW' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-DECIMALS_OUT = '0'.
  IT_FIELDCAT-SELTEXT_L    = 'PESO KG'.
  IT_FIELDCAT-SELTEXT_M    = 'PESO KG'.
  IT_FIELDCAT-SELTEXT_S    = 'PESO KG'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'LFIMG' .
  it_fieldcat-ref_fieldname = 'LFIMG' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'CANTIDAD QQ'.
  IT_FIELDCAT-SELTEXT_M    = 'CANTIDAD QQ'.
  IT_FIELDCAT-SELTEXT_S    = 'CANTIDAD QQ'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'HKONT' .
  it_fieldcat-ref_fieldname = 'HKONT' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'CUENTA'.
  IT_FIELDCAT-SELTEXT_M    = 'CUENTA'.
  IT_FIELDCAT-SELTEXT_S    = 'CUENTA'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'BELNR' .
  it_fieldcat-ref_fieldname = 'BELNR' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'DOCUMENTO'.
  IT_FIELDCAT-SELTEXT_M    = 'DOCUMENTO'.
  IT_FIELDCAT-SELTEXT_S    = 'DOCUMENTO'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'XBLNR' .
  it_fieldcat-ref_fieldname = 'XBLNR' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'REFERENCIA'.
  IT_FIELDCAT-SELTEXT_M    = 'REFERENCIA'.
  IT_FIELDCAT-SELTEXT_S    = 'REFERENCIA'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'KOSTL' .
  it_fieldcat-ref_fieldname = 'KOSTL' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'CENTRO DE COSTO'.
  IT_FIELDCAT-SELTEXT_M    = 'CENCO'.
  IT_FIELDCAT-SELTEXT_S    = 'CENCO'.
  APPEND it_fieldcat to it_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'SGTXT' .
  it_fieldcat-ref_fieldname = 'SGTXT' .
  it_fieldcat-ref_tabname = 'PAGO' .
  it_fieldcat-key = 'X'.
  IT_FIELDCAT-SELTEXT_L    = 'TEXTO'.
  IT_FIELDCAT-SELTEXT_M    = 'TEXTO'.
  IT_FIELDCAT-SELTEXT_S    = 'TEXTO'.
  APPEND it_fieldcat to it_fieldcat.

ENDFORM.                    " CAMPOS_ALV
*&---------------------------------------------------------------------*
*&      Form  LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LAYOUT .
  DATA: LS_LAYCAT TYPE SLIS_LAYOUT_ALV.
  CLEAR LS_LAYCAT.
  D_LAYCAT-no_colhead = SPACE.
  D_LAYCAT-no_hotspot = SPACE. " headings not as hotspot
  D_LAYCAT-Zebra = 'X'. " striped pattern
  D_LAYCAT-no_vline = 'X'. "SPACE.
  D_LAYCAT-cell_merge = 'X'. " not suppress field replication
  D_LAYCAT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " LAYOUT
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOSTRAR_ALV .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat             = it_fieldcat[]
*     IT_SORT                 = IT_SORTCAT
      I_CALLBACK_PROGRAM      = 'ZSDR_PAGOS_TRANSPORTADOR'
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
    TABLES
      t_outtab                = PAGO
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.                    " MOSTRAR_ALV

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->SL_UCOMM     text
*      -->SL_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING L_UCOMM TYPE SY-UCOMM
                        L_SELFIELD TYPE SLIS_SELFIELD.

  DATA: DOC TYPE BKPF-BELNR.

  CASE L_UCOMM.
    WHEN 'BACK'. "ATRAS

    WHEN '&IC1'. " Doble click
      CLEAR DOC.
      READ TABLE PAGO INDEX L_SELFIELD-TABINDEX.
      DOC = PAGO-BELNR.
      PERFORM MOSTRAR_DOC USING DOC '0100' FECHA-LOW(4).

  ENDCASE.

ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOSTRAR_DOC USING P_DOC P_BUKRS P_GJAHR.

  CLEAR: t, t_msg.
  REFRESH: t, t_msg.

  PERFORM batch_insdata(ZSDR_PAGOS_TRANSPORTADOR) TABLES t USING :
         'X' 'SAPMF05L' '100',
         ' ' 'BDC_CURSOR' 'RF05L-BELNR',
         ' ' 'RF05L-BELNR' P_DOC,
         ' ' 'RF05L-BUKRS' P_BUKRS,
         ' ' 'RF05L-GJAHR' P_GJAHR,
         ' ' 'BDC_OKCODE' '/00'.

  CALL TRANSACTION 'FB03'
    USING t MODE 'E'
    UPDATE 'S'
    MESSAGES INTO t_msg.

ENDFORM.                    " MOSTRAR_FACTURA

*&---------------------------------------------------------------------*
*&      Form  ORDENAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ORDENAR_ALV .

  SORT PAGO BY WERKS TDLNR BELNR SEGMENT.

  DATA: IT_sort TYPE slis_sortinfo_alv.
  CLEAR IT_SORT.
  IT_sort-spos = 1.
  IT_sort-fieldname = 'WERKS'.
  IT_sort-up = 'X'.
*  IT_sort-subtot = 'X'.
*  IT_SORT-EXPA = 'X'. " Sirve para que salgan los subtotales
  APPEND IT_sort TO IT_sortcat.

ENDFORM.                    " ORDENAR_ALV

*&---------------------------------------------------------------------*
*&      Form  INICIALIZAR
*&---------------------------------------------------------------------*

*       text
*----------------------------------------------------------------------*
*      -->T          text
*      -->VALUE      text
*      -->(DYNBEGIN) text
*      -->VALUE      text
*      -->(NAME)     text
*      -->VALUE      text
*      -->(VAL)      text
*----------------------------------------------------------------------*
FORM batch_insdata TABLES t STRUCTURE bdcdata
USING value(dynbegin) value(name) value(val).

  DATA : typ TYPE c.
  CLEAR t.
  t-dynbegin = dynbegin.
  IF dynbegin = 'X'.
    MOVE : name TO t-program ,
    val TO t-dynpro.
  ELSE.
    MOVE : name TO t-fnam,
    val TO t-fval.
    DESCRIBE FIELD val TYPE typ.
    IF typ <> 'C'.
      CONDENSE t-fval.
    ENDIF.
  ENDIF.
  APPEND t.
ENDFORM.
