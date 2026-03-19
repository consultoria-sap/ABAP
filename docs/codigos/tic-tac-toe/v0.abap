REPORT zgame.
TABLES sscrfields.
DATA: flag, count(10) TYPE c ,
      f1,f2,f3,f4,f5,f6,f7,f8,f9,
      p1(2) TYPE c,
      p2(2) TYPE c,
      player(2) TYPE c,
      ch TYPE c.
SELECTION-SCREEN BEGIN OF BLOCK rad1
WITH FRAME TITLE text-002 NO INTERVALS.
PARAMETERS message(10) TYPE c .
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN:
BEGIN OF LINE,
PUSHBUTTON 2(5) but1 USER-COMMAND cli1 MODIF ID sc1,
PUSHBUTTON 7(5) but2 USER-COMMAND cli2 MODIF ID sc2,
PUSHBUTTON 12(5) but3 USER-COMMAND cli3 MODIF ID sc3,
END OF LINE,
BEGIN OF LINE,
PUSHBUTTON 2(5) but4 USER-COMMAND cli4 MODIF ID sc4,
PUSHBUTTON 7(5) but5 USER-COMMAND cli5 MODIF ID sc5,
PUSHBUTTON 12(5) but6 USER-COMMAND cli6 MODIF ID sc6,
END OF LINE,
BEGIN OF LINE,
PUSHBUTTON 2(5) but7 USER-COMMAND cli7 MODIF ID sc7,
PUSHBUTTON 7(5) but8 USER-COMMAND cli8 MODIF ID sc8,
PUSHBUTTON 12(5) but9 USER-COMMAND cli9 MODIF ID sc9,
END OF LINE.
SELECTION-SCREEN END OF BLOCK rad1.
* DISPLAYING THE SCORE FILED AS A LABEL
*disanling process********************************
FORM box_disable USING ch.
  LOOP AT SCREEN.
    IF screen-group1 = ch.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM. "box_disable
 
AT SELECTION-SCREEN OUTPUT.
  IF f1 = 1.
    PERFORM box_disable USING 'SC1'.
  ENDIF.
  IF f2 = 1.
    PERFORM box_disable USING 'SC2'.
  ENDIF.
  IF f3 = 1.
    PERFORM box_disable USING 'SC3'.
  ENDIF.
  IF f4 = 1.
    PERFORM box_disable USING 'SC4'.
  ENDIF.
  IF f5 = 1.
    PERFORM box_disable USING 'SC5'.
  ENDIF.
  IF f6 = 1.
    PERFORM box_disable USING 'SC6'.
  ENDIF.
  IF f7 = 1.
    PERFORM box_disable USING 'SC7'.
  ENDIF.
  IF f8 = 1.
    PERFORM box_disable USING 'SC8'.
  ENDIF.
  IF f9 = 1.
    PERFORM box_disable USING 'SC9'.
  ENDIF.
 
AT SELECTION-SCREEN .
  CASE sscrfields.
    WHEN 'CLI1'.
      count = count + 1.
      PERFORM player_turn.
      but1 = p1.
      f1 = '1'.
      PERFORM computer_move.
    WHEN 'CLI2'.
      count = count + 1.
      PERFORM player_turn.
      but2 = p1.
      f2 = '1'.
      PERFORM computer_move.
    WHEN 'CLI3'.
      count = count + 1.
      PERFORM player_turn.
      but3 = p1.
      f3 = '1'.
      PERFORM computer_move.
    WHEN 'CLI4'.
      count = count + 1.
      PERFORM player_turn.
      but4 = p1.
      f4 = '1'.
      PERFORM computer_move.
    WHEN 'CLI5'.
      count = count + 1.
      PERFORM player_turn.
      but5 = p1.
      f5 = '1'.
      PERFORM computer_move.
    WHEN 'CLI6'.
      count = count + 1.
      PERFORM player_turn.
      but6 = p1.
      f6 = '1'.
      PERFORM computer_move.
    WHEN 'CLI7'.
      count = count + 1.
      PERFORM player_turn.
      but7 = p1.
      f7 = '1'.
      PERFORM computer_move.
    WHEN 'CLI8'.
      count = count + 1.
      PERFORM player_turn.
      but8 = p1.
      f8 = '1'.
      PERFORM computer_move.
    WHEN 'CLI9'.
      count = count + 1.
      PERFORM player_turn.
      but9 = p1.
      f9 = '1'.
      PERFORM computer_move.
  ENDCASE.
*this is for toggle operation p1 = X ; p2 = O ;
FORM player_turn.
  player = count MOD 2.
*BUT2 = player.
  IF player = 1.
*BUT4 = 'player1'.
    p1 = 'X'.
  ELSE.
*BUT4 = 'player2'.
    p1 = 'O'.
  ENDIF.
ENDFORM. "player_turn
*&---------------------------------------------------------------------*
*& Form computer_move
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM computer_move.
  IF count = 9.
    message = 'DRAW'.
    PERFORM reset.
  ENDIF.
  IF count = 7.
    PERFORM fourth_move.
  ENDIF.
  IF count = 5.
    PERFORM third_move.
  ENDIF.
  IF count = 3.
    PERFORM second_move.
  ENDIF.
  IF count = 1.
    PERFORM first_move.
  ENDIF.
  PERFORM who_wins.
ENDFORM. "computer_move
*computer - O
FORM first_move.
  IF but5 <> 'X'.
    but5 = 'O'.
  ELSE.
    but9 = 'O'.
  ENDIF.
  count = count + 1.
ENDFORM. "first_move
*&---------------------------------------------------------------------*
*& Form second_move
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM second_move.
  DATA str1 TYPE c.
  str1 = 'X'.
  PERFORM check_possible USING 'X'.
  IF count = 3.
    PERFORM misc_move.
  ENDIF.
  IF count = 3.
    PERFORM empty_fill.
  ENDIF.
ENDFORM. "second_move
*&---------------------------------------------------------------------*
*& Form check_possible
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* -->STR text
*----------------------------------------------------------------------*
FORM check_possible USING str TYPE c.
*checking for rows
*1st row --3rd col empty
  IF but1 = str AND but2 = str AND but3 = ' '.
    but3 = 'O'.
    count = count + 1.
  ENDIF.
*2ndrow
  IF but4 = str AND but5 = str AND but6 = ' '.
    but6 = 'O'.
    count = count + 1.
  ENDIF.
*3rd row
  IF but7 = str AND but8 = str AND but9 = ' '.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
*1st row --2nd col empty
  IF but1 = str AND but2 = ' ' AND but3 = str.
    but2 = 'O'.
    count = count + 1.
  ENDIF.
*2ndrow
  IF but4 = str AND but5 = ' ' AND but6 = str.
    but5 = 'O'.
    count = count + 1.
  ENDIF.
*3rd row
  IF but7 = str AND but8 = ' ' AND but9 = str.
    but8 = 'O'.
    count = count + 1.
  ENDIF.
*1st row --1st col empty
  IF but1 = ' ' AND but2 = str AND but3 = str.
    but1 = 'O'.
    count = count + 1.
  ENDIF.
*2ndrow
  IF but4 = ' ' AND but5 = str AND but6 = str.
    but4 = 'O'.
    count = count + 1.
  ENDIF.
*3rd row
  IF but7 = ' ' AND but8 = str AND but9 = str.
    but7 = 'O'.
    count = count + 1.
  ENDIF.
*check for columns
*1st col --3rd col empty
  IF but1 = str AND but4 = str AND but7 = ' '.
    but7 = 'O'.
    count = count + 1.
  ENDIF.
*2nd col
  IF but2 = str AND but5 = str AND but8 = ' '.
    but8 = 'O'.
    count = count + 1.
  ENDIF.
*3rd col
  IF but3 = str AND but6 = str AND but9 = ' '.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
*1st col --2nd col empty
  IF but1 = str AND but4 = ' ' AND but7 = str.
    but4 = 'O'.
    count = count + 1.
  ENDIF.
*2nd col
  IF but2 = str AND but5 = ' ' AND but8 = str.
    but5 = 'O'.
    count = count + 1.
  ENDIF.
*3rd col
  IF but3 = str AND but6 = ' ' AND but9 = str.
    but6 = 'O'.
    count = count + 1.
  ENDIF.
*1st col --1st col empty
  IF but1 = ' ' AND but4 = str AND but7 = str.
    but1 = 'O'.
    count = count + 1.
  ENDIF.
*2nd col
  IF but2 = ' ' AND but5 = str AND but8 = str.
    but2 = 'O'.
    count = count + 1.
  ENDIF.
*3rd col
  IF but3 = ' ' AND but6 = str AND but9 = str.
    but3 = 'O'.
    count = count + 1.
  ENDIF.
*diagonal
*left-top
  IF but1 = ' ' AND but5 = str AND but9 = str.
    but1 = 'O'.
    count = count + 1.
  ENDIF.
  IF but1 = str AND but5 = str AND but9 = ' '.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
*right-top
  IF but3 = ' ' AND but5 = str AND but7 = str.
    but3 = 'O'.
    count = count + 1.
  ENDIF.
  IF but3 = str AND but5 = str AND but7 = ' '.
    but7 = 'O'.
    count = count + 1.
  ENDIF.
ENDFORM. "check_possible
*&---------------------------------------------------------------------*
*& Form misc_move
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM misc_move.
  IF but6 = 'X' AND but8 = 'X'.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
  IF but1 = 'X' AND but9 = 'X'.
    but2 = 'O'.
    count = count + 1.
  ENDIF.
  IF but3 = 'X' AND but7 = 'X'.
    but2 = 'O'.
    count = count + 1.
  ENDIF.
  IF but1 = 'X' AND but5 = 'X'.
    but7 = 'O'.
    count = count + 1.
  ENDIF.
  IF but1 = 'X' AND but8 = 'X'.
    but7 = 'O'.
    count = count + 1.
  ENDIF.
  IF but3 = 'X' AND but8 = 'X'.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
  IF but6 = 'X' AND but7 = 'X'.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
  IF but4 = 'X' AND but6 = 'X'.
    but1 = 'O'.
    count = count + 1.
  ENDIF.
*----------------------------misc--last updated trial -error
  IF but2 = 'X' AND but8 = 'X'.
    but1 = 'O'.
    count = count + 1.
    EXIT .
  ENDIF.
  IF but2 = 'X' AND but7 = 'X'.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
  IF but2 = 'X' AND but9 = 'X'.
    but7 = 'O'.
    count = count + 1.
  ENDIF.
  IF but4 = 'X' AND but8 = 'X'.
    but1 = 'O'.
    count = count + 1.
  ENDIF.
  IF but1 = 'X' AND but6 = 'X'.
    but3 = 'O'.
    count = count + 1.
  ENDIF.
  IF but2 = 'X' AND but6 = 'X'.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
  IF but2 = 'X' AND but4 = 'X'.
    but3 = 'O'.
    count = count + 1.
  ENDIF.
  IF but4 = 'X' AND but9 = 'X'.
    but7 = 'O'.
    count = count + 1.
  ENDIF.
  IF but4 = 'X' AND but3 = 'X'.
    but1 = 'O'.
    count = count + 1.
  ENDIF.
ENDFORM. "misc_move
*&---------------------------------------------------------------------*
*& Form empty_fill
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM empty_fill.
  IF but1 <> 'X' AND but1 <> 'O'.
    but1 = 'O'.
    count = count + 1.
  ELSEIF but2 <> 'X' AND but2 <> 'O'.
    but2 = 'O'.
    count = count + 1.
  ELSEIF but3 <> 'X' AND but3 <> 'O'.
    but3 = 'O'.
    count = count + 1.
  ELSEIF but4 <> 'X' AND but4 <> 'O'.
    but4 = 'O'.
    count = count + 1.
  ELSEIF but5 <> 'X' AND but5 <> 'O'.
    but5 = 'O'.
    count = count + 1.
  ELSEIF but6 <> 'X' AND but6 <> 'O'.
    but6 = 'O'.
    count = count + 1.
  ELSEIF but7 <> 'X' AND but7 <> 'O'.
    but7 = 'O'.
    count = count + 1.
  ELSEIF but8 <> 'X' AND but8 <> 'O'.
    but8 = 'O'.
    count = count + 1.
  ELSEIF but9 <> 'X' AND but9 <> 'O'.
    but9 = 'O'.
    count = count + 1.
  ENDIF.
ENDFORM. "empty_fill
*&---------------------------------------------------------------------*
*& Form third_move
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM third_move.
  PERFORM check_possible USING 'O'.
  IF count = 5.
    PERFORM check_possible USING 'X'.
  ENDIF.
  IF count = 5.
    PERFORM empty_fill.
  ENDIF.
ENDFORM. "third_move
*&---------------------------------------------------------------------*
*& Form fourth_move
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM fourth_move.
  PERFORM check_possible USING 'O'.
  IF count = 7.
    PERFORM check_possible USING 'X'.
  ENDIF.
  IF count = 7.
    PERFORM empty_fill.
  ENDIF.
ENDFORM. "fourth_move
*check for win ,reset--------------------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Form check_x_win
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM check_x_win.
* checking of the rows
  DATA a TYPE i.
  IF but1 = 'X' AND but2 = 'X' AND but3 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
  IF but4 = 'X' AND but5 = 'X' AND but6 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
  IF but7 = 'X' AND but8 = 'X' AND but9 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
* checking of the cols
  IF but1 = 'X' AND but4 = 'X' AND but7 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
  IF but2 = 'X' AND but5 = 'X' AND but8 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
  IF but3 = 'X' AND but6 = 'X' AND but9 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
* checking for diagonal
  IF but1 = 'X' AND but5 = 'X' AND but9 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
  IF but3 = 'X' AND but5 = 'X' AND but7 = 'X'.
    message = ' X wins '.
    PERFORM reset.
  ENDIF.
ENDFORM. "check_x_win
*&---------------------------------------------------------------------*
*& Form check_o_win
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM check_o_win.
* checking of the rows
  IF but1 = 'O' AND but2 = 'O' AND but3 = 'O'.
    message = ' O wins '.
    PERFORM reset.
  ENDIF.
  IF but4 = 'O' AND but5 = 'O' AND but6 = 'O'.
    message = ' O wins '.
    PERFORM reset.
  ENDIF.
  IF but7 = 'O' AND but8 = 'O' AND but9 = 'O'.
    message = ' O wins '.
    PERFORM reset.
  ENDIF.
* checking of the cols
  IF but1 = 'O' AND but4 = 'O' AND but7 = 'O'.
    message = 'O wins '.
    PERFORM reset.
  ENDIF.
  IF but2 = 'O' AND but5 = 'O' AND but8 = 'O'.
    message = ' O wins '.
    PERFORM reset.
  ENDIF.
  IF but3 = 'O' AND but6 = 'O' AND but9 = 'O'.
    message = ' O wins '.
    PERFORM reset.
  ENDIF.
* checking for diagonal
  IF but1 = 'O' AND but5 = 'O' AND but9 = 'O'.
    message = ' O wins '.
    PERFORM reset.
  ENDIF.
  IF but3 = 'O' AND but5 = 'O' AND but7 = 'O'.
    message = ' O wins '.
    PERFORM reset.
  ENDIF.
ENDFORM. "check_o_win
*&---------------------------------------------------------------------*
*& Form who_wins
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM who_wins.
  PERFORM check_x_win.
  PERFORM check_o_win.
ENDFORM. "who_wins
*&---------------------------------------------------------------------*
*& Form reset
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM reset.
  but1 = ' '.
  but2 = ' '.
  but3 = ' '.
  but4 = ' '.
  but5 = ' '.
  but6 = ' '.
  but7 = ' '.
  but8 = ' '.
  but9 = ' '.
  f1 = ' '.
  f2 =' '.
  f3 = ' '.
  f4 =' '.
  f5 = ' '.
  f6 =' '.
  f7 = ' '.
  f8 =' '.
  f9 = ' '.
* Message = ' '.
* Score = ' '.
  count = 0.
ENDFORM. "reset
 
INITIALIZATION.
  count = 0.
  but1 = p1.
  but2 = p1.
  but3 = p1.
  but4 = p1.
  but5 = p1.
  but6 = p1.
  but7 = p1.
  but8 = p1.
  but9 = p1.
