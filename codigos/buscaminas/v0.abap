REPORT  zbuscaminas NO STANDARD PAGE HEADING LINE-SIZE 125.
* ------------------------------------------------------------
* ABAP Minesweeper
* (c) Andrey Timofeev
* http://mrand.name/sap-abap
* license: free, "as is"
* ------------------------------------------------------------
* Installation: compile and run.
*   (for SAP 4.x, use http://mrand.name/sap-abap/sweeper4.txt)
* ------------------------------------------------------------
*  v1.0    2009.04.01
*     initial release
*


INCLUDE <icon>.


CONSTANTS:
" >> board cell values
   blank_hidden  TYPE c VALUE '0',
   blank_marked  TYPE c VALUE 'm',
   blank_opened  TYPE c VALUE '.',

   bomb_hidden   TYPE c VALUE '*',
   bomb_marked   TYPE c VALUE 'M',
   bomb_opened   TYPE c VALUE '&',

   "digit_hidden TYPE c VALUE 'A', "  A B C D E F G H
   "digit_marked TYPE c VALUE 'a', "  a b c d e f g h
   "digit_opened TYPE c VALUE '1', "  1 2 3 4 5 6 7 8

   endgame_bomb_boom       TYPE c VALUE 'X',
   endgame_bomb_missmark   TYPE c VALUE '@',
   border                  TYPE c VALUE '#',

" >> game state
   game_in   VALUE '1',
   game_over VALUE '2',
   game_win  VALUE '3'.

DATA:
   board(9999) TYPE c,  " 2D board,  x_size * y_size + borders
   ofs         TYPE i,  " board[ofs] = cell unique ID
   min         TYPE i,  " board[min] .. board[max]
   max         TYPE i,
   rdx         TYPE i,  " = 2 + width  of board
   rdy         TYPE i,  " = 2 + height of board
   square      TYPE i,  " = x_size * y_size = visible area
   square2     TYPE i,  " =    rdx *    rdy = visible area + border
   range       TYPE i,  " = max - min + 1
   rest        TYPE i,  " = square - bomb_cnt = empty cells to invent
   game        TYPE c,  " gamestate  = 1,2,3
   game_size   TYPE c,  " B=Beginner, I=Interm, E=Expert, C=Custom
   game_time(5) TYPE c, " seconds
   b_left(4)   TYPE c.  " unmarked bombs left

"  >> eight directions: North, South, East, West, NE, NW, SE, SW
DATA:  eight_directions TYPE TABLE OF i INITIAL SIZE 8 WITH HEADER
LINE .

" >> cells2update list, to track board[] changes
TYPES:
   BEGIN OF celltype,
      offset(4) TYPE c,
      color TYPE c,
   END OF celltype.
DATA: cells2update TYPE TABLE OF celltype INITIAL SIZE 1000 WITH
HEADER LINE.

" >> misc
CONSTANTS:
   x_ofs TYPE i VALUE 1,
   y_ofs TYPE i VALUE 5.
DATA:
   game_time1 TYPE timestamp, " game    begin
   game_time2 TYPE timestamp.


" >> high_scores
CONSTANTS:
   database_id_prefix(21) TYPE c VALUE 'ABAPMINESWEEPERSCORES'.
TYPES:
   BEGIN OF score_line,
      user    LIKE sy-uname,
      time(5) TYPE c,
   END OF score_line.

DATA:
   high_scores TYPE SORTED TABLE OF score_line
        WITH UNIQUE KEY time WITH HEADER LINE,
   database_id LIKE indx-srtfd. " export/import to database ID





" >> game difficulty
SELECTION-SCREEN BEGIN OF BLOCK bl_game_difficulty.

SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: COMMENT  (23) hstitle1.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS g1 RADIOBUTTON GROUP one
        USER-COMMAND radiogroup01.
SELECTION-SCREEN: COMMENT (10) text1.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS g2 RADIOBUTTON GROUP one.
SELECTION-SCREEN: COMMENT (12) text2.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS g3 RADIOBUTTON GROUP one.
SELECTION-SCREEN: COMMENT (10) text3.
SELECTION-SCREEN: END OF LINE.


SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS g4 RADIOBUTTON GROUP one.
SELECTION-SCREEN: COMMENT (10) text4.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: END OF BLOCK bl_game_difficulty.


" >> High Scores table
SELECTION-SCREEN BEGIN OF BLOCK bl_high_scores.

SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: COMMENT  (1) dummy1.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: COMMENT  (23) hstitle2.
SELECTION-SCREEN: END OF LINE.

DEFINE displ_hsline.
  selection-screen: begin of line.
  selection-screen: comment  (1) hs1_&1.
  selection-screen: comment (12) hs2_&1.
  selection-screen: comment  (5) hs3_&1.
  selection-screen: end of line.
END-OF-DEFINITION.

SELECTION-SCREEN ULINE /1(20).
displ_hsline 0.
SELECTION-SCREEN ULINE /1(20).
displ_hsline 1.
displ_hsline 2.
displ_hsline 3.
displ_hsline 4.
displ_hsline 5.
displ_hsline 6.
displ_hsline 7.
displ_hsline 8.
displ_hsline 9.

SELECTION-SCREEN: END OF BLOCK bl_high_scores.



" >> Window: Custom Game Dimensions

SELECTION-SCREEN BEGIN OF SCREEN 1001.

SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: COMMENT (12) txtcustw.
PARAMETERS: x_size TYPE i  DEFAULT '09'.

SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: COMMENT (12) txtcusth.
PARAMETERS: y_size TYPE i  DEFAULT '09'.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN: COMMENT (12) txtcustb.
PARAMETERS: bomb_cnt TYPE i DEFAULT '10'.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN END OF SCREEN 1001.




" >>  modify board[ofs] and track changes
DEFINE setcell.
  board+ofs(1) = &1.

  cells2update-offset = ofs.
  cells2update-color = &1.
  append cells2update.

  if game_time1 is initial.
    get time stamp field game_time1.
  endif.
END-OF-DEFINITION.


*----------------------------------------------------------------------*
*       CLASS cl_my_gui_html_viewer DEFINITION
*----------------------------------------------------------------------*
* Custom HTML contol
*----------------------------------------------------------------------*
CLASS cl_my_gui_html_viewer DEFINITION INHERITING FROM
         cl_gui_html_viewer.
  PUBLIC SECTION.
    METHODS: constructor  IMPORTING parent TYPE REF TO cl_gui_container.
    METHODS: html_board_update.
  PRIVATE SECTION.
    METHODS: on_sapevent FOR EVENT sapevent OF cl_gui_html_viewer
                 IMPORTING action query_table.
    DATA: js TYPE STANDARD TABLE OF char255 INITIAL SIZE 1000.

ENDCLASS.                    "cl_my_gui_html_viewer DEFINITION


DATA:
    lo_dock TYPE REF TO cl_gui_docking_container,
    lo_cont TYPE REF TO cl_gui_container,
    html_control TYPE REF TO cl_my_gui_html_viewer,
    wnd_style TYPE i.


INITIALIZATION.
  hstitle1 = '   :: GAME DIFFICULTY ::'.

  text1 = 'Beginner'.
  text2 = 'Intermediate'.
  text3 = 'Expert'.
  text4 = 'Custom'.

  txtcustw = 'Width'.
  txtcusth = 'Height'.
  txtcustb = 'Bombs'.

  hstitle2 = '   :: HIGH SCORES ::'.
  hs1_0 = '#'.
  hs2_0 = 'user'.
  hs3_0 = 'time'.

  hs1_1  = '1'.
  hs1_2  = '2'.
  hs1_3  = '3'.
  hs1_4  = '4'.
  hs1_5  = '5'.
  hs1_6  = '6'.
  hs1_7  = '7'.
  hs1_8  = '8'.
  hs1_9  = '9'.




  " >> create controls
  wnd_style = cl_gui_control=>ws_thickframe + cl_gui_control=>ws_child.

  CREATE OBJECT lo_dock
    EXPORTING
      repid = sy-cprog
      dynnr = sy-dynnr
      ratio = 80
      side  = cl_gui_docking_container=>dock_at_right
      name  = 'DOCK_CONT'
      style = wnd_style.

  lo_cont = lo_dock.

  CREATE OBJECT html_control
    EXPORTING
      parent = lo_cont.

  " >>
  PERFORM game_create USING 'B' x_size y_size bomb_cnt.

  PERFORM html_load_gifs.

  PERFORM html_show.


AT LINE-SELECTION. " abap-mode, cmd 'PICK'
  ADD -1 TO sy-lsind.

  IF sy-lisel CS 'switch'.
    LEAVE LIST-PROCESSING.
  ELSE.
    CHECK game = game_in.

    PERFORM cell_get_clicked CHANGING ofs.
    CHECK ofs > 0.

    PERFORM cell_open USING ofs.
    IF rest <= 0 AND game = game_in.

      GET TIME STAMP FIELD game_time2.
      game_time = game_time2 - game_time1.

      PERFORM game_ok.
    ENDIF.
    PERFORM game_print_abap.

  ENDIF.

AT PF09.  " abap-mode, cmd 'MARK'
  ADD -1 TO sy-lsind.
  IF game = game_in.
    PERFORM cell_get_clicked CHANGING ofs.
    CHECK ofs > 0.
    PERFORM cell_mark USING ofs.
    PERFORM game_print_abap.
  ENDIF.



AT SELECTION-SCREEN OUTPUT.
  IF LINES( cells2update ) > 0.
    " here: switch back from abap to html
    CALL METHOD html_control->html_board_update( ).
  ENDIF.


AT SELECTION-SCREEN ON RADIOBUTTON GROUP one.
  CHECK sy-ucomm = 'RADIOGROUP01'.
  IF g1 = 'X'.
    PERFORM game_create USING 'B' 09 09 10.
  ELSEIF g2 = 'X'.
    PERFORM game_create USING 'I' 16 16 40.
  ELSEIF g3 = 'X'.
    PERFORM game_create USING 'E' 30 16 99.
  ELSE.
    CALL SELECTION-SCREEN 1001
         STARTING AT 20 4.
    PERFORM game_create USING 'C' x_size y_size bomb_cnt.
  ENDIF.

  PERFORM html_show.


*&---------------------------------------------------------------------*
*&      Form  game_print_abap.
*&---------------------------------------------------------------------*
FORM game_print_abap.
  DATA:  ofs TYPE i, ch TYPE c.

  SKIP TO LINE 3.

  WRITE: / 'Bombs left: ', b_left NO-ZERO.

  ofs = rdx.
  SKIP TO LINE y_ofs.

  DO y_size TIMES.
    WRITE AT x_ofs '|' NO-GAP.

    DO x_size TIMES.
      ADD 1 TO ofs.
      ch = board+ofs(1).
      CASE ch.
        WHEN blank_opened.
          WRITE: ' '.

        WHEN '1' OR '2' OR '3' OR '4' OR '5' OR '6' OR '7' OR '8'.
          WRITE: ' ' NO-GAP, ch NO-GAP.

        WHEN bomb_marked.
          WRITE icon_breakpoint AS ICON NO-GAP.

        WHEN blank_marked
        OR 'a' OR 'b' OR 'c' OR 'd' OR 'e' OR 'f' OR 'g' OR 'h'.
          WRITE icon_breakpoint AS ICON NO-GAP.

        WHEN endgame_bomb_missmark.
          WRITE icon_breakpoint_disable AS ICON NO-GAP.

        WHEN endgame_bomb_boom.
          WRITE icon_system_cancel AS ICON NO-GAP.

        WHEN bomb_opened. "endgame only
          WRITE icon_dummy AS ICON NO-GAP.

        WHEN OTHERS.
          WRITE: icon_wd_transparent_container AS ICON NO-GAP.
      ENDCASE.
    ENDDO.
    WRITE '|'.
    ADD 2 TO ofs.
    NEW-LINE.
  ENDDO.
  WRITE: AT x_ofs '' NO-GAP, '    switch back   ' COLOR 2 HOTSPOT ON.

  IF game = game_over.
    WRITE: /, /4  'Game over', /, /.
  ELSEIF   game = game_win.
    WRITE: /, /4   'You win', /, /.
  ELSE.
    SKIP 3.
  ENDIF.
  WRITE: / '   open: double-click'.
  WRITE: / '   mark: click and press F9'.
ENDFORM.                    "game_print_abap


*&---------------------------------------------------------------------*
*&      Form  CELL_MARK
*&---------------------------------------------------------------------*
*   mark a cell with 'bomb sign'
*----------------------------------------------------------------------*
FORM cell_mark USING value(ofs) TYPE i.
  DATA: ch TYPE c.
  ch = board+ofs(1).
  CASE ch.
    WHEN blank_hidden. setcell blank_marked. ADD -1 TO b_left.
    WHEN blank_marked. setcell blank_hidden. ADD +1 TO b_left.
    WHEN bomb_hidden.  setcell bomb_marked.  ADD -1 TO b_left.
    WHEN bomb_marked.  setcell bomb_hidden.  ADD +1 TO b_left.

    WHEN 'A' OR 'B' OR 'C' OR 'D' OR 'E' OR 'F' OR 'G' OR 'H'.
      TRANSLATE ch TO LOWER CASE.
      setcell   ch.      ADD -1 TO b_left.

    WHEN 'a' OR 'b' OR 'c' OR 'd' OR 'e' OR 'f' OR 'g' OR 'h'.
      TRANSLATE ch TO UPPER CASE.
      setcell  ch.       ADD +1 TO b_left.

  ENDCASE.
ENDFORM.                    "CELL_MARK



*&---------------------------------------------------------------------*
*&      Form  cell_open
*&---------------------------------------------------------------------*
*       open a cell, at one's own risk
*----------------------------------------------------------------------*
FORM cell_open USING value(ofs) TYPE i.
  CASE board+ofs(1).
    WHEN blank_hidden.
      PERFORM cell_floodfill USING ofs.
    WHEN 'A'. setcell  '1'. ADD -1 TO rest.
    WHEN 'B'. setcell  '2'. ADD -1 TO rest.
    WHEN 'C'. setcell  '3'. ADD -1 TO rest.
    WHEN 'D'. setcell  '4'. ADD -1 TO rest.
    WHEN 'E'. setcell  '5'. ADD -1 TO rest.
    WHEN 'F'. setcell  '6'. ADD -1 TO rest.
    WHEN 'G'. setcell  '7'. ADD -1 TO rest.
    WHEN 'H'. setcell  '8'. ADD -1 TO rest.
    WHEN '1' OR '2' OR '3' OR '4' OR '5' OR '6' OR '7' OR '8'.
      PERFORM cell_open_around USING ofs.
    WHEN bomb_hidden.
      setcell endgame_bomb_boom.
      PERFORM game_lose.
  ENDCASE.
ENDFORM.                    "cell_open

*&---------------------------------------------------------------------*
*&      Form  cell_get_clicked
*&---------------------------------------------------------------------*
FORM cell_get_clicked CHANGING ofs TYPE i.
  DATA: row TYPE i, col TYPE i.
  row =   sy-curow - y_ofs.
  col = ( sy-cucol - x_ofs - 2 ) DIV 2.
  ofs = ( 1 + row ) * rdx + col + 1.
  IF row < 0 OR row > y_size OR
     col < 0 OR col > x_size.
    ofs = 0.
  ENDIF.
ENDFORM.                    "cell_get_clicked



DATA: floodfill TYPE TABLE OF i INITIAL SIZE 1000.

*&---------------------------------------------------------------------*
*&      Form  cell_flood_fill
*&---------------------------------------------------------------------*
*      open all adjacent empty cells
*----------------------------------------------------------------------*
FORM cell_floodfill USING value(x) TYPE i.
  DATA: ofs TYPE i.

  ofs = x + 00. " cell itself
  setcell blank_opened. ADD -1 TO rest.

  APPEND x TO floodfill.
  LOOP AT floodfill INTO x.
    LOOP AT eight_directions.
      ofs = x + eight_directions.

      CASE board+ofs(1).
        WHEN blank_hidden.
          setcell blank_opened.  ADD -1 TO rest.
          APPEND ofs TO floodfill.
        WHEN 'A'. setcell '1'. ADD -1 TO rest.
        WHEN 'B'. setcell '2'. ADD -1 TO rest.
        WHEN 'C'. setcell '3'. ADD -1 TO rest.
        WHEN 'D'. setcell '4'. ADD -1 TO rest.
        WHEN 'E'. setcell '5'. ADD -1 TO rest.
        WHEN 'F'. setcell '6'. ADD -1 TO rest.
        WHEN 'G'. setcell '7'. ADD -1 TO rest.
        WHEN 'H'. setcell '8'. ADD -1 TO rest.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
  REFRESH floodfill.
ENDFORM.                    "cell_flood_fill



*&---------------------------------------------------------------------*
*&      Form  cell_open_eight_directions
*&---------------------------------------------------------------------*
*       Open up to 8 cells around current one
*----------------------------------------------------------------------*
FORM cell_open_around USING value(x) TYPE i.
  DATA: ofs TYPE i.
  DATA: value TYPE i.

  " 1 >> get cell's VALUE       (1 to 8)
  value = board+x(1).

  " 2 >> look around it, get count of marked
  LOOP AT eight_directions.
    ofs = x + eight_directions.
    CASE board+ofs(1).
      WHEN bomb_marked
        OR blank_marked
        OR 'a' " digit_maked
        OR 'b' " ..
        OR 'c'
        OR 'd'
        OR 'e'
        OR 'f'
        OR 'g'
        OR 'h'.
        value = value - 1.
    ENDCASE.
  ENDLOOP.

  " 3 >> check its EQness
  CHECK value = 0.

  " 4 >> here: opening is possible

  " 5 >> do open
  LOOP AT eight_directions.
    ofs = x + eight_directions.
    CASE board+ofs(1).
      WHEN blank_hidden.
        PERFORM cell_floodfill USING ofs.

      WHEN 'A'. setcell '1'. ADD -1 TO rest.
      WHEN 'B'. setcell '2'. ADD -1 TO rest.
      WHEN 'C'. setcell '3'. ADD -1 TO rest.
      WHEN 'D'. setcell '4'. ADD -1 TO rest.
      WHEN 'E'. setcell '5'. ADD -1 TO rest.
      WHEN 'F'. setcell '6'. ADD -1 TO rest.
      WHEN 'G'. setcell '7'. ADD -1 TO rest.
      WHEN 'H'. setcell '8'. ADD -1 TO rest.

      WHEN blank_marked
        OR 'a'
        OR 'b'
        OR 'c'
        OR 'd'
        OR 'e'
        OR 'f'
        OR 'g'
        OR 'h'.
        setcell endgame_bomb_missmark.

      WHEN bomb_hidden.
        setcell endgame_bomb_boom.
        PERFORM game_lose.
    ENDCASE.

  ENDLOOP.
ENDFORM.                    "cell_open_eight_directions



*&---------------------------------------------------------------------*
*&      Form  game_lose
*&---------------------------------------------------------------------
FORM game_lose.

  game = game_over.
  ADD -1 TO b_left.
  " >> show actual bombs
  WHILE board(square2) CA '*abcdefghm'. "  digit_marked + blank_marked
    ofs = sy-fdpos.
    IF board+ofs(1) = bomb_hidden. " if  = '*'
      setcell bomb_opened.
    ELSE.
      setcell endgame_bomb_missmark.
    ENDIF.
  ENDWHILE.

  MESSAGE s000(su) WITH 'Game over'.
ENDFORM.                                                    "game_lose


*&---------------------------------------------------------------------*
*&      Form  game_ok
*&---------------------------------------------------------------------*
FORM game_ok.

  game = game_win.
  b_left = 0.
  " >> show bombs
  WHILE board(square2) CS bomb_hidden.
    ofs = sy-fdpos.
    setcell bomb_marked.
  ENDWHILE.

  MESSAGE s000(su) WITH 'You win!' .

  CHECK game_size <> 'C'.

  PERFORM high_scores_read.
  PERFORM high_scores_update.
  PERFORM high_scores_show.

ENDFORM.                                                    "game_ok


*&---------------------------------------------------------------------*
*&      Form  game_create
*&---------------------------------------------------------------------*
FORM game_create USING
     value(sz)  TYPE c
     value(x)   TYPE i
     value(y)   TYPE i
     value(b)   TYPE i.

  DATA:
     ofs        TYPE i,
     j          TYPE i,
     drop_cnt   TYPE i,
     drop_bombs TYPE c.
  DATA:
     prng TYPE REF TO cl_abap_random_int,
     backgr     TYPE c,
     foregr     TYPE c,
     half       TYPE i.


  game_size = sz.
  x_size = x.
  y_size = y.
  bomb_cnt = b.

  CONCATENATE database_id_prefix game_size INTO database_id.

  CLEAR:
    game_time,
    game_time1,
    game_time2.

  game = game_in.

  PERFORM high_scores_read.
  PERFORM high_scores_show.

  CLEAR: board.

  square = x_size * y_size.
  IF bomb_cnt > square.
    bomb_cnt = square. " limit bombs to 100%
  ENDIF.
  b_left = bomb_cnt.

  rest = square - bomb_cnt. " empty places to invent

  rdx =  2 + x_size. " width  + left and right  border
  rdy =  2 + y_size. " height + top  and button border

  square2 = rdx * rdy.

  IF square2 > 9999.
    MESSAGE e000(su)  WITH 'board too large (9999)'.
  ENDIF.

  " >>  board[9999]'s used space
  min = 1 + 1 * rdx.       " topleft
  max = square2 - rdx - 2. " bottomright
  range = max - min + 1.

  " >> directions
  REFRESH eight_directions.
  eight_directions = -1 + rdx * -1.  APPEND eight_directions. " NW
  eight_directions = 00 + rdx * -1.  APPEND eight_directions. " North
  eight_directions = +1 + rdx * -1.  APPEND eight_directions. " NE
  eight_directions = -1 + rdx * 00.  APPEND eight_directions. " W
  eight_directions = +1 + rdx * 00.  APPEND eight_directions. " E
  eight_directions = -1 + rdx * +1.  APPEND eight_directions. " SW
  eight_directions = 00 + rdx * +1.  APPEND eight_directions. " S
  eight_directions = 01 + rdx * +1.  APPEND eight_directions. " SE

  " >> bomb placement

  " >>   speed optimization:
  "        if bombs < 50%, place bombs  randomly
  "        if bombs > 50%, place spaces randomly

  half = x_size * y_size DIV 2.
  IF bomb_cnt < half.
    drop_bombs = 'X'.     " straight order
    drop_cnt = bomb_cnt.
    backgr = blank_hidden.
    foregr = bomb_hidden.
  ELSE.
    drop_bombs = ' '.     " reversed order
    drop_cnt = rest.
    backgr = bomb_hidden.
    foregr = blank_hidden.
  ENDIF.

  " >> fill background
  ofs = min.
  DO range TIMES.
    board+ofs(1) = backgr.
    ADD 1 TO ofs.
  ENDDO.

  " >> horizontal border
  DO rdx TIMES.

    ofs = sy-index - 1.
    board+ofs(1) = border.

    ofs = square2 - sy-index .
    board+ofs(1) = border.
  ENDDO.
  " >> vertical border
  DO y_size TIMES.
    ofs = rdx * sy-index.
    board+ofs(1) = border.
    ofs = sy-index * rdx + rdx - 1.
    board+ofs(1) = border.
  ENDDO.


  " >> actual placement
  DATA: seed TYPE i.
  seed = cl_abap_random=>seed( ).


  prng = cl_abap_random_int=>create(
   seed = seed min = min max = max ).

  DO drop_cnt TIMES.
    DO.
      ofs = prng->get_next( ).

      CASE board+ofs(1).
        WHEN foregr OR border.
          " skip used cells
        WHEN OTHERS.
          EXIT. " found unused (BG 1 2 3 4 5 6 7 8)
      ENDCASE.
    ENDDO.

    board+ofs(1) = foregr.

    IF drop_bombs = 'X'.
      " add 1 point to cells around
      LOOP AT eight_directions.
        j = ofs + eight_directions.
        CASE board+j(1).
          WHEN bomb_hidden OR border.

          WHEN OTHERS.
            board+j(1) = board+j(1) + 1.
        ENDCASE.
      ENDLOOP.
    ELSE.
      " get 1 point from every bomb around
      LOOP AT eight_directions.
        j = ofs + eight_directions.
        CASE board+j(1).
          WHEN bomb_hidden.
            board+ofs(1) = board+ofs(1) + 1.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDDO.

  " >> hide digits
  TRANSLATE board(square2) USING '1A2B3C4D5E6F7G8H'.

ENDFORM.                    "game_create








*----------------------------------------------------------------------*
*       CLASS my_cl_gui_html_viewer IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_my_gui_html_viewer IMPLEMENTATION.

  METHOD constructor.
    DATA: myevent_tab TYPE cntl_simple_events,
          myevent TYPE cntl_simple_event.

    CALL METHOD super->constructor(
      parent = parent
      uiflag = html_control->uiflag_noiemenu
      ).

    myevent-appl_event = 'X'.
    myevent-eventid = html_control->m_id_sapevent.
    APPEND myevent TO myevent_tab.
    myevent-eventid = html_control->m_id_navigate_complete.
    APPEND myevent TO myevent_tab.

    CALL METHOD html_control->set_registered_events(
      events = myevent_tab
      ).

    SET HANDLER me->on_sapevent FOR html_control.

  ENDMETHOD.                    "constructor

  " >> HTML callback event
  METHOD on_sapevent.  " arguments:  action, query_table[]
    DATA: param LIKE LINE OF query_table.
    DATA: cell_ofs TYPE i.


    READ TABLE query_table WITH KEY name = 'ID' INTO param.
    IF sy-subrc EQ 0.  cell_ofs = param-value. ENDIF.

    READ TABLE query_table WITH KEY name =  'TIME' INTO param.
    IF sy-subrc EQ 0.  game_time = param-value. ENDIF.

    CASE action.

      WHEN 'click'.    " left-click
        CHECK game = game_in.
        PERFORM cell_open USING cell_ofs.
        IF rest <= 0 AND game = game_in.
          PERFORM game_ok.
        ENDIF.
        CALL METHOD me->html_board_update( ).

      WHEN 'mouseup'.   " right-click
        CHECK game = game_in.
        PERFORM cell_mark USING cell_ofs.
        CALL METHOD me->html_board_update( ).

      WHEN 'newgame'.
        PERFORM game_create USING game_size x_size y_size bomb_cnt.
        PERFORM html_show.

      WHEN 'switch'.
        LEAVE TO LIST-PROCESSING.
        SET PF-STATUS space.
        PERFORM game_print_abap.
    ENDCASE.

  ENDMETHOD.                    "on_sapevent

  " >> transport board[]'s changes (saved in cells2update[]), to HTML
  METHOD html_board_update.
    DATA: ofs TYPE i, new TYPE i, len TYPE i, end TYPE i.
    DATA: buf TYPE string.
    DATA: jsline LIKE LINE OF js.

    " >> convert cells2update[] to plain string
    CONCATENATE LINES OF cells2update INTO buf SEPARATED BY '|'.
    CONDENSE buf NO-GAPS.

    " >> convert plain string to JavaScript code
    "    and pack it to HTML_VIEWER's compatible table
    ofs = 0.
    end = STRLEN( buf ).

    WHILE ofs < end.
      new = ofs + 249. "    255 - strlen ( b+=""; ) is 249

      IF new > end. "
        len = end - ofs.
      ELSE.
        len = 249.
      ENDIF.

      CONCATENATE 'b+="' buf+ofs(len) '";'  INTO jsline.
      APPEND jsline TO js.

      ofs = ofs + len.
    ENDWHILE.


    CONCATENATE 'updateCells(' game ',"' b_left+1 '")' INTO jsline.
    APPEND jsline TO js.

    " >> actual transfer
    CALL METHOD me->set_script( script = js[] ).
    CALL METHOD me->execute_script( ).


    " >>
    REFRESH js.
    REFRESH cells2update.

  ENDMETHOD.                    "html_board_update

ENDCLASS.                    "cl_my_gui_html_viewer IMPLEMENTATION


*&---------------------------------------------------------------------*
*&      Form  html_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->S          text
*----------------------------------------------------------------------*
FORM html_create TABLES html.
  DATA: html_str TYPE string, s TYPE string,
        table1 TYPE TABLE OF char255 WITH HEADER LINE INITIAL SIZE 150.


  IF 1 = 2.

    "    CALL FUNCTION 'WS_UPLOAD'
    "      EXPORTING
    "        filename = 'C:\SAP\game\source.html'
    "        filetype = 'ASC'
    "      TABLES
    "        data_tab = html[]
    "      EXCEPTIONS
    "        OTHERS   = 1.
    "    CHECK sy-subrc EQ 0.
    "
    "    CONCATENATE LINES OF html INTO html_str SEPARATED BY '~'.

  ELSE.


    " >>  create html
    CONCATENATE

      '<html><head>'
  '<meta http-equiv="content-type" content="text/html">'
  '<style type="text/css">'
  '*    { font: bold 12px sans-serif}'
  'span { position: absolute;  width: 16px; height: 16px;'
  '       font-size: 6pt;      background: url("blank.gif")}'
  'div  { background: silver;  margin: 8px 0;'
  '       text-align: center;  border: 2px inset white}'
  'td   { text-align: center;  padding: 0}'
  'td div{height: 24px;        width: 30px; margin: 0;'
  '       padding: 3px;        border: 1px gray solid}'
  '#wMain{position: absolute;  padding: 0 8px;'
  '       border: 2px outset white}'
  '#wTool{height: 34px}'
  '</style>'

  '<script>'
  'var DX=10, DY=10, BB=98,'
  '    game=1, tID, tm=0,    mouse_left=0, mouse_right=2,'
  '    images=[], SZ=16, x, y, b="",'
  '    imagesInfo = ['
  '   "blank *0ABCDEFGH",'

  '   "bombdeath X",        "bombrevealed &",'
  '   "bombmisflagged @",   "bombflagged mMabcdefgh",'

  '   "open1 1",   "open2 2",   "open3 3",'
  '   "open4 4",   "open5 5",   "open6 6",'
  '   "open7 7",   "open8 8",   "open0 ."'
  '];'

  '/*VARIABLES_INITIALIZATION_HERE_DONT_DELETE*/'

  'function init(){'
  '  c1.innerText = BB;'

  '  c2.onclick        = abapHandler("IMG" , mouse_left, "newgame");'
  '  document.onclick  = abapHandler("SPAN", mouse_left,   "click");'
  '  document.onmouseup= abapHandler("SPAN", mouse_right,"mouseup");'

  '  var p, w = DX*SZ+4;  var h = DY*SZ+4;'
  '  setSize(wBrd,  w, h);'
  '  setSize(wMain, w+20);'
  '  map(imagesInfo, function(x){'
  '      map((p = x.split(" "))[1].split(""),'
  '        function(ch){images[ch]=p[0]+".gif"})}'
  '  )'
  '}'

  'function updateCells(game_state, bomb_left){'
  '  game = game_state;  c1.innerText = bomb_left;'

  '  var x, i, seq = b.split("|"); b = "";'
  '  for(i=0;i<seq.length;i++)'
  '    if (x=seq) with(document.getElementById("x"+x.slice(0,-1)))'
  '       style.backgroundImage = "url("+images[x.slice(-1)]+")";'
  '  if (game==2) {clearTimeout(tID); c2.src = "facedead.gif"}'
  '  if (game==3) {clearTimeout(tID); c2.src = "facewin.gif" }'
  '}'

  'function abapHandler(tag, mouse_button, action){'
  '  return('
  '    function(){'
  '      var ev = window.event, obj = ev.srcElement;'
  '      if (obj.nodeName == tag && ev.button==mouse_button) {'
  '        tID = tID ? tID : setTimeout("onTimer()", 1000);'
  '        callback.href ='
  '          "SAPEVENT:"+action+"?ID="+obj.id.slice(1)+"&TIME="+tm;'
  '        callback.click();'
  '      }'
  '    }'
  '  )'
  '}'

  'function onTimer(){'
  '  c3.innerText = ++tm;'
  '  tID = (game==1) ? setTimeout("onTimer()", 1000) : tID;'
  '}'

  'function setSize(obj, w, h){'
  '  obj.style.width = w;'
  '  if (h) obj.style.height = h;'
  '}'

  'function map(list, func){'
  '  var a = new Array(list.length);'
  '  for (var i=0;i<list.length;i++) a=func(list,i);'
  '  return a;'
  '}'
  '</script></head>'


  '<body onload="init()">'
  '<div id=wMain>'
  '<div id=wTool><table border=0 id=wHdr>'
  '<tr>'
  ' <td width=34px><div id=c1>0</div></td>'
  ' <td width=100%><img id=c2 src="facesmile.gif"></td>'
  ' <td width=34px><div id=c3>0</div></td>'
  '</tr></table></div>'
  '<div id=wBrd>'
  '<script>'
  '  for(y=0;y<DY;y++) for(x=0;x<DX;x++) document.write('
  '    "<span id=x"+((y+1)*(DX+2)+x+1)+" style=\"left:"'
  '    +(10+SZ*x)+"px;top:"+(52+SZ*y)+"px;\"></span>")'
  '</script>'
  '</div>'
  '<div><a id=btnSwitch href="SAPEVENT:switch?0">'
  'switch to ABAP</a>'
  '</div></div>'
  '<a id=callback style="display:none"'
  '  href="SAPEVENT:click?dummy">SAPEVENT:click</a>'
  '</body>'
  '</html>'


    INTO html_str SEPARATED BY '~'.

  ENDIF.

  CONDENSE html_str.



  " >> patch html with game parameters
  DATA: xstr(4) TYPE c, ystr(4) TYPE c.
  WRITE x_size TO xstr NO-GROUPING.
  WRITE y_size TO ystr NO-GROUPING.

  CONCATENATE 'DX=' xstr ',DY=' ystr ',BB="' b_left '";' INTO s.

  REPLACE FIRST OCCURRENCE OF
   '/*VARIABLES_INITIALIZATION_HERE_DONT_DELETE*/'
   IN html_str WITH s.

  IF sy-subrc <> 0.
    MESSAGE e000(su) WITH 'html template is broken'.
  ENDIF.

  "  >> performance improvement: condense html to width 255,
  "         to reduce whitespaces sent to client

  SPLIT html_str AT '~' INTO TABLE table1.

  DATA: ofs TYPE i, len TYPE i, nex TYPE i.

  REFRESH html.
  ofs = 0.
  LOOP AT table1.
    len = STRLEN( table1 ).
    CHECK len > 0.
    nex = ofs + len.

    IF nex < 255.
      html+ofs(len) = table1.
      ofs = nex.
    ELSE.
      APPEND html.
      html = table1.
      ofs = len.
    ENDIF.
  ENDLOOP.
  APPEND html.

ENDFORM.                    "html_create

*&---------------------------------------------------------------------*
*&      Form  load_graphics
*&---------------------------------------------------------------------*
*       create GIF-images from scratch
*----------------------------------------------------------------------*
FORM html_load_gifs.


  PERFORM html_load_gif USING 'open0.gif'
       'R0lGODlhEAAQAIAAAHt7e729vSH5BAAAAAAALAAAAAAQABAAA'
       'AIdhI9pwe0PnnRxzmphlniz7oGbmJGWeXmU2qAcyxQAOw=='
       '' '' '' ''.

  PERFORM html_load_gif USING 'open1.gif'
       'R0lGODlhEAAQAJEAAAAA/3t7e729vQAAACH5BAAAAAAALAAAA'
       'AAQABAAAAIpjI9pwu0fnnRRAiCruxg+3lEbmFlX+Z1eGjZaw6'
       'EMGLsjLU7Tq9v9UwAAOw==' '' '' ''.

  PERFORM html_load_gif USING 'open2.gif'
       'R0lGODlhEAAQAJEAAAB7AHt7e729vQAAACH5BAAAAAAALAAAA'
       'AAQABAAAAItjI9pwu0fnnSRgYsvtbm3ijkhU02jUIon+ngbt3'
       '4wMJFzR9sCnsm1lPrphI0CADs=' '' '' ''.

  PERFORM html_load_gif USING 'open3.gif'
       'R0lGODlhEAAQAJEAAHt7e729vf8AAAAAACH5BAAAAAAALAAAA'
       'AAQABAAAAIshI9pwe0PnnQxiIsxZbmLVk0aE0pjUFrd5niseI'
       'ETF5O0V6O3K89S6tMFHQUAOw==' '' '' ''.

  PERFORM html_load_gif USING 'open4.gif'
       'R0lGODlhEAAQAJEAAAAAe3t7e729vQAAACH5BAAAAAAALAAAA'
       'AAQABAAAAIujI9pwu0fnnSxgSsuoE5n3FTfNnKMV4anxoJC1b'
       'bqhDLiU79Tau/5vZsFTcNGAQA7' '' '' ''.

  PERFORM html_load_gif USING 'open5.gif'
       'R0lGODlhEAAQAJEAAHsAAHt7e729vQAAACH5BAAAAAAALAAAA'
       'AAQABAAAAIpjI9pwu0fnnRRgItzq7mDzWATaF0jw3kmqYro6Q'
       'rVFKcte5MntUO9UwAAOw==' '' '' ''.

  PERFORM html_load_gif USING 'open6.gif'
       'R0lGODlhEAAQAJEAAAB7e3t7e729vQAAACH5BAAAAAAALAAAA'
       'AAQABAAAAIsjI9pwu0fnnSRgYsvtTlvgU1NFYoC2ZUMmmorBz'
       'gqK7sn3I5NG+sm9AMGGwUAOw==' '' '' ''.

  PERFORM html_load_gif USING 'open7.gif'
       'R0lGODlhEAAQAJEAAAAAAHt7e729vQAAACH5BAAAAAAALAAAA'
       'AAQABAAAAIqjI9pwu0fnnRRgItzq7mDPTEYGI5MJZlneVGTuq'
       'at+8CxYwtoSPO9zygAADs=' '' '' ''.

  PERFORM html_load_gif USING 'open8.gif'
       'R0lGODlhEAAQAIAAAHt7e729vSH5BAAAAAAALAAAAAAQABAAA'
       'AIphI9pwe0PnnSRqdXqPdliXwXaJ37hRmVXWoZt96onuFpywk'
       '6Sq8O9UwAAOw==' '' '' ''.

  PERFORM html_load_gif USING 'blank.gif'
       'R0lGODlhEAAQAJEAAHt7e729vf///wAAACH5BAAAAAAALAAAA'
       'AAQABAAAAIqlI8ZyRdggpxUAiiqfnjXG3kTmIlWZ3KhSaZqya'
       'LxKrYpyF36ruf8DygAADs=' '' '' ''.

  PERFORM html_load_gif USING 'bombdeath.gif'
       'R0lGODlhEAAQAJEAAAAAAHt7e/8AAP///yH5BAAAAAAALAAAA'
       'AAQABAAAAI0jI9pwu0fHgNSREnlFRR4zzUb933O5g1DmVlNup'
       'YiydbuVIMMmrdjfnrRQL5KK4ipjCqOAgA7' '' '' ''.

  PERFORM html_load_gif USING 'bombflagged.gif'
       'R0lGODlhEAAQAKIAAAAAAHt7e729vf8AAP///wAAAAAAAAAAA'
       'CH5BAAAAAAALAAAAAAQABAAAAM8SLrc0nCJoIS92AZK8hjZVl'
       'nfF3JkCWJil5osisFXmwnAOWJ5vOOAoM8VLBY1MqMR+bsxJ5u'
       'oVAqdWjcJADs='  '' ''.

  PERFORM html_load_gif USING 'bombmisflagged.gif'
       'R0lGODlhEAAQAKIAAAAAAHt7e729vf8AAP///wAAAAAAAAAAA'
       'CH5BAAAAAAALAAAAAAQABAAAANEGLrcKjDKGSYEVtQxJI6cBo'
       'VAWQqhOA5mmaoCwBEuG1WXzHInVLU6Vgtm4gg/RJ0SiVsVOzf'
       'QsRZFQWNSn9UjCTUzkwQAOw==' '' ''.

  PERFORM html_load_gif USING 'bombrevealed.gif'
       'R0lGODlhEAAQAJEAAAAAAHt7e729vf///yH5BAAAAAAALAAAA'
       'AAQABAAAAI0jI9pwu0fHgNSREnlFRR4zzUb933O5g1DmVlNup'
       'YiydbuVIMMmrdjfnrRQL5KK4ipjCqOAgA7' '' '' ''.

  PERFORM html_load_gif USING 'facedead.gif'
       'R0lGODlhGgAaAKIAAAAAAHt7e729vf//AP///wAAAAAAAAAAA'
       'CH5BAAAAAAALAAAAAAaABoAAAOAGLrcziKQSau9M0rMr95CKI'
       '4kyWRlWp6ECrxvypbvYNvxOI/A7eO6BSrU+/0Aop2g2CsOmsA'
       'PiHhz4qqhnRN63UpRVuPx21qKz0jtWZwWlsOwmq+tGG6PWLKI'
       'yY4qzWtPSW4kYXNBdWU8cEiIUzRxMoQqlFlCUg+ZDZianZydm'
       'gkAOw=='.

  PERFORM html_load_gif USING 'facesmile.gif'
       'R0lGODlhGgAaAKIAAAAAAHt7e729vf//AP///wAAAAAAAAAAA'
       'CH5BAAAAAAALAAAAAAaABoAAAN/GLrcziKQSau9M0rMr95CKI'
       '4kyWRlWp6ECrxvypbvYNvxOI/A7eO6BSrU+/0Aop2gaDyGlMw'
       'aLvoUtpY+6UC7/YCwzSZyxwxnvaiyGUi+qXFu9BW8PcblojKM'
       'i8Tn111VCkNEZn2CXzxqOUlWLnsyjiqTiC0Pl5hemJsBmpyYC'
       'QA7'.

  PERFORM html_load_gif USING 'facesmile.gif'
       'R0lGODlhGgAaAKIAAAAAAHt7e729vf//AP///wAAAAAAAAAAA'
       'CH5BAAAAAAALAAAAAAaABoAAAN/GLrcziKQSau9M0rMr95CKI'
       '4kyWRlWp6ECrxvypbvYNvxOI/A7eO6BSrU+/0Aop2gaDyGlMw'
       'aLvoUtpY+6UC7/YCwzSZyxwxnvaiyGUi+qXFu9BW8PcblojKM'
       'i8Tn111VCkNEZn2CXzxqOUlWLnsyjiqTiC0Pl5hemJsBmpyYC'
       'QA7'.

  PERFORM html_load_gif USING 'facewin.gif'
       'R0lGODlhGgAaAKIAAAAAAHt7AHt7e729vf//AP///wAAAAAAA'
       'CH5BAAAAAAALAAAAAAaABoAAAOEKLrczkOUSau9M0rMr95DKI'
       '4kyWRlWp6FCrxvypYvYdvxOI/A7eO6BSrU+/0Aot2gaDyGlEW'
       'YtEZAfkBLnLS6rV5RvTCMWwt/W8tigMoNaM/Ephy5Y8p9dCE6'
       'izverFB4XUBwInZNVoWGd4mKhoc5SXouUjKTKphPQlcPnQ2cn'
       'qGgoZ4JADs='.
ENDFORM.                    "html_load_gifs

*&---------------------------------------------------------------------*
*&      Form  create_gif
*&---------------------------------------------------------------------*
FORM  html_load_gif USING
        image_name TYPE c
        s1 TYPE c
        s2 TYPE c
        s3 TYPE c
        s4 TYPE c
        s5 TYPE c
        s6 TYPE c.

  DATA: gif_size  TYPE i,
        gif_base64 TYPE string,
        gif_binary TYPE xstring,
        gif_binary_table TYPE TABLE OF w3mime.

  CONCATENATE s1 s2 s3 s4 s5 s6 INTO gif_base64.

  CALL FUNCTION 'SSFC_BASE64_DECODE'
    EXPORTING
      b64data = gif_base64
    IMPORTING
      bindata = gif_binary
    EXCEPTIONS
      OTHERS  = 1.
  CHECK sy-subrc EQ 0.

  PERFORM xstring_to_table
     TABLES     gif_binary_table
     USING      gif_binary
     CHANGING   gif_size.

  CALL METHOD html_control->load_data
    EXPORTING
      url                  = image_name
      type                 = 'image'
      subtype              = 'gif'
      size                 = gif_size
    CHANGING
      data_table           = gif_binary_table
    EXCEPTIONS
      dp_invalid_parameter = 1
      dp_error_general     = 2
      cntl_error           = 3
      OTHERS               = 4.
ENDFORM.                    "html_load_gif


*---------------------------------------------------------------------*
*       FORM XSTRING_TO_TABLE                                         *
*---------------------------------------------------------------------*
*       convert xstring to xtable[255]
*---------------------------------------------------------------------*
FORM xstring_to_table
    TABLES    table1
    USING     buffer TYPE  xstring
    CHANGING  binary_size TYPE i.

  DATA: rows TYPE i, pos TYPE i.
  FIELD-SYMBOLS:   <fs> TYPE x.

  ASSIGN COMPONENT 0 OF STRUCTURE table1 TO <fs> TYPE 'X'.
  binary_size = XSTRLEN( buffer ).
  rows = ( binary_size + 255 - 1 ) DIV 255.
  DO rows TIMES.
    <fs> = buffer+pos.
    pos = pos + 255.
    APPEND table1.
  ENDDO.
ENDFORM.                    "xstring_to_table


*&---------------------------------------------------------------------*
*&      Form  html_show
*&---------------------------------------------------------------------*
FORM html_show.
  DATA: doc_url(80),
        html TYPE TABLE OF w3html INITIAL SIZE 150.

  PERFORM html_create TABLES html.

  CALL METHOD html_control->load_data(
     IMPORTING  assigned_url = doc_url
     CHANGING   data_table  = html
      EXCEPTIONS
       dp_invalid_parameter = 1
       dp_error_general     = 2
       cntl_error           = 3
       OTHERS               = 4
   ).

  CALL METHOD html_control->show_url( url = doc_url ).

ENDFORM.                                                    "html_show






*---------------------------------------------------------------------*
*       FORM high_scores_read                                         *
*---------------------------------------------------------------------*
FORM high_scores_read.
  REFRESH high_scores.
  IMPORT lines = high_scores[] FROM DATABASE indx(st) ID database_id.
ENDFORM.                    "high_scores_read


*---------------------------------------------------------------------*
*       FORM high_scores_show                                         *
*---------------------------------------------------------------------*
FORM high_scores_show.
  DATA: s(6) TYPE c, line TYPE c.
  FIELD-SYMBOLS: <fs1> TYPE c, <fs2> TYPE c.

  DO 9 TIMES.
    line = sy-index.
    CONCATENATE 'hs2_' line INTO s.
    ASSIGN (s) TO <fs1>.
    CONCATENATE 'hs3_' line INTO s.
    ASSIGN (s) TO <fs2>.
    READ TABLE high_scores INDEX sy-index.
    IF sy-subrc EQ 0.
      <fs1> = high_scores-user.
      <fs2> = high_scores-time.
    ELSE.
      CLEAR: <fs1>, <fs2>.
    ENDIF.
  ENDDO.
ENDFORM.                    "high_scores_show



*---------------------------------------------------------------------*
*       FORM high_scores_update                                       *
*---------------------------------------------------------------------*
FORM high_scores_update.

  high_scores-user = sy-uname.
  WRITE game_time TO high_scores-time RIGHT-JUSTIFIED.

  INSERT high_scores INTO TABLE high_scores[].

  LOOP AT high_scores FROM 10.
    DELETE high_scores INDEX sy-tabix.
  ENDLOOP.

  EXPORT lines = high_scores[] TO DATABASE indx(st) ID database_id.
ENDFORM.                    "high_scores_update
