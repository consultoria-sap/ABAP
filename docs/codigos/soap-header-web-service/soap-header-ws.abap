REPORT  ztest.

START-OF-SELECTION.

*armar el consumo del WS
  " Objeto proxy
  DATA:
        lv_ref_ws            TYPE REF TO zws_seguridad,
        lv_ref_ws2          TYPE REF TO zws_ordc,
        interface             TYPE REF TO zws_ordc,
        ws_header         TYPE REF TO if_wsprotocol_ws_header,
        lr_xml_element   TYPE REF TO if_ixml_element,
        lr_name               TYPE string,
        lr_namespace     TYPE string,
        ai_application_fault  TYPE REF TO cx_ai_application_fault,
        ai_system_fault        TYPE REF TO cx_ai_system_fault.

*  *armado XML
            DATA:           ixml TYPE REF TO if_ixml,
                xml_document TYPE REF TO if_ixml_document,
                          xml_root TYPE REF TO if_ixml_element,
                    xml_element TYPE REF TO if_ixml_element,
                         xml_node TYPE REF TO if_ixml_node,
                           l_xstring TYPE xstring,
                           l_string TYPE string.


  " Faltas
  DATA:
        lv_sysexcfault    TYPE REF TO cx_ai_system_fault,      "Falta de sistema
        lv_appexcfault    TYPE REF TO cx_ai_application_fault, "Falta de la aplicacion externa
        lv_cxroot            TYPE REF TO cx_root,
        gv_message      TYPE    c LENGTH 255,
*el  segundo servicio
        p_zin                TYPE    zp_ws_seguridad,
        gwa_out           TYPE   zrespon1,
       lv_login             TYPE zpasvalauth_req,
       lv_token            TYPE string,
       system_fault     TYPE REF TO cx_ai_system_fault,
      light_not_found TYPE REF TO cx_sxidag_flight_not_found,
        p_ord              TYPE zvalordcomguardar_orden_compr2,
        wa_out           TYPE zvalordcomguardar_orden_compr1.


  MOVE:
  'Test' TO p_zin-parameters-auth_req-username,
  '12345' TO p_zin-parameters-auth_req-password.


  TRY.
    "Crea el proxy
    CREATE OBJECT lv_ref_ws
      EXPORTING
        logical_port_name = 'ZPL_UNO'.


    TRY.
        "Envia petición
        CALL METHOD lv_ref_ws->validar_usuario
          EXPORTING
            validar_usuario          = p_zin
          IMPORTING
            validar_usuario_response = gwa_out.

      CATCH cx_ai_system_fault      INTO lv_sysexcfault.

        gv_message = lv_sysexcfault->get_text( ).

      CATCH cx_ai_application_fault INTO lv_appexcfault.
        gv_message = lv_appexcfault->get_text( ).

        CONCATENATE 'ERROR' gv_message INTO gv_message. "Error app ext:

    ENDTRY.
*    CATCH cx_ai_system_fault INTO lv_sysexcfault.

*      gv_message = lv_sysexcfault->get_text( ).

    IF gv_message IS INITIAL.

      CLEAR lv_token.
      MOVE
        gwa_out-parameters-auth_resp-token TO lv_token.


      TRY.
        "Crea el proxy 2
        CREATE OBJECT lv_ref_ws2
          EXPORTING
            logical_port_name = 'ZPL_DOS'.

        TRY.
* create instance
          CREATE OBJECT interface.
* get ws_header protocol
          ws_header ?= lv_ref_ws2->get_protocol( if_wsprotocol=>ws_header ).

*armar el XML
          SET EXTENDED CHECK OFF.
          CONCATENATE
            '<SOAP-ENV:Header>'
            '<eb:MessageHeader eb:version="1.0" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '
            ' xmlns:eb="http://www.ebxml.org/namespaces/messageHeader" '
            '  xmlns:xsd="http://www.w3.org/1999/XMLSchema"> '
            ' <eb:ConversationId>NULL</eb:ConversationId> '
            ' <eb:From>'
            ' <eb:PartyId type="urn:x12.org:IO5:01">99999</eb:PartyId> '
            '   </eb:From> '
            ' <eb:To> '
            ' <eb:PartyId type="urn:x12.org:IO5:01">123123</eb:PartyId> '
            '   </eb:To> '
            ' <eb:CPAId>IPCC</eb:CPAId> '
            ' <eb:Service eb:type="OTA">SabreCommand</eb:Service> '
            ' <eb:Action>SabreCommandLLSRQ</eb:Action> '
            ' <eb:MessageData> '
            ' <eb:MessageId>mid:20001209-133003-2333@ clientofsabre.com< /eb:MessageId> '
            ' <eb:Timestamp>2001-02-15T11:15:12Z</eb:Timestamp>  '
            ' <eb:TimeToLive>2001-02-15T11:15:12Z</eb:TimeToLive> '
            '     </eb:MessageData> '
            '   </eb:MessageHeader> '
            '   <wsse:Security xmlns:wsse="http://schemas.xmlsoap.org/ws/2002/12/secext" '
            '     xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/12/utility"> '
            '     <wsse:UsernameToken>' lv_token '</wsse:UsernameToken>'
            '       <wsse:Username>TEST</wsse:Username> '
            '       <wsse:Password>12345</wsse:Password> '
            '       <Organization>NM9A</Organization> '
            '       <Domain>DEFAULT</Domain> '
            '   </wsse:Security> '
            ' </SOAP-ENV:Header> '
            INTO l_string.
          SET EXTENDED CHECK ON.

*          * convert to xstring
          l_xstring = cl_proxy_service=>cstring2xstring( l_string ).

          IF NOT l_string IS INITIAL.
* create ixml dom document from xml xstring
            CALL FUNCTION 'SDIXML_XML_TO_DOM'
              EXPORTING
                xml           = l_xstring
              IMPORTING
                document      = xml_document
              EXCEPTIONS
                invalid_input = 1
                OTHERS        = 2.

*              IF sy-subrc = 0 AND NOT xml_document IS INITIAL.
            xml_root = xml_document->get_root_element( ).
            xml_element ?= xml_root->get_first_child( ).
* agregar header
            WHILE NOT xml_element IS INITIAL.
              lr_name = xml_element->get_name( ).
              lr_namespace = xml_element->get_namespace_uri( ).
              ws_header->set_request_header(
              name = lr_name
              namespace = lr_namespace
              dom = xml_element ).
              xml_element ?= xml_element->get_next( ).
            ENDWHILE.
*              ENDIF.
          ENDIF.


*pasar datos para ir al segundo WS, con la finalidad que marque un error diferente al del *token
          MOVE:
          '4600107862' TO p_ord-parameters-orden_compra_req-numero_orden,
          'IH07' TO p_ord-parameters-orden_compra_req-empresa_code,
          'F' TO p_ord-parameters-orden_compra_req-tipo_doc,
          'ZF' TO p_ord-parameters-orden_compra_req-material_doc,
          '0' TO p_ord-parameters-orden_compra_req-delete_ind ,
          '9' TO p_ord-parameters-orden_compra_req-estado,
          '2019-07-01' TO p_ord-parameters-orden_compra_req-fecha_orden,
          '200059' TO p_ord-parameters-orden_compra_req-num_proveedor,
          'PPD' TO p_ord-parameters-orden_compra_req-metodo_pago,
          '99' TO p_ord-parameters-orden_compra_req-forma_pago,
          'G03' TO p_ord-parameters-orden_compra_req-uso_cfdi,
          'MXN' TO p_ord-parameters-orden_compra_req-moneda,
          ' ' TO p_ord-parameters-orden_compra_req-pdf,
          ' ' TO p_ord-parameters-orden_compra_req-indicador_anticipo,
          '0' TO p_ord-parameters-orden_compra_req-importe_anticipo.

          TRY.
              "Envia petición
              CALL METHOD lv_ref_ws2->guardar_orden_compra
                EXPORTING
                  guardar_orden_compra          = p_ord
                IMPORTING
                  guardar_orden_compra_response = wa_out.

            CATCH cx_ai_system_fault      INTO lv_sysexcfault.

              gv_message = lv_sysexcfault->get_text( ).

            CATCH cx_ai_application_fault INTO lv_appexcfault.
              gv_message = lv_appexcfault->get_text( ).

              CONCATENATE 'ERROR' gv_message INTO gv_message. "Error app ext:

          ENDTRY.

        ENDTRY.

      ENDTRY.

    ELSE.

      EXIT.
    ENDIF.

  ENDTRY.
