**Crear servicio
  TRY.
      CREATE OBJECT service_senasa
        EXPORTING
          logical_port_name = 'ZSENASA_PF2CO_IWEB_SERVICE_SEN'.
    CATCH cx_ai_system_fault INTO cx_root.
      text = cx_root->get_text( ).
  ENDTRY.

**************************************************
*              H-E-A-D-E-R  X-M-L                *
**************************************************
**Agregar datos del Header obligatorios para SENASA
  protocolo ?= service_senasa->get_protocol( if_wsprotocol=>ws_header ).

  CONCATENATE
*           '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
             '<soap:Header>'
*           '<soapenv:Header>'
               '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
                 '<wsse:UsernameToken wsu:Id="UsernameToken-3" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                   '<wsse:Username>testwservice</wsse:Username>'
                   '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">testwservicepsw</wsse:Password>'
*                    '<wsse:Username>7798181710001</wsse:Username>'
*                    '<wsse:Password>TRAZA123</wsse:Password>'
*                    '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">TRAZA123</wsse:Password>'
                 '</wsse:UsernameToken>'
               '</wsse:Security>'
             '</soap:Header>'
*            '</soap:Envelope>'
*             '<soapenv:Header>'
  INTO lv_string.

*Convertir a XSTRING
  lv_xstring = cl_proxy_service=>cstring2xstring( lv_string ).

  IF lv_string IS NOT INITIAL.

    CALL FUNCTION 'SDIXML_XML_TO_DOM'
      EXPORTING
        xml           = lv_xstring
      IMPORTING
        document      = xml_document
      EXCEPTIONS
        invalid_input = 1
        OTHERS        = 2.
    IF sy-subrc EQ 0 AND xml_document IS NOT INITIAL.
      xml_root = xml_document->get_root_element( ).
      xml_element ?= xml_root->get_first_child( ).

      WHILE xml_element IS NOT INITIAL.
        CLEAR: name, namespace.
        name = xml_element->get_name( ).
        namespace = xml_element->get_namespace_uri( ).
        protocolo->set_request_header( name = name namespace = namespace dom = xml_element ).
        xml_element ?= xml_element->get_next( ).
      ENDWHILE.
    ENDIF.
  ENDIF.

**************************************************
*                B-O-D-Y  X-M-L                  *
**************************************************
**Asignar datos que seran enviados a SENASA
  request-parameters-arg0 = gt_ztrans_senasa.
  request-parameters-arg1 = '7798181710001'.
  request-parameters-arg2 = 'AGRO2020'.
*  request-parameters-arg1 = '7798192290004'.
*  request-parameters-arg2 = 'GGezP.99'.
*  request-parameters-arg1 = '7798181710001'.
*  request-parameters-arg2 = 'TRAZA123'.
*  request-parameters-arg1 = 'senasaws'.
*  request-parameters-arg2 = 'Clave2013'.

**************************************************
*           S-A-V-E   T-R-A-N-S-A-C-T-I-O-N      *
**************************************************
**Consumir Web Services de SENASA
  TRY.
      CALL METHOD service_senasa->save_transacciones
        EXPORTING
          save_transacciones          = request
        IMPORTING
          save_transacciones_response = p_ge_response.
*      IF ge_response-parameters-return-resultado IS INITIAL.
*        p_wa_error_flag = 'X'.
*        p_gw_error_response = ge_response-parameters-return-errores.
*      ENDIF.
    CATCH cx_ai_system_fault INTO cx_root.
      text = cx_root->get_text( ).
    CATCH cx_ai_application_fault INTO cx_root.
      text = cx_root->get_text( ).
  ENDTRY.
