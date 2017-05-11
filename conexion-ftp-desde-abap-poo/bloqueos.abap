*&---------------------------------------------------------------------*
*& Report  ZPRB1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zprb1.

DATA: seqg3 TYPE STANDARD TABLE OF seqg3,
      seqg4 TYPE HASHED TABLE OF seqg3 WITH UNIQUE KEY gname garg gmode,
      resul TYPE c,
      user TYPE seqg3-guname,
      table TYPE c LENGTH 20.

PARAMETERS: consec TYPE zhr_conssat-conse.

START-OF-SELECTION.

  CALL FUNCTION 'ENQUEUE_EZCONSAT'
    EXPORTING
      mode_zhr_conssat = 'S'
      mandt            = sy-mandt
      conse            = consec.

*CALL FUNCTION 'DEQUEUE_EZCONSAT'
*  EXPORTING
*    mode_zhr_conssat = 'S'
*    mandt            = sy-mandt
*    conse            = consec.


  CALL FUNCTION 'ENQUE_READ'
    EXPORTING
      gclient = sy-mandt
      guname  = sy-uname
    TABLES
      enq     = seqg3.

  seqg4 = seqg3.

  table = 'ZHR_CONSSAT'.
  PERFORM ver_bloq USING consec table
                 CHANGING resul user.

  DATA: lgart TYPE zhr_conssat-lgart.
  IF resul NE 'X'.
    SELECT SINGLE lgart
      INTO (lgart)
      FROM zhr_conssat
      WHERE conse = '001'.
    WRITE: lgart.
  ELSE.
    MESSAGE s121(cd) WITH 'El consecutivo' consec 'esta siendo utilizado por' user.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  VER_BLOQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEQ  text
*----------------------------------------------------------------------*
FORM ver_bloq USING  p_consec p_table
      CHANGING p_resul p_user.
  DATA: p_garg TYPE seqg3-garg,
        info TYPE seqg3.
  CLEAR p_resul.

  CONCATENATE sy-mandt p_consec INTO p_garg.
  READ TABLE seqg4 INTO info
                    WITH TABLE KEY gname = p_table
                                   garg = p_garg
                                   gmode = 'S'.
  p_user = info-guname.
  IF sy-subrc EQ 0.
    p_resul = 'X'.
  ENDIF.

ENDFORM.                    " VER_SEQ

