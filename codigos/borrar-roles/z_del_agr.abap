REPORT  Z_DEL_AGR.

*--------------------------------------------------------------*
* Version valid from 4.5b - 7.00                               *
* Borrar roles de manera masiva                                *
*--------------------------------------------------------------*

TABLES :  AGR_DEFINE.
DATA: BEGIN OF ACTTAB OCCURS 0,
        AGR_NAME LIKE AGR_DEFINE-AGR_NAME,
      END OF ACTTAB.

SELECT-OPTIONS ACTGRP FOR AGR_DEFINE-AGR_NAME.
PARAMETERS: TEST(1) DEFAULT 'X'.

* F4 Hilfe für die Aktivitäsgruppe
AT SELECTION-SCREEN ON VALUE-REQUEST FOR ACTGRP-LOW.
  DATA: SELECTED_VALUE LIKE AGR_DEFINE-AGR_NAME.
  CALL FUNCTION 'PRGN_ACTIVITY_GROUPS_F4_HELP'
       IMPORTING
            SELECTED_VALUE             = SELECTED_VALUE
       EXCEPTIONS
            NO_ACTIVITY_GROUP_SELECTED = 1
            OTHERS                     = 2.
  IF SY-SUBRC = 0.
    ACTGRP-LOW = SELECTED_VALUE.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR ACTGRP-HIGH.
  DATA: SELECTED_VALUE LIKE AGR_DEFINE-AGR_NAME.
  CALL FUNCTION 'PRGN_ACTIVITY_GROUPS_F4_HELP'
       IMPORTING
            SELECTED_VALUE             = SELECTED_VALUE
       EXCEPTIONS
            NO_ACTIVITY_GROUP_SELECTED = 1
            OTHERS                     = 2.
  IF SY-SUBRC = 0.
    ACTGRP-HIGH = SELECTED_VALUE.
  ENDIF.
  START-OF-SELECTION.

  SELECT AGR_NAME FROM AGR_DEFINE
         INTO  CORRESPONDING FIELDS OF TABLE ACTTAB
         WHERE AGR_NAME IN ACTGRP.
 
 LOOP AT ACTTAB.
    CALL FUNCTION 'PRGN_AUTH_ACTIVITY_GROUP'
         EXPORTING
              ACTIVITY_GROUP   = ACTTAB-AGR_NAME
              ACTION_DELETE    = 'X'
*             MESSAGE_OUTPUT   = 'X'
         EXCEPTIONS
              NOT_AUTHORIZED   = 1
              OTHERS           = 2.

    IF SY-SUBRC EQ 0.
      IF TEST EQ SPACE.
        WRITE : / 'Delete : ', ACTTAB.
        CALL FUNCTION 'PRGN_ACTIVITY_GROUP_DELETE'
             EXPORTING
                  ACTIVITY_GROUP                = ACTTAB-AGR_NAME
                  show_dialog                   = ' '
                  ENQUEUE_AND_TRANSPORT         = 'X'
             EXCEPTIONS
                  NOT_AUTHORIZED                = 1
                  TRANSPORT_CHECK_PROBLEM       = 2
                  TRANSPORT_CANCELED_OR_PROBLEM = 3
                  ONE_OR_MORE_USERS_ENQUEUED    = 4
                  FOREIGN_LOCK                  = 5
                  USER_CANCELS_ACTION           = 6
                  OTHERS                        = 7.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ELSE.
        WRITE : / 'Test Delete : ', ACTTAB.
      ENDIF.
    ELSE.
      WRITE : / 'Missing authorization for :', ACTTAB-AGR_NAME.
    ENDIF.
  ENDLOOP.
