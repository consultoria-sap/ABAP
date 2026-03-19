report  zmm_criticidad no standard page heading.

include zmm_criticidad_top.
include zmm_criticidad_form.

*&---------------------------------------------------------------------*
*& Validaciones de Pantalla
*&---------------------------------------------------------------------*
at selection-screen on value-request for archivo.
  perform set_filepath changing archivo.

*&---------------------------------------------------------------------*
*& INITIALIZATION
*&---------------------------------------------------------------------*
initialization.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
start-of-selection.

  perform upload_excel_it using archivo changing ti_data.

 if ti_data[] is initial.
    message text-e02 type 'I' display like 'E'.
  else.
    perform cargar_alv.
  endif.



  end-of-selection.
*&---------------------------------------------------------------------*
*& END-OF-SELECTION
*&---------------------------------------------------------------------*
