DATA: itab TYPE STANDARD TABLE OF zempleados_ap329,
      wa_emp TYPE zempleados_ap329,
      gv_reg TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK id.
    PARAMETERS: pa_id TYPE i DEFAULT gv_reg.
    SELECTION-SCREEN END OF BLOCK id.
    SELECTION-SCREEN BEGIN OF BLOCK balta WITH FRAME TITLE text-002.
    PARAMETERS:
    pa_nom  TYPE znombre_ap00329    MODIF ID b1,
    pa_ape1 TYPE zapellido1_ap00329 MODIF ID b1,
    pa_ape2 TYPE zapellido2_ap00329 MODIF ID b1,
    pa_dni  TYPE zdni_ap00329       MODIF ID b1 OBLIGATORY,
    pa_tel  TYPE asld2tel           MODIF ID b1,
    pa_dpto TYPE zdpto_ap00329      MODIF ID b1.
*Introducir otro parametro con fecha de alta.
    SELECTION-SCREEN END OF BLOCK balta.

    wa_emp-id           = gv_reg.
    wa_emp-nombre       = pa_nom.
    wa_emp-apellido1    = pa_ape1.
    wa_emp-apellido2    = pa_ape2.
    wa_emp-dni          = pa_dni.
    wa_emp-telefono     = pa_tel.
    wa_emp-departamento = pa_dpto.

INITIALIZATION.
  SELECT * FROM zempleados_ap329
  INTO TABLE itab.
*Número de registros en la tabla -> ID
  IF sy-subrc EQ 0.
    DESCRIBE TABLE itab LINES gv_reg.
  ENDIF.
  pa_id  = gv_reg + 1.

    TRY.
          IF wa_emp-id IS NOT INITIAL.
            IF sy-subrc EQ 0.
              INSERT zempleados_ap329 FROM wa_emp.
              IF sy-subrc EQ 0.
                FORMAT COLOR COL_POSITIVE INVERSE ON.
                WRITE: / 'Registro insertado correctamente.',
                       / wa_emp-id,
                       / wa_emp-nombre,
                       / wa_emp-apellido1,
                       / wa_emp-apellido2,
                       / wa_emp-dni,
                       / wa_emp-telefono.
              ELSE.
                FORMAT COLOR COL_NEGATIVE INVERSE ON.
                WRITE: / 'Error al insertar registro'.
              ENDIF.
            ENDIF.
          ELSE.
            WRITE: / 'No se ha indicado el identificador de usuario.'.
          ENDIF.
      CATCH cx_root.
    ENDTRY.
