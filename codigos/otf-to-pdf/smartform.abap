    CALL FUNCTION lc_fname
      EXPORTING
        control_parameters   = st_control_parameters
        output_options       = st_output_options
        cantidad             = gst_grid-dividendo
        cant_texto           = cant_str
        cuotas               = cuotas
        vencimiento          = lc_fe_ven_s
        fecha_actual         = lc_feact_prt
        cli_nom1             = cli_nom1
        cli_cod1             = cli_cod1
        lines                = lc_lines_p
      IMPORTING
        document_output_info = st_document_output_info
        job_output_info      = st_job_output_info
        job_output_options   = st_job_output_options
      TABLES
        it_amortizacion      = git_grid.
