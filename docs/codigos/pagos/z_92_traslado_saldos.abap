FUNCTION z_92_traslado_saldos.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IV_CLIENTE) TYPE  BDC_FVAL
*"     VALUE(IV_SUBTOTAL) TYPE  BDC_FVAL
*"     VALUE(IV_IVA) TYPE  BDC_FVAL
*"     VALUE(IV_TXTSUBTOTAL) TYPE  BDC_FVAL OPTIONAL
*"     VALUE(IV_TXTIVA) TYPE  BDC_FVAL OPTIONAL
*"     VALUE(IV_CLAVECTA) TYPE  BDC_FVAL
*"     VALUE(IT_FOLIOS) TYPE  ZTT_92_FOLIOSCOMPENSA
*"     VALUE(IV_FECHA) TYPE  BDC_FVAL
*"  EXPORTING
*"     VALUE(EV_DOCUMENTO) TYPE  BELNR_D
*"     VALUE(ET_RESULTADO) TYPE  ZTT_92_RESULTADO_ENTRADA
*"----------------------------------------------------------------------

*Ramon Morales
*20160304

  DATA lv_correcto TYPE i.
  DATA lv_gaulv TYPE auglv.



  CALL FUNCTION 'POSTING_INTERFACE_START'
    EXPORTING
      i_function         = 'C'        "CALL TRANSACTION
      i_mode             = 'N'        "Modo N
      i_update           = 'S'        "Update S
    EXCEPTIONS
      client_incorrect   = 1
      function_invalid   = 2
      group_name_missing = 3
      mode_invalid       = 4
      update_invalid     = 5
      OTHERS             = 6.

  IF sy-subrc = 0.
    lv_correcto = 1.
  ENDIF.

  DATA: wa_syst TYPE syst.
  DATA: wa_return TYPE bapiret2.
  DATA: return TYPE STANDARD TABLE OF bapiret2.


  DATA:   ls_blntab TYPE  blntab
        , ls_ftclear TYPE  ftclear
        , ls_ftpost TYPE  ftpost
        , ls_fttax TYPE  fttax.

  DATA:   lt_blntab TYPE STANDARD TABLE OF blntab
        , lt_ftclear TYPE STANDARD TABLE OF ftclear
        , lt_ftpost TYPE STANDARD TABLE OF ftpost
        , lt_fttax TYPE STANDARD TABLE OF fttax.

  DATA p_subrc TYPE sy-subrc.


  FIELD-SYMBOLS: <ls_blntab> TYPE blntab.
  FIELD-SYMBOLS: <ls_folios> TYPE zstr_92_folioscompensa.

******************ENCABEZADO***************************
* Creamos el documento de compensación de la
* partida
* Batch Input Values
  ls_ftpost-stype = 'K'."Header
  ls_ftpost-count = 1. "number of Dynpro

* Fecha de documento
  "write p_datos-fecha_contabilizacion to txt_fecha.
  ls_ftpost-fnam = 'BKPF-BLDAT'.
  ls_ftpost-fval = iv_fecha.
  APPEND ls_ftpost TO lt_ftpost.
* Fecha de contabilizacion
  ls_ftpost-fnam = 'BKPF-BUDAT'.
  ls_ftpost-fval = iv_fecha.
  APPEND ls_ftpost TO lt_ftpost.

* Clase de documento
  ls_ftpost-fnam = 'BKPF-BLART'.
  ls_ftpost-fval = 'SA'.
  APPEND ls_ftpost TO lt_ftpost.

* Sociedad
  ls_ftpost-fnam = 'BKPF-BUKRS'.
  ls_ftpost-fval = '2000'."p_bsid-bukrs.
  APPEND ls_ftpost TO lt_ftpost.
* Moneda
  ls_ftpost-fnam = 'BKPF-WAERS'.
  ls_ftpost-fval = 'MXN'."p_waers.
  APPEND ls_ftpost TO lt_ftpost.
* Texto encabezado
  ls_ftpost-fnam = 'RF05A-AUGTX'.
  ls_ftpost-fval = iv_txtsubtotal.
  APPEND ls_ftpost TO lt_ftpost.

** Referencia
*  ls_ftpost-fnam = 'BKPF-XBLNR'.
*  ls_ftpost-fval = iv_cliente.
*  APPEND ls_ftpost TO lt_ftpost.

*************************PARTIDAS****************************

* Primera línea, Siguiente DYNRPO
  ls_ftpost-stype = 'P'."Posicion
  ls_ftpost-count = 1.  "number of ITEM
* Ind movimiento
  ls_ftpost-fnam = 'RF05A-NEWBS'.
  ls_ftpost-fval = iv_clavecta.
  APPEND ls_ftpost TO lt_ftpost.
* Cuenta
  ls_ftpost-fnam = 'RF05A-NEWKO'.
  ls_ftpost-fval = '710010'.
  APPEND ls_ftpost TO lt_ftpost.
** Centro de coste
*  ls_ftpost-fnam = 'BSEG-KOSTL'.
*  ls_ftpost-fval = '2001031012'.
*  APPEND ls_ftpost TO lt_ftpost.
* Centro de coste
  ls_ftpost-fnam = 'COBL-KOSTL'.
  ls_ftpost-fval = '2001031012'.
  APPEND ls_ftpost TO lt_ftpost.
* Importe
  ls_ftpost-fnam = 'BSEG-WRBTR'.
  ls_ftpost-fval = iv_subtotal.
  APPEND ls_ftpost TO lt_ftpost.
* Texto de posición
  ls_ftpost-fnam = 'BSEG-SGTXT'.
  ls_ftpost-fval = iv_txtsubtotal.
  APPEND ls_ftpost TO lt_ftpost.
* Texto de asignacion
  ls_ftpost-fnam = 'BSEG-ZUONR'.
  ls_ftpost-fval = iv_cliente.
  APPEND ls_ftpost TO lt_ftpost.



  IF iv_iva GT 0.
* Segunda línea, Siguiente DYNRPO
    ls_ftpost-stype = 'P'."Posicion
    ls_ftpost-count = 2.  "number of ITEM
* Ind movimiento
    ls_ftpost-fnam = 'RF05A-NEWBS'.
    ls_ftpost-fval = iv_clavecta.
    APPEND ls_ftpost TO lt_ftpost.
* Cuenta
    ls_ftpost-fnam = 'RF05A-NEWKO'.
    ls_ftpost-fval = '710010'.
    APPEND ls_ftpost TO lt_ftpost.
** Centro de coste
*    ls_ftpost-fnam = 'BSEG-KOSTL'.
*    ls_ftpost-fval = '2001031012'.
*    APPEND ls_ftpost TO lt_ftpost.
* Centro de coste
    ls_ftpost-fnam = 'COBL-KOSTL'.
    ls_ftpost-fval = '2001031012'.
    APPEND ls_ftpost TO lt_ftpost.
* Importe
    ls_ftpost-fnam = 'BSEG-WRBTR'.
    ls_ftpost-fval = iv_iva.
    APPEND ls_ftpost TO lt_ftpost.
* Texto de posición
    ls_ftpost-fnam = 'BSEG-SGTXT'.
    ls_ftpost-fval = iv_txtiva.
    APPEND ls_ftpost TO lt_ftpost.
* Texto de asignacion
    ls_ftpost-fnam = 'BSEG-ZUONR'.
    ls_ftpost-fval = iv_cliente.
    APPEND ls_ftpost TO lt_ftpost.


  ENDIF.

* Se reemplaza esta parte del codigo para compensar varios documentos en un mismo evento
** Documents to be cleared
*  ls_ftclear-agkoa = 'D'.             "Account Type K = vendor D = Customer S = GL Account
*  ls_ftclear-agkon = iv_cliente.      "p_bsid-kunnr. "Example Customer
*  ls_ftclear-agbuk = '2000'.          "p_bsid-bukrs. "Example company code
*  ls_ftclear-xnops = 'X'.             "Indicator: Select only open items which are not special G/L?
*  "ls_ftclear-xfifo = 'X'.
*  ls_ftclear-selfd = 'BELNR'.         "Selection Field
*  ls_ftclear-selvon = iv_folio.
*  ls_ftclear-selbis = iv_folio.
*  APPEND ls_ftclear TO lt_ftclear.


  LOOP AT it_folios ASSIGNING <ls_folios>.

* Documents to be cleared
  ls_ftclear-agkoa = 'D'.             "Account Type K = vendor D = Customer S = GL Account
  ls_ftclear-agkon = iv_cliente.      "p_bsid-kunnr. "Example Customer
  ls_ftclear-agbuk = '2000'.          "p_bsid-bukrs. "Example company code
  ls_ftclear-xnops = 'X'.             "Indicator: Select only open items which are not special G/L?
  "ls_ftclear-xfifo = 'X'.
  ls_ftclear-selfd = 'BELNR'.         "Selection Field
  ls_ftclear-selvon = <ls_folios>-iv_folio.
  ls_ftclear-selbis = <ls_folios>-iv_folio.
  APPEND ls_ftclear TO lt_ftclear.


  ENDLOOP.


  lv_gaulv = 'UMBUCHNG'.

  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
      i_auglv                    = lv_gaulv
      i_tcode                    = 'FB05'
      i_sgfunct                  = 'C'
*     I_NO_AUTH                  = ' '
    IMPORTING
      e_msgid                    = wa_syst-msgid
      e_msgno                    = wa_syst-msgno
      e_msgty                    = wa_syst-msgty
      e_msgv1                    = wa_syst-msgv1
      e_msgv2                    = wa_syst-msgv2
      e_msgv3                    = wa_syst-msgv3
      e_msgv4                    = wa_syst-msgv4
      e_subrc                    = p_subrc
    TABLES
      t_blntab                   = lt_blntab
      t_ftclear                  = lt_ftclear
      t_ftpost                   = lt_ftpost
      t_fttax                    = lt_fttax
    EXCEPTIONS
      clearing_procedure_invalid = 1
      clearing_procedure_missing = 2
      table_t041a_empty          = 3
      transaction_code_invalid   = 4
      amount_format_error        = 5
      too_many_line_items        = 6
      company_code_invalid       = 7
      screen_not_found           = 8
      no_authorization           = 9
      OTHERS                     = 10.

  IF  sy-subrc <> 0
     OR wa_syst-msgty CA 'EAX'
     OR p_subrc <> 0.
    IF wa_syst-msgty CA 'EAX'.
      CALL FUNCTION 'MAP2I_SYST_TO_BAPIRET2'
        EXPORTING
          syst     = wa_syst
        CHANGING
          bapiret2 = wa_return.
      wa_return-type = 'E'. "Error siempre
    ELSE.
      CALL FUNCTION 'MAP2I_SYST_TO_BAPIRET2'
        EXPORTING
          syst     = syst
        CHANGING
          bapiret2 = wa_return.
      wa_return-type = 'E'. "Error siempre
    ENDIF.
    IF NOT wa_return IS INITIAL.
      APPEND wa_return TO et_resultado.
    ENDIF.
  ENDIF.


  LOOP AT lt_blntab ASSIGNING <ls_blntab>.
    ev_documento = <ls_blntab>-belnr.
  ENDLOOP.

  CALL FUNCTION 'POSTING_INTERFACE_END'
    EXPORTING
      i_bdcimmed              = ' '
*     I_BDCSTRTDT             = NO_DATE
*     I_BDCSTRTTM             = NO_TIME
    EXCEPTIONS
      session_not_processable = 1
      OTHERS                  = 2.


  IF sy-subrc = 0.
    lv_correcto = 1.
  ENDIF.

ENDFUNCTION.
