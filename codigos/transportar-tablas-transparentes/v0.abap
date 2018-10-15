Este Reporte sirve para transportar tablas transparentes, es util a la hora de querer migrar datos de tablas "Z" o SAP desde
un mandante a otro...Este ejemplo genera una Orden de Transporte por Tabla.

*----------------------------------------------------------------------*
* REPORT   : Y_TRANSPORTE_TABLAS
* OBJETIVO : CREAR ORDENES DE TRANSPORTE DADO UNA TABLA DEL TIPO
*            TRANSPARENTE SELECCIONADA POR PANTALLA.
*----------------------------------------------------------------------*
*
REPORT Y_TRANSPORTE_TABLAS.
*
*----------------------------------------------------------------------*
* DECLARACION DE TABLAS
*----------------------------------------------------------------------*
TABLES : dd02l.
*----------------------------------------------------------------------*
* SELECCION DE PARAMETRO NOMBRE_TABLA POR PANTALLA
*----------------------------------------------------------------------*
PARAMETERS : table LIKE dd02l-tabname OBLIGATORY.
*----------------------------------------------------------------------*
* DECLARACION DE VARIABLES
*----------------------------------------------------------------------*
DATA : w_tabclass     LIKE dd02l-tabclass,
       w_desc_orden   LIKE e07t-as4text,
       w_nume_orden   LIKE e070-trkorr,
       wa_e070        LIKE e070,
       wa_e07t        LIKE e07t,
       wa_e070c       LIKE e070c,
       tbi_e071       LIKE e071  OCCURS 1 WITH HEADER LINE,
       tbi_e071k      LIKE e071k OCCURS 1 WITH HEADER LINE.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
*
* ---------------------------------------------------------------------*
*  Validar que la Tabla exista y que sea del tipo Transparente
* ---------------------------------------------------------------------*
*
  CLEAR : w_tabclass.
  SELECT SINGLE tabclass INTO w_tabclass FROM  dd02l
         WHERE  tabname   EQ table
         AND    as4local  EQ 'A'.
  IF ( sy-subrc NE 0 ).
    MESSAGE w208(00) WITH 'Tabla No Existe..'(e01).
    LEAVE PROGRAM.
  ELSEIF ( w_tabclass NE 'TRANSP' ).
    MESSAGE w208(00) WITH 'No es Tabla Transparente'(e05).
    LEAVE PROGRAM.
  ENDIF.
*
* ---------------------------------------------------------------------*
*  Agregar Datos de la Orden de Transporte a Tablas Internas
* ---------------------------------------------------------------------*
*
  CONCATENATE 'TRANSPORTE DE TABLA : ('
              table ') DESDE MANDANTE :' sy-mandt
         INTO w_desc_orden SEPARATED BY space.
*
  tbi_e071-pgmid        = 'R3TR'.
  tbi_e071-object       = 'TABU'.
  tbi_e071-obj_name     = table.
  tbi_e071-objfunc      = 'K'.
  APPEND tbi_e071.
*
  tbi_e071k-pgmid       = 'R3TR'.
  tbi_e071k-object      = 'TABU'.
  tbi_e071k-objname     = table.
  tbi_e071k-mastertype  = 'TABU'.
  tbi_e071k-mastername  = table.
*
  IF ( dd02l-clidep EQ 'X' ).
    CONCATENATE sy-mandt '*' INTO tbi_e071k-tabkey.
  ELSE.
    tbi_e071k-tabkey = '*'.
  ENDIF.
*
  APPEND tbi_e071k.
*
* ---------------------------------------------------------------------*
*  Crea una Nueva Orden de Transporte con la Tabla Seleccionada
* ---------------------------------------------------------------------*
*
  CALL FUNCTION 'TRINT_INSERT_NEW_COMM'
    EXPORTING
      wi_kurztext       = w_desc_orden
      wi_trfunction     = 'K'
      iv_username       = sy-uname
    IMPORTING
      we_trkorr         = w_nume_orden
      we_e070           = wa_e070
      we_e07t           = wa_e07t
      we_e070c          = wa_e070c
    EXCEPTIONS
      no_systemname     = 1
      no_systemtype     = 2
      no_authorization  = 3
      db_access_error   = 4
      file_access_error = 5
      enqueue_error     = 6
      number_range_full = 7
      invalid_input     = 8
      OTHERS            = 9.
*
  IF sy-subrc IS INITIAL.
*
    CALL FUNCTION 'TRINT_MODIFY_COMM'
      EXPORTING
        wi_e070                        = wa_e070
        wi_e07t                        = wa_e07t
        wi_e070c                       = wa_e070c
        wi_sel_e071                    = 'X'
        wi_sel_e071k                   = 'X'
        iv_no_namespace_check          = 'X'
      TABLES
        wt_e071                        = tbi_e071
        wt_e071k                       = tbi_e071k
      EXCEPTIONS
        chosen_project_closed          = 1
        e070_insert_error              = 2
        e070_update_error              = 3
        e071k_insert_error             = 4
        e071k_update_error             = 5
        e071_insert_error              = 6
        e071_update_error              = 7
        e07t_insert_error              = 8
        e07t_update_error              = 9
        e070c_insert_error             = 10
        e070c_update_error             = 11
        locked_entries                 = 12
        locked_object_not_deleted      = 13
        ordername_forbidden            = 14
        order_change_but_locked_object = 15
        order_released                 = 16
        order_user_locked              = 17
        tr_check_keysyntax_error       = 18
        no_authorization               = 19
        wrong_client                   = 20
        unallowed_source_client        = 21
        unallowed_user                 = 22
        unallowed_trfunction           = 23
        unallowed_trstatus             = 24
        no_systemname                  = 25
        no_systemtype                  = 26
        OTHERS                         = 27.
*
    IF ( sy-subrc EQ 0 ).
      MESSAGE i368(00) WITH 'Nueva Orden Creada : '(e02) w_nume_orden.
    ELSE.
      MESSAGE e368(00) WITH
        'TRINT_MODIFY_COMM Error : '(e03) sy-subrc.
    ENDIF.
  ELSE.
    MESSAGE e368(00) WITH
      'TRINT_INSERT_NEW_COMM Error : '(e04) sy-subrc.
  ENDIF.
*----------------------------------------------------------------------*
