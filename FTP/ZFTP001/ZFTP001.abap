*&---------------------------------------------------------------------*
*& Report  ZFTP001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zftp001_top.  "Include de elementos para el programa

INCLUDE zftp001_mimp. "Include para la implementeacion de metodos y perform

START-OF-SELECTION.   "Inicio del programa

  DATA: obj TYPE REF TO actions.  "Creacin del objeto que se instanciara
  CREATE OBJECT obj.              "en nuestro metodo

  obj->encrypt( contrasena = passerv llave = key ).    "Llamada el metodo encrypt

  hdl = obj->connect( usuario = user contrasena = password "Llamada al metodo connect la cual
                ipdestino = ip destsap = dest ).           "almacenamos el resultado en una varible

  CONCATENATE 'cd' '-ruta de la carpeta-' INTO wa_commands-line SEPARATED BY space.
  obj->append( line = wa_commands-line ).             "Llamada al metodo que agrega lista de comandos
  obj->append( line = 'dir' ).                        ""

  mtab_data = obj->send_comm( encargado = hdl index = 0 comandos = commands ).  "Llamada al metodo que hace el
                                                                                "envio de Comandos via FTP
  LOOP AT mtab_data INTO wa_mtab.   "Visualizamos el contenido de la ejecucion
    WRITE:/ wa_mtab-line.           "de nuestro comando FTP
  ENDLOOP.

  obj->close( hdl ).   "Llamada al metodo que cierra la coneion FTP

END-OF-SELECTION.
