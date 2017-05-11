*&---------------------------------------------------------------------*
*&  Include           ZFTP001_MIMP
*&---------------------------------------------------------------------*
CLASS actions IMPLEMENTATION.
  METHOD encrypt.
    data: result TYPE c LENGTH 50.

    CALL 'AB_RFC_X_SCRAMBLE_STRING'
    ID 'SOURCE'      FIELD contrasena
    ID 'KEY'         FIELD llave
    ID 'SCR'         FIELD 'X'
    ID 'DESTINATION' FIELD password
    ID 'DSTLEN'      FIELD dstlen.

    CONCATENATE 'Resultado de Encriptar: ' password
    INTO result SEPARATED BY space.

    PERFORM draw USING result.

  ENDMETHOD.                    "encrypt

  METHOD connect.
    CALL FUNCTION 'FTP_CONNECT'
      EXPORTING
        user            = usuario
        password        = contrasena
        host            = ipdestino
        rfc_destination = destsap
      IMPORTING
        handle          = hdl
      EXCEPTIONS
        not_connected   = 1
        OTHERS          = 2.

    encargado = hdl.

    IF sy-subrc = 0.
      PERFORM draw USING 'Conexion Correcta'.
    ELSE.
      PERFORM draw USING 'Conexion Erronea'.
    ENDIF.
  ENDMETHOD.                    "connect

  METHOD send_comm.
    CALL FUNCTION 'FTP_COMMAND_LIST'
      EXPORTING
        handle        = encargado
      TABLES
        commands      = comandos
        data          = receive
      EXCEPTIONS
        command_error = 1
        tcpip_error   = 2
        data_error    = 3.

    IF sy-subrc = 0.
      PERFORM draw USING 'Comandos Enviados Correctamente'.
    ELSE.
      PERFORM draw USING 'Comandos No Enviados'.
    ENDIF.
  ENDMETHOD.                    "send_comm

  METHOD close.
    CALL FUNCTION 'FTP_DISCONNECT'
      EXPORTING
        handle = hdl.
    subrc = sy-subrc.

    IF sy-subrc = 0.
      PERFORM draw USING 'Sesion Cerrada Correctamente'.
    ELSE.
      PERFORM draw USING 'Sesion No Cerrada'.
    ENDIF.
  ENDMETHOD.                    "close


  METHOD append.
    CLEAR wa_commands-line.
    wa_commands-line = line.
    APPEND wa_commands TO commands.
  ENDMETHOD.                    "APPEND

ENDCLASS.                    "actions IMPLEMENTATION


*&---------------------------------------------------------------------*
*&      Form  DRAW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MESSAGE  text
*----------------------------------------------------------------------*
FORM draw  USING    p_message.
  WRITE:/ p_message.
ENDFORM.                    " DRAW
