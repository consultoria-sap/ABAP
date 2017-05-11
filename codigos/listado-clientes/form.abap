*&---------------------------------------------------------------------*
*&      Form  
*& http://foros.consultoria-sap.com/t/creacion-de-un-listado-de-clientes/13891/12
*&---------------------------------------------------------------------*

form datos.

  select name1 ort01 stcd1
           into (kna1-name1, kna1-ort01, kna1-stcd1)
           from kna1
           where kunnr = knvp-kunnr.

    select single pernr
             into knvp-pernr
             from knvp
            where kunnr = knvp-kunnr
             and parvw = 've'.


    if sy-subrc ne 0.
      clear knvp-pernr.
    endif.
    vkgrp = knvp-pernr.
    select single pernr
            into pa0001-pernr
            from pa0001
            where pernr = knvp-pernr.

    select vkbur vkgrp pltyp
           into (knvv-vkbur, knvv-vkgrp, knvv-pltyp)
           from knvv
           where vkbur eq knvv-vkbur
            and vkgrp eq knvv-vkgrp.
            listado-name1 = kna1-name1.
            listado-ort01 = kna1-ort01.
            listado-stcd1 = kna1-stcd1.
            listado-pernr = knvp-pernr.
            listado-parvw = 've'.
            listado-kunnr = knvp-kunnr.
            listado-vkbur = knvv-vkbur.
            listado-vkgrp = knvv-vkgrp.
            listado-pltyp = knvv-pltyp.
            append listado.
            clear listado.
         endselect.
        endselect.
  perform campos_alv.
  perform ordenar_alv.
  perform layout.
  perform alv_report.
endform.
