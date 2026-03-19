REPORT  ztest04.

TYPES:
  BEGIN OF st_texto,
    linea(150) TYPE c,
  END OF st_texto.
DATA: it_texto TYPE STANDARD TABLE OF st_texto,
      wa_texto TYPE st_texto.

DATA: gv_line          TYPE i VALUE 150, "Longitud de Linea
      gv_obj_container TYPE REF TO cl_gui_custom_container,
      gv_obj_textedit  TYPE REF TO cl_gui_textedit,
      gv_texto         TYPE string.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
 SELECTION-SCREEN COMMENT /3(36) text-001 . "Pulsa para ver en acción a TEXT EDIT
 SELECTION-SCREEN PUSHBUTTON 40(3) pa_boton USER-COMMAND b1. "Boton
SELECTION-SCREEN: END OF BLOCK b1.

AT SELECTION-SCREEN.
  IF sy-ucomm = 'B1' .
    PERFORM muestra_dynpro.
  ENDIF.

START-OF-SELECTION.

END-OF-SELECTION.

FORM muestra_dynpro.
  CALL SCREEN 100 STARTING AT 10 5.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  PERFORM crear_textedit.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'ACEPTA'.
      PERFORM get_text.
    WHEN 'PROPUE'.
      PERFORM set_text.
    WHEN 'EDIT'.
      PERFORM insertar_texto.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  CREAR_TEXTEDIT
*&---------------------------------------------------------------------*
FORM crear_textedit .
  IF gv_obj_textedit IS INITIAL.
    CREATE OBJECT gv_obj_container
      EXPORTING
        container_name              = 'TEXTEDIT'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT gv_obj_textedit
      EXPORTING
        parent                     = gv_obj_container
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_position          = gv_line
        wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

    CALL METHOD gv_obj_textedit->set_readonly_mode
      EXPORTING
        readonly_mode          = 1 "1 = TRUE, 0 = FALSE
      EXCEPTIONS
        error_cntl_call_method = 1
        invalid_parameter      = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD gv_obj_textedit->set_toolbar_mode
      EXPORTING
        toolbar_mode = cl_gui_textedit=>false.

    CALL METHOD gv_obj_textedit->set_statusbar_mode
      EXPORTING
        statusbar_mode = cl_gui_textedit=>false.
  ENDIF.
ENDFORM.                    " CREAR_TEXTEDIT
*&---------------------------------------------------------------------*
*&      Form  GET_TEXT
*&---------------------------------------------------------------------*

FORM get_text .
  CALL METHOD gv_obj_textedit->get_text_as_r3table
    IMPORTING
      table = it_texto.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.
  IF it_texto IS NOT INITIAL.
    LOOP AT it_texto INTO wa_texto.
      MESSAGE wa_texto-linea TYPE 'I'.
    ENDLOOP.
  ELSE.
    MESSAGE 'Sin Datos' TYPE 'I'.
  ENDIF.
ENDFORM.                    " GET_TEXT
*&---------------------------------------------------------------------*
*&      Form  SET_TEXT
*&---------------------------------------------------------------------*
FORM set_text .
  REFRESH it_texto.
  DO 5 TIMES.
    wa_texto-linea = sy-index.
    CONDENSE wa_texto-linea.
    CONCATENATE 'Linea Núm: ' wa_texto-linea
           INTO wa_texto-linea SEPARATED BY space.
    APPEND wa_texto TO it_texto.
  ENDDO.

  CALL METHOD gv_obj_textedit->set_text_as_r3table
    EXPORTING
      table = it_texto.

  CALL METHOD gv_obj_textedit->set_readonly_mode
    EXPORTING
      readonly_mode          = 1 "1 = TRUE, 0 = FALSE
    EXCEPTIONS
      error_cntl_call_method = 1
      invalid_parameter      = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SET_TEXT
*&---------------------------------------------------------------------*
*&      Form  INSERTAR_TEXTO
*&---------------------------------------------------------------------*
FORM insertar_texto .
  CALL METHOD gv_obj_textedit->delete_text
    EXCEPTIONS
      error_cntl_call_method = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD gv_obj_textedit->set_readonly_mode
    EXPORTING
      readonly_mode          = 0 "1 = TRUE, 0 = FALSE
    EXCEPTIONS
      error_cntl_call_method = 1
      invalid_parameter      = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " INSERTAR_TEXTO
