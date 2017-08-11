FORM submit .

  DATA: lv_fechi TYPE d,
        lv_fechf TYPE d.

  FIELD-SYMBOLS: <fs_txt_file> LIKE LINE OF gtd_data.

* Para calcular la fecha
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum  "20170809
      days      = 0
      months    = 1
      signum    = '-'
      years     = 0
    IMPORTING
      calc_date = lv_fechi.

  CONCATENATE  lv_fechi(6) '01' INTO lv_fechi.


  CALL FUNCTION 'FKK_LAST_DAY_OF_MONTH'
    EXPORTING
      day_in            = lv_fechi
    IMPORTING
      last_day_of_month = lv_fechf
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
*fin calcular fecha

*  IF sy-subrc EQ 0.
  cl_salv_bs_runtime_info=>set(
  EXPORTING display  = abap_false
    metadata = abap_false
  data     = abap_true ).

* Submit
  SUBMIT zrm06em00
  WITH listu EQ 'ALV'
  with s_bedat BETWEEN lv_fechi AND lv_fechf


  EXPORTING LIST TO MEMORY AND RETURN.
  TRY.
      cl_salv_bs_runtime_info=>get_data_ref(
      IMPORTING r_data = lr_data ).
      ASSIGN lr_data->* TO <fs_t_data>.
    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE `Unable to retrieve ALV data` TYPE 'E'.
  ENDTRY.
  cl_salv_bs_runtime_info=>clear_all( ).

  IF <fs_t_data> IS ASSIGNED.
    LOOP AT <fs_t_data> ASSIGNING <fs_wa_data>.
      MOVE-CORRESPONDING <fs_wa_data> TO gwa_data.
      APPEND gwa_data TO  gtd_data.
    ENDLOOP.
  ENDIF.

  LOOP AT gtd_data ASSIGNING <fs_txt_file>.

    MOVE-CORRESPONDING <fs_txt_file> TO gwa_body.
    APPEND gwa_body TO gtd_body.
    CLEAR gwa_body.

  ENDLOOP.

ENDFORM.                    " SUBMIT


*&---------------------------------------------------------------------*
*&      Form  CONSTRUIR_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM construir_txt .

  CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
    EXPORTING
      i_field_seperator    = '|'
      i_line_header        = 'X'
*     I_FILENAME           =
*     I_APPL_KEEP          = ' '
    TABLES
      i_tab_sap_data       = gtd_body
    CHANGING
      i_tab_converted_data = gtd_txt_format
* EXCEPTIONS
*     CONVERSION_FAILED    = 1
*     OTHERS               = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  gtd_txt_format1[] = gtd_txt_format[].


ENDFORM.                    " CONSTRUIR_TXT
*&---------------------------------------------------------------------*
*&      Form  TXT_DOWNLOAD_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM txt_download_server .

  DATA: lv_fname      TYPE string,
        lv_directorio TYPE string,
        lv_message    TYPE string,
        lv_exep       TYPE abap_bool VALUE abap_false.

  CLEAR: lv_directorio.

  FIELD-SYMBOLS: <fs_txt_format> LIKE LINE OF gtd_txt_format1."gtd_txt_format.

  DATA: v_record(839) TYPE c.

  CONCATENATE gc_tcode '_' sy-datum INTO lv_fname.
  CONCATENATE gc_ruta lv_fname '.TXT' INTO lv_directorio.

  TRY.
      OPEN DATASET lv_directorio FOR OUTPUT IN TEXT MODE ENCODING NON-UNICODE IGNORING CONVERSION ERRORS.
    CATCH cx_sy_file_open.
      lv_message =  'El archivo ya está abierto'.
      lv_exep = abap_true.
    CATCH cx_sy_codepage_converter_init .
      lv_message = 'No se admite la conversión deseada'.
      lv_exep = abap_true.
    CATCH cx_sy_conversion_codepage.
      lv_message = 'Error interno en la conversión.'.
      lv_exep = abap_true.
    CATCH cx_sy_file_authority.
      lv_message = 'No tiene autorización para el acceso al archivo.'.
      lv_exep = abap_true.
    CATCH cx_sy_pipes_not_supported .
      lv_message = 'Se ha superado el número máximo de archivos abiertos.'.
      lv_exep = abap_true.
    CATCH cx_sy_too_many_files.
      lv_message = 'Se ha superado el número máximo de archivos abiertos.'.
      lv_exep = abap_true.
  ENDTRY.

  LOOP AT gtd_txt_format1 ASSIGNING <fs_txt_format>.
    v_record = <fs_txt_format>-field.
    TRANSFER v_record TO lv_directorio." LENGTH 839.
  ENDLOOP.

  CLOSE DATASET lv_directorio.

ENDFORM.                    " TXT_DOWNLOAD_SERVER
