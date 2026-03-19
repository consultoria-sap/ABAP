****************************************
* Chequear que el archivo exista en PC local
****************************************

PARAMETERS: p_file TYPE rlgrap-filename.

* Variables
DATA: gl_gui_frontend_services TYPE REF TO cl_gui_frontend_services,
      l_existe TYPE abap_bool,
      l_file_string TYPE string.

  CLEAR: l_existe, l_file_string.

*Revisar que el archivo exista
  CREATE OBJECT gl_gui_frontend_services.
  l_file_string = p_file.
  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file                 = l_file_string
    RECEIVING
      result               = l_existe "(si existe lo llena con una X)
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.
*If not the file not exists
  IF l_existe IS INITIAL.
    MESSAGE i024(zz) WITH 'No existe el archivo localmente'.
  ENDIF. " IF l_existe IS INITIAL

*****************************************
* Chequear que el archivo exista en servidor  *
*****************************************

*Constantes y variables
  CONSTANTS: lc_bar TYPE c VALUE '/'.

  DATA: l_path_and_file(100) TYPE c,
        l_path(100)          TYPE c,
        l_name_file(100)     TYPE c,
        l_server_lines       TYPE i,

        BEGIN OF r_server_files,
          name_file(100) TYPE c,
        END OF r_server_files.

  DATA: i_server_files LIKE TABLE OF r_server_files,
        i_files        TYPE STANDARD TABLE OF salfldir.

  REFRESH: i_files, i_server_files.

* Clear
  CLEAR: l_path_and_file, l_path, l_server_lines,
         l_name_file, r_server_files.


  l_path_and_file = p_file.

* obtener directorio
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = l_path_and_file
    IMPORTING
      pathname = l_path.

* Obtener archivos
  CALL FUNCTION 'RZL_READ_DIR'
    EXPORTING
      name           = l_path
    TABLES
      file_tbl       = i_files
    EXCEPTIONS
      argument_error = 1
      not_found      = 2
      send_error     = 3
      system_failure = 4
      OTHERS         = 5.


  IF NOT sy-subrc IS INITIAL.
    MESSAGE i024(zz) WITH 'No existe el archivo en servidor'.
    LEAVE LIST-PROCESSING.
  ENDIF.


*Split
  SPLIT p_file AT '/' INTO TABLE i_server_files.
*Save
  DESCRIBE TABLE i_server_files LINES l_server_lines.
*Read table
  READ TABLE i_server_files INDEX l_server_lines INTO l_name_file.

*Sort
  SORT i_files BY name.
* Leer el archivo en la tabla
  READ TABLE i_files TRANSPORTING NO FIELDS
                     WITH KEY name = l_name_file
                     BINARY SEARCH.

*Si no existe
  IF NOT sy-subrc IS INITIAL.
    MESSAGE i024(zz) WITH 'No existe el archivo en servidor'.
    LEAVE LIST-PROCESSING.
  ENDIF.
