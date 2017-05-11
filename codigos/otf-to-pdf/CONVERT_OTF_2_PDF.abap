   CALL FUNCTION 'CONVERT_OTF_2_PDF'
      IMPORTING
        bin_filesize           = v_bin_filesize
      TABLES
        otf                    = st_job_output_info-otfdata
        doctab_archive         = it_docs
        lines                  = it_lines
      EXCEPTIONS
        err_conv_not_possible  = 1
        err_otf_mc_noendmarker = 2
        OTHERS                 = 3.

 CONCATENATE p_bsid'_' sy-datum '.pdf' INTO v_name.
    DATA: lc_filename TYPE string,
          lv_line     TYPE string.
    CLEAR: lc_filename, lv_line, wa_lines.
    CONCATENATE '\\RUTA\carpeta1\carpeta2' v_name
    INTO lc_filename.

    CONDENSE lc_filename NO-GAPS.
OPEN DATASET lc_filename  FOR OUTPUT IN BINARY MODE. "TEXT MODE ENCODING UTF-8.
LOOP AT it_lines INTO wa_lines.
  TRANSFER wa_lines-tdline TO lc_filename.
ENDLOOP.
CLOSE DATASET lc_filename.
