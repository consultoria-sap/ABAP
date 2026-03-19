* La operación depende de si tenemos
   * factura o abono
    case lv_tipo_doc.
      when gc_tipo_doc_f.
        lv_auglv = gc_eingzahl.
      when gc_tipo_doc_a.
        lv_auglv = gc_ausgzahl.
    endcase.

Donde
constants: gc_eingzahl type t041a-auglv value 'EINGZAHL',
           gc_ausgzahl type t041a-auglv value 'AUSGZAHL',
           gc_umbuchng type t041a-auglv value 'UMBUCHNG'.
*&---------------------------------------------------------------------*
*&      Form  COMPENSAR_PARTIDA
*&---------------------------------------------------------------------*
*       Compensación de partidas de cliente
*----------------------------------------------------------------------*
form compensar_partida  using    p_bsid type bsid
                                 p_datos type zws_crm
                                 p_importe
                                p_auglv
                                 p_waers
                        changing p_subrc type sy-subrc
                                 return type bapiret2_t
                                 t_blntab type re_t_ex_blntab.

  data: lt_ftclear type standard table of ftclear
                   with header line,
        lt_ftpost type standard table of ftpost
                  with header line,
        lt_fttax type standard table of fttax
                  with header line.

  data: txt_fecha(10) type c.
  data: txt_importe(15) type c.
  data: lv_sgtxt type bseg-sgtxt.

* Iniciar interfaz de contabilización
  perform iniciar_interfaz changing p_subrc
                                    return.
  if p_subrc <> 0.
    return.
  endif.

* Creamos el documento de compensación de la
* partida
* Batch Input Values
  lt_ftpost-stype = 'K'."Header
  lt_ftpost-count = 1. "number of Dynpro

* Fecha de documento
  write p_datos-fecha_contabilizacion to txt_fecha.
  lt_ftpost-fnam = 'BKPF-BLDAT'.
  lt_ftpost-fval = txt_fecha.
  append lt_ftpost.
* Fecha de contabilizacion
  lt_ftpost-fnam = 'BKPF-BUDAT'.
  lt_ftpost-fval = txt_fecha.
  append lt_ftpost.
* Clase de documento
  lt_ftpost-fnam = 'BKPF-BLART'.
  case p_auglv.
    when gc_ausgzahl.
      lt_ftpost-fval = zfi_param_crm-blart_pa.
    when gc_eingzahl.
      lt_ftpost-fval = zfi_param_crm-blart_co.
  endcase.
  append lt_ftpost.
* Sociedad
  lt_ftpost-fnam = 'BKPF-BUKRS'.
  lt_ftpost-fval = p_bsid-bukrs.
  append lt_ftpost.
* Moneda
  lt_ftpost-fnam = 'BKPF-WAERS'.
  lt_ftpost-fval = p_waers.
  append lt_ftpost.
* Referencia
  lt_ftpost-fnam = 'BKPF-XBLNR'.
  lt_ftpost-fval = p_bsid-xblnr.
  append lt_ftpost.
* Primera línea, Siguiente DYNRPO
  lt_ftpost-stype = 'P'."Posicion
  lt_ftpost-count = 2.  "number of ITEM
* Ind movimiento
  lt_ftpost-fnam = 'RF05A-NEWBS'.
* Tenemos que asignar el proceso
  case p_auglv.
    when gc_ausgzahl.
      lt_ftpost-fval = '50'.
    when gc_eingzahl.
      lt_ftpost-fval = '40'.
  endcase.
  append lt_ftpost.
* Cuenta
  lt_ftpost-fnam = 'RF05A-NEWKO'.
  lt_ftpost-fval = p_datos-cuenta_banco.
  append lt_ftpost.
* Importe
  write p_importe to txt_importe
                currency p_waers.
  lt_ftpost-fnam = 'BSEG-WRBTR'.
  lt_ftpost-fval = txt_importe.
  append lt_ftpost.

* Texto de posición
  write p_importe to txt_importe
                currency p_waers.
  lt_ftpost-fnam = 'BSEG-SGTXT'.
  perform forma_texto_posicion_cobro using p_bsid-kunnr
                                           p_bsid-xblnr
                                  changing lv_sgtxt.
  lt_ftpost-fval = lv_sgtxt.
  append lt_ftpost.


* Documents to be cleared
  lt_ftclear-agkoa = 'D'. "Account Type
  lt_ftclear-xnops = 'X'.  "Indicator: Select only open items which are not special G/L?
  lt_ftclear-xfifo = 'X'.
  lt_ftclear-agbuk = p_bsid-bukrs. "Example company code
  lt_ftclear-agkon = p_bsid-kunnr. "Example Customer
  lt_ftclear-selfd = 'BELNR'."Selection Field
  lt_ftclear-selvon = p_bsid-belnr. "Documento seleccionado
  lt_ftclear-selbis = p_bsid-belnr. "Documento seleccionado
  append lt_ftclear.

  perform procesar_interfaz using p_auglv
                                  t_blntab[]
                                  lt_ftclear[]
                                  lt_ftpost[]
                                  lt_fttax[]
                         changing p_subrc
                                  return.

* Cerrar interfaz
  perform cerrar_interfaz changing p_subrc
                                   return.

endform.                    " COMPENSAR_PARTIDA
*&---------------------------------------------------------------------*
*&      Form  INICIAR_INTERFAZ
*&---------------------------------------------------------------------*
*       Iniciamos la interfaz de contabilización
*----------------------------------------------------------------------*
form iniciar_interfaz  changing p_subrc type sy-subrc
                                return type bapiret2_t.

  data: wa_return type bapiret2.

  call function 'POSTING_INTERFACE_START'
    exporting
      i_function               = 'C'        "CALL TRANSACTION
      i_mode                   = gv_modoct  "Modo N
      i_update                 = 'S'        "Update S
    exceptions
      client_incorrect         = 1
      function_invalid         = 2
      group_name_missing       = 3
      mode_invalid             = 4
      update_invalid           = 5
      others                   = 6
            .
  if sy-subrc <> 0.
    p_subrc = sy-subrc.
    call function 'MAP2I_SYST_TO_BAPIRET2'
      exporting
        syst           = syst
      changing
        bapiret2       = wa_return.
    if not wa_return is initial.
      append wa_return to return.
    endif.
  endif.

endform.                    " INICIAR_INTERFAZ
*&---------------------------------------------------------------------*
*&      Form  PROCESAR_INTERFAZ
*&---------------------------------------------------------------------*
*       Llamamos a la interfaz de proceso de documentos
*----------------------------------------------------------------------*
form procesar_interfaz  using    p_auglv
                                 t_blntab type standard table
                                 t_ftclear type standard table
                                 t_ftpost type standard table
                                 t_fttax type standard table
                        changing p_subrc
                                 return type bapiret2_t.

  data: l_tcode type sy-tcode value 'FB05', "You get an error with any other value
      l_sgfunct type rfipi-sgfunct value 'C'. "Post immediately
  data: wa_syst type syst.
  data: wa_return type bapiret2.

* Podemos llamar a contabilizar y compensar (si pasamos
* el valor para P_AUGLV) es decir, FB05, o llamamos a
* contabilizar a secas (FB01) si P_AUGLV es inicial
  if p_auglv is not initial.
    l_tcode = 'FB05'.
    call function 'POSTING_INTERFACE_CLEARING'
      exporting
        i_auglv                          = p_auglv
        i_tcode                          = l_tcode
        i_sgfunct                        = l_sgfunct
*       I_NO_AUTH                        = ' '
      importing
        e_msgid                          = wa_syst-msgid
        e_msgno                          = wa_syst-msgno
        e_msgty                          = wa_syst-msgty
        e_msgv1                          = wa_syst-msgv1
        e_msgv2                          = wa_syst-msgv2
        e_msgv3                          = wa_syst-msgv3
        e_msgv4                          = wa_syst-msgv4
        e_subrc                          = p_subrc
      tables
        t_blntab                         = t_blntab[]
        t_ftclear                        = t_ftclear[]
        t_ftpost                         = t_ftpost[]
        t_fttax                          = t_fttax[]
      exceptions
        clearing_procedure_invalid       = 1
        clearing_procedure_missing       = 2
        table_t041a_empty                = 3
        transaction_code_invalid         = 4
        amount_format_error              = 5
        too_many_line_items              = 6
        company_code_invalid             = 7
        screen_not_found                 = 8
        no_authorization                 = 9
        others                           = 10.
  else.
    l_tcode = 'FB01'.
    call function 'POSTING_INTERFACE_DOCUMENT'
      exporting
        i_tcode                        = l_tcode
        i_sgfunct                      = l_sgfunct
*       I_NO_AUTH                      = ' '
      importing
        e_msgid                          = wa_syst-msgid
        e_msgno                          = wa_syst-msgno
        e_msgty                          = wa_syst-msgty
        e_msgv1                          = wa_syst-msgv1
        e_msgv2                          = wa_syst-msgv2
        e_msgv3                          = wa_syst-msgv3
        e_msgv4                          = wa_syst-msgv4
        e_subrc                          = p_subrc
      tables
        t_blntab                       = t_blntab[]
        t_ftpost                       = t_ftpost[]
        t_fttax                        = t_fttax[]
      exceptions
        account_missing                = 1
        company_code_missing           = 2
        posting_key_invalid            = 3
        posting_key_missing            = 4
        record_type_invalid            = 5
        transaction_code_invalid       = 6
        amount_format_error            = 7
        too_many_line_items            = 8
        company_code_invalid           = 9
        screen_not_found               = 10
        no_authorization               = 11
        others                         = 12.
  endif.
  if    sy-subrc <> 0
     or wa_syst-msgty ca 'EAX'
     or p_subrc <> 0.
    if wa_syst-msgty ca 'EAX'.
      call function 'MAP2I_SYST_TO_BAPIRET2'
        exporting
          syst           = wa_syst
        changing
          bapiret2       = wa_return.
       wa_return-type = 'E'. "Error siempre
    else.
      call function 'MAP2I_SYST_TO_BAPIRET2'
        exporting
          syst           = syst
        changing
          bapiret2       = wa_return.
      wa_return-type = 'E'. "Error siempre
    endif.
    if not wa_return is initial.
      append wa_return to return.
    endif.
  endif.

endform.                    " PROCESAR_INTERFAZ
*&---------------------------------------------------------------------*
*&      Form  CERRAR_INTERFAZ
*&---------------------------------------------------------------------*
*       Cerramos la interfaz de proceso de contabilizaciones
*----------------------------------------------------------------------*
form cerrar_interfaz  changing p_subrc type sy-subrc
                               return type bapiret2_t.

  data: wa_return type bapiret2.

  call function 'POSTING_INTERFACE_END'
    exporting
      i_bdcimmed                    = ' '
*     I_BDCSTRTDT                   = NO_DATE
*     I_BDCSTRTTM                   = NO_TIME
    exceptions
      session_not_processable       = 1
      others                        = 2
            .
  if sy-subrc <> 0.
    call function 'MAP2I_SYST_TO_BAPIRET2'
      exporting
        syst           = syst
      changing
        bapiret2       = wa_return.
    if not wa_return is initial.
      append wa_return to return.
    endif.
  endif.

endform.                    " CERRAR_INTERFAZ
