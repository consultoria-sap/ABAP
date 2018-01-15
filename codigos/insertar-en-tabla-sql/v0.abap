* Fuente: http://foros.consultoria-sap.com/t/insert-en-tabla-sql-sin-usar-wa-poo/22117 *
* Autor: Vlp89 *


METHOD clear_sql_cobemp.
    DATA: wa_cobemph LIKE ti_cobemph,
          v_fecha(23) TYPE c.
    
    EXEC SQL.
      OPEN DBCUR FOR
      SELECT    COBEMP_CI, COBEMP_FECHA_PAGO, COBEMP_NCOMP_PAGO,
                COBEMP_MONTO_PAGO, COBEMP_CONTROL, COBEMP_FECHA_REGISTRO
      FROM COBEMP
    ENDEXEC.

    DO.
      CLEAR: wa_cobemph.
      EXEC SQL.
        FETCH NEXT DBCUR INTO
          :WA_COBEMPH-CI,
          :WA_COBEMPH-FECHA_PAGO,
          :WA_COBEMPH-N_COMP_PAGO,
          :WA_COBEMPH-MONTO_PAGO,
          :WA_COBEMPH-CONTROL,
          :v_fecha
      ENDEXEC.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
      wa_cobemph-lapso = wa_cobemph-fecha_pago+0(4) && wa_cobemph-fecha_pago+5(2).
      wa_cobemph-fecha_registro = v_fecha+0(4) && v_fecha+5(2) && v_fecha+8(2).
      APPEND wa_cobemph TO ti_cobemph.
    ENDDO.

    LOOP AT ti_cobemph INTO wa_cobemph.
      EXEC SQL.
        INSERT INTO COBEMPH (cobemp_lapso, cobemp_ci, cobemp_fecha_pago, cobemp_ncomp_pago, cobemp_monto_pago, cobemp_control, cobemp_fecha_registro)
        VALUES (:wa_cobemph-lapso, :wa_cobemph-ci, :wa_cobemph-fecha_pago, :wa_cobemph-n_comp_pago, :wa_cobemph-monto_pago, :wa_cobemph-control, :wa_cobemph-fecha_registro)
      ENDEXEC.

      IF sy-subrc = 0.
        CLEAR wa_cobemph.
        EXEC SQL.
          DELETE COBEMP
        ENDEXEC.
        IF sy-subrc EQ 0.
          COMMIT WORK.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.
