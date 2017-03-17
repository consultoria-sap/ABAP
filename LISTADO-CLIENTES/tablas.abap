*&---------------------------------------------------------------------*
*& http://foros.consultoria-sap.com/t/creacion-de-un-listado-de-clientes/13891/33
*&---------------------------------------------------------------------*

SELECT KUNNR VKBUR PLTYP VKGRP
   INTO (KNVV-KUNNR, KNVV-VKBUR, KNVV-PLTYP, KNVV-VKGRP)
    FROM KNVV
    WHERE VKBUR EQ VKBUR
      AND VKGRP EQ VKGRP.

    SELECT SINGLE PERNR
     INTO KNVP-PERNR
      FROM KNVP
       WHERE KUNNR EQ KNVV-KUNNR
        AND PARVW EQ 'VE'.

    IF SY-SUBRC NE 0.
      CLEAR KNVP-PERNR.
    ENDIF.

    SELECT SINGLE SNAME
      INTO PA0001-SNAME
      FROM PA0001
      WHERE PERNR EQ KNVP-PERNR.

    SELECT SINGLE NAME1 ORT01 STCD1
        INTO (KNA1-NAME1, KNA1-ORT01, KNA1-STCD1)
        FROM KNA1
        WHERE KUNNR EQ KNVV-KUNNR.
    ENDSELECT.
