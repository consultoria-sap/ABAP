*&---------------------------------------------------------------------*
*&  Include           ZFTP001_TOP
*&---------------------------------------------------------------------*
REPORT  zftp001.

*----------------------------------------------------------------------*
* Declaración de Tipos                                                 *
*----------------------------------------------------------------------*
TYPES: BEGIN OF comm,
  line TYPE c LENGTH 250,       "Esta sera la estructura para que almacenara
END OF comm.                    "nuestros comandos FTP.

*----------------------------------------------------------------------*
*  Declaración de Variables Globales                                   *
*----------------------------------------------------------------------*
DATA: password(30)   TYPE c,        "Aqui se alojara nuestro password encriptado
      hdl            TYPE i,        "Se alojara el manejador asignado por el Sist.
      dstlen         TYPE i,        "Campo de recepcion obligatorio para la encriptacion
      confirm        LIKE sy-subrc. "Variable de control de errores

*----------------------------------------------------------------------*
*  Declaración de Constates Globales                                   *
*----------------------------------------------------------------------*
CONSTANTS:
  key TYPE i VALUE 26101957,                "Llave de encriptacion
  dest LIKE rfcdes-rfcdest VALUE 'SAPFTPA', "Destino SAP por default SAPFTPA
  ip(15) TYPE c VALUE '-con la ip destino-',      "IP de servidor destino
  user(15) TYPE c VALUE '-usuario-',           "Usuario de Servidor destino
  passerv(11) TYPE c VALUE '-contrasenia-'.    "Password de Servidor destino


*----------------------------------------------------------------------*
*  Declaración de Tablas Internas                                      *
*----------------------------------------------------------------------*
DATA: commands TYPE STANDARD TABLE OF comm, "Tabla interna que almacenara nuestros comandos FTP
      mtab_data TYPE STANDARD TABLE OF comm."Almacenara nuestro resultado de la ejecucion de los comandos FTP


*----------------------------------------------------------------------*
*  Declaración de Areas de Trabajo                                     *
*----------------------------------------------------------------------*
DATA: wa_commands TYPE comm, "Area de trabajo para el envio de comandos
      wa_mtab TYPE comm.     "Area de trabajo para la recepcion de informacion


*&---------------------------------------------------------------------*
*&       Class actions
*&---------------------------------------------------------------------*
*  Clase local para remplazar los simbolos del nombre
*----------------------------------------------------------------------*
CLASS actions DEFINITION.
  PUBLIC SECTION.

    METHODS:
*Metodo de Encriptacion
             encrypt   IMPORTING value(contrasena) LIKE passerv
                                 value(llave) LIKE key,
*Metodo de Conexion FTP
             connect   IMPORTING value(usuario) LIKE user
                                 value(contrasena) LIKE password
                                 value(ipdestino) LIKE ip
                                 value(destsap) LIKE dest
                       RETURNING value(encargado) LIKE hdl,
*Metodo de Envio de Comandos
             send_comm IMPORTING value(encargado) LIKE hdl
                                 value(index) TYPE i
                                 value(comandos) LIKE commands
                       RETURNING value(receive) LIKE mtab_data,
*Metodo de Cierre de Sesion FTP
             close     IMPORTING value(encargado) LIKE hdl
                       RETURNING value(subrc) LIKE sy-subrc,
*Metodo para Agregar Comandos FTP
             append    IMPORTING value(line) LIKE wa_commands-line.

ENDCLASS.                    "actions DEFINITION
