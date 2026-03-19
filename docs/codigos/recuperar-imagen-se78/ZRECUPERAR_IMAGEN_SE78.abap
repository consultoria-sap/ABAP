*&---------------------------------------------------------------------*
*& Report  ZRECUPERAR_IMAGEN_SE78
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zrecuperar_imagen_se78.

DATA: l_bytecount TYPE i,
      l_tdbtype LIKE stxbitmaps-tdbtype,
      l_content TYPE STANDARD TABLE OF bapiconten
      INITIAL SIZE 0.

DATA: graphic_size TYPE i.

DATA: BEGIN OF graphic_table OCCURS 0,
      line(255) TYPE x,
      END OF graphic_table.


DATA: btype LIKE  stxbitmaps-tdbtype.


SELECTION-SCREEN BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
PARAMETERS: name_img LIKE stxbitmaps-tdname DEFAULT 'ENJOY',
            filename TYPE  string DEFAULT 'C:\Oscar\Imagen_recup.bmp'.

SELECTION-SCREEN SKIP.

PARAMETERS: p_bcol RADIOBUTTON GROUP rad1,
            p_bmon RADIOBUTTON GROUP rad1.
SELECTION-SCREEN END OF BLOCK uno.



IF p_bcol = 'X'.
  btype = 'BCOL'.
ELSE.
  btype = 'BMON'.
ENDIF.


CALL FUNCTION 'SAPSCRIPT_GET_GRAPHIC_BDS'
  EXPORTING
    i_object       = 'GRAPHICS'
    i_name         = name_img    " Nombre del Logo
    i_id           = 'BMAP'
    i_btype        = btype
  IMPORTING
    e_bytecount    = l_bytecount
  TABLES
    content        = l_content
  EXCEPTIONS
    not_found      = 1
    bds_get_failed = 2
    bds_no_content = 3
    OTHERS         = 4.


CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
  EXPORTING
    old_format               = 'BDS'
    new_format               = 'BMP'
    bitmap_file_bytecount_in = l_bytecount
  IMPORTING
    bitmap_file_bytecount    = graphic_size
  TABLES
    bds_bitmap_file          = l_content
    bitmap_file              = graphic_table
  EXCEPTIONS
    OTHERS                   = 1.



CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    bin_filesize = graphic_size
    filename     = filename
    filetype     = 'BIN'
  TABLES
    data_tab     = graphic_table.

IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

