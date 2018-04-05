  DATA: BEGIN OF i_text OCCURS 0.
          INCLUDE STRUCTURE soli.
  DATA: END OF i_text.

  DATA: wspoolnumber   LIKE  sy-spono ,
        wmailname      LIKE  sood1-objnam,
        wsubject       LIKE  sood1-objdes ,
        wrecepient(40) TYPE  c ,
        wdli           LIKE  soos1-dlinam.

  DATA: object_hd_change LIKE sood1 OCCURS 0 WITH HEADER LINE,
        objpara          LIKE selc  OCCURS 0 WITH HEADER LINE,
        receivers        LIKE soos1 OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF i_receivers OCCURS 0.
          INCLUDE STRUCTURE receivers.
  DATA: END OF i_receivers.



  wsubject     = 'Entrega numero....1234567890.'.
  wrecepient   = 'tu_correo@algo.com'.



  object_hd_change-objla  = sy-langu.
  object_hd_change-objnam = wmailname.
  object_hd_change-objdes = wsubject.
  object_hd_change-objsns = 'F'.
  object_hd_change-vmtyp  = 'T'.
  object_hd_change-skips  = 'X'.
  object_hd_change-acnam  = 'SP01'.
  object_hd_change-objcp  = 'X'.



  REFRESH i_text.
  CLEAR i_text.
  i_text-line = 'Texto del mensaje'.
  APPEND i_text.



  REFRESH i_receivers.
  CLEAR i_receivers.
  i_receivers-rcdat  = sy-datum.
  i_receivers-rctim  = sy-uzeit.
  i_receivers-recextnam = wrecepient.
  i_receivers-recesc = 'U'.
  i_receivers-sndex  = 'X'.     " Express-Mail
  APPEND i_receivers.


  objpara-name = 'SPI'.
  objpara-low  = wspoolnumber.
  APPEND objpara.


  CALL FUNCTION 'SO_OBJECT_SEND'
       EXPORTING
            object_hd_change           = object_hd_change
            object_type                = 'RAW'
            owner                      = sy-uname
       TABLES
            objcont                    = i_text
            receivers                  = i_receivers
       EXCEPTIONS
       active_user_not_exist            = 1
       communication_failure            = 2
       component_not_available          = 3
       folder_not_exist                 = 4
       folder_no_authorization          = 5
       forwarder_not_exist              = 6
       note_not_exist                   = 7
       object_not_exist                 = 8
       object_not_sent                  = 9
       object_no_authorization          = 10
       object_type_not_exist            = 11
       operation_no_authorization       = 12
       owner_not_exist                  = 13
       parameter_error                  = 14
       substitute_not_active            = 15
       substitute_not_defined           = 16
       system_failure                   = 17
       too_much_receivers               = 18
       user_not_exist                   = 19
       originator_not_exist             = 20
       x_error                          = 21
       OTHERS                           = 22.

  IF sy-subrc <> 0.
    WRITE: /'Error al enviar el mail'.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  COMMIT WORK.
