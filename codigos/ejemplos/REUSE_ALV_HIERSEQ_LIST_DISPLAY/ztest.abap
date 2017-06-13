report ZTEST message-id id.
 
*---------------------------------------------------------------------*
*          Type pools
*---------------------------------------------------------------------*
type-pools : slis.
*---------------------------------------------------------------------*
*          Tables
*---------------------------------------------------------------------*
tables: t616u ,
        vbpa  ,
        vbap  ,
        vbak  ,
        mara  ,
        t005t ,
        t604t .
*---------------------------------------------------------------------*
*          Internal Tables
*---------------------------------------------------------------------*
* To store first line contents of report
data : begin of it_output occurs 0,
         vbeln      like vbap-vbeln,           " Sales order number
         posnr      like vbap-posnr,           " Sales order line
         matnr      like vbap-matnr,           " Material Number
         arktx      like vbap-arktx,           " Description of material
         herkl      like vbap-zzherkl,         " Country of origin
         landx      like t005t-landx,          " Country Description
         stawn      like vbap-zzstawn,         " HTS Commodity code
         text1      like t604t-text1,          " HTS Description
         check,                                " Check box for selection
         line_color(4),                        " Line color
         vbpos(17),                            " Key for Hier List
       end of it_output.
* To store second line contents of report
data: begin of it_output2 occurs 0,
         herkl      like vbap-zzherkl,         " Country of origin
         stawn      like vbap-zzstawn,         " HTS Commodity code
         vbpos(17),                            " Key for Hier List
      end of it_output2.
* Internal table to store details of sales order
data : begin of it_material occurs 0,
         vbeln      like vbap-vbeln,           " Sales order number
         posnr      like vbap-posnr,           " Sales order line
         matnr      like vbap-matnr,           " Material Number
         werks      like vbap-werks,           " Plant
         arktx      like vbap-arktx,           " Description of material
         herkl      like vbap-zzherkl,         " Country of origin
         stawn      like vbap-zzstawn,         " HTS Commodity code
       end of it_material.
* Internal table to store error messages
data : begin of it_errmsgs occurs 0,
         vbeln       like vbap-vbeln,           " Sales order number
         posnr       like vbap-posnr,           " Sales order line
         message(100) type c,                   " Error Message
       end of it_errmsgs.
 
* WORKING STORAGE FOR BAPI INTERFACE
data: begin of it_bapiparex occurs 0.
        include structure bapiparex.                        "1710
data: end of it_bapiparex.
 
data: begin of it_bape.
data: structure like bapiparex-structure.                   "len 30
        include structure bape_vbap.                        "len 261
data:       filler(1419) type c.                            "len 1419
data: end of it_bape.
 
data: begin of it_bapex.
data: structure like bapiparex-structure.                   "len 30
        include structure bape_vbapx.                       "len 22
data:       filler(1658) type c.
data: end of it_bapex.
 
*Internal Tables to capture BapirETURN messages
data: it_bapireturn1 like bapiret2 occurs 0 with header line,
      it_bapireturn2 like bapiret2 occurs 0 with header line.
 
data: x_orderitemx like bapisdh1x.
data: v_export type c.
data: begin of itmupd occurs 0.
        include structure bapisditmx.
data: end of itmupd.
data: begin of itmfld occurs 0.
        include structure bapisditm.
data: end of itmfld.
* Internal table for field catalog
data : it_fieldcat type slis_t_fieldcat_alv with header line,
* Internal table for Events
       it_events   type slis_t_event with header line.
*---------------------------------------------------------------------*
*         Global Variables
*---------------------------------------------------------------------*
data:    v_tabix         like  sy-tabix,          " Line index
         v_repid         like  sy-repid,          " Program name
         x_layout        type  slis_layout_alv,   " Output layout
         v_herkl(6),
         v_stawn(34).
*---------------------------------------------------------------------*
*          Selection Screen
*---------------------------------------------------------------------*
selection-screen : begin of block blk1
                       with frame title text-001. " Geography-Receipt
select-options :
* Country
 s_land1 for  vbpa-land1,
* Ship-to-Party
 s_kunnr for  vbpa-kunnr.
 
selection-screen  : end of block blk1.
 
 
selection-screen  : begin of block blk2
                        with frame title text-002 . " Geography-Export
select-options :
* Sales Organization
 s_vkorg    for vbak-vkorg,
* Shipping Point / Receiving Point
 s_vstel    for vbap-vstel,
* Plant
 s_werks    for vbap-werks.
 
selection-screen  : end of block blk2.
 
 
selection-screen  : begin of block blk3
                        with frame title text-003." Further Doc.Data
select-options :
* Created on
s_erdat    for vbak-erdat.
 
 
selection-screen :begin of line.
*-Sales document Radiobutton - Select-Option
parameters : r_select  radiobutton group grp1 .
selection-screen comment 4(25) text-015 for field r_select.
*-Select Option for Sales Order
select-options : s_vbeln  for vbap-vbeln.
selection-screen :end of line.
 
selection-screen :begin of line.
*-Sales document Radiobutton - Parameter
parameters : r_parmtr  radiobutton group grp1 .
selection-screen comment 4(28) text-015 for field r_parmtr.
parameters: p_vbeln like vbak-vbeln.
selection-screen :end of line.
 
selection-screen :begin of line.
*-Item
selection-screen comment 3(26) text-016 for field s_posnr.
select-options: s_posnr for vbap-posnr.
selection-screen :end of line.
 
 
select-options :
* Created By
s_ernam    for vbak-ernam,
* Sales Order Type
s_auart    for vbak-auart,
* Material
s_matnr    for vbap-matnr,
* Material Group
s_matkl    for vbap-matkl.
 
selection-screen  : end of block blk3.
 
 
selection-screen begin of block blk4 with frame .
*To Display error record only
parameters p_errors as checkbox .
 
selection-screen end of block blk4.
*---------------------------------------------------------------------*
*          Start of Selection
*---------------------------------------------------------------------*
start-of-selection.
* Selecting data depending on selection criteria
  perform select_data.
 
*---------------------------------------------------------------------*
*          End of Selection
*---------------------------------------------------------------------*
end-of-selection.
*Display report output
  perform display_output.
 
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*        Select data based on selection criteria
*----------------------------------------------------------------------*
form select_data.
*Refresh & clear internal tables before populating data
  refresh : it_output ,
            it_output2,
            it_material.
  clear   : it_output,
            it_material,
            it_output2.
*Fetching data from VBAP
*-Sales Order - Select-Option
  if r_select = 'X'.            
    select vbap~vbeln
           vbap~posnr
           vbap~matnr
           vbap~werks
           vbap~arktx
           vbap~zzherkl
           vbap~zzstawn into table it_material
           from vbap
           inner join vbak
           on vbap~vbeln = vbak~vbeln
           where vbak~vkorg in s_vkorg
           and   vbap~vstel in s_vstel
           and   vbap~werks in s_werks
           and   vbak~erdat in s_erdat
           and   vbak~vbeln in s_vbeln
           and   vbak~ernam in s_ernam
           and   vbak~auart in s_auart
           and   vbap~matnr in s_matnr
           and   vbap~matkl in s_matkl.
*-Sales Order - Parameter & Item - Select-Option
  elseif r_parmtr = 'X'.           
    select vbap~vbeln
           vbap~posnr
           vbap~matnr
           vbap~werks
           vbap~arktx
           vbap~zzherkl
           vbap~zzstawn into table it_material
           from vbap
           inner join vbak
           on vbap~vbeln = vbak~vbeln
           where vbak~vkorg in s_vkorg
           and   vbap~vstel in s_vstel
           and   vbap~werks in s_werks
           and   vbak~erdat in s_erdat
           and   vbak~vbeln  = p_vbeln
           and   vbak~ernam in s_ernam
           and   vbak~auart in s_auart
           and   vbap~posnr in s_posnr
           and   vbap~matnr in s_matnr
           and   vbap~matkl in s_matkl.
  endif.          
* If sy-subrc is not equal to zero exit
  if sy-subrc <> 0 .
    exit.
  endif.
* Else Excluding records
  loop at it_material.
    v_tabix = sy-tabix.
    select single kunnr
                from vbpa
                into vbpa-vbeln
                where vbeln = it_material-vbeln  and
                      posnr = it_material-posnr  and
                      parvw = 'WE'               and
                      kunnr in s_kunnr           and
                      land1 in s_land1.
    if sy-subrc <> 0.
      select single kunnr
                  from vbpa
                  into vbpa-vbeln
                  where vbeln = it_material-vbeln    and
                        posnr = '000000'             and
                        parvw = 'WE'                 and
                        kunnr in s_kunnr             and
                        land1 in s_land1.
      if sy-subrc <> 0.
        delete it_material index v_tabix.
        continue.
      endif.
    endif.
* Delete recods that are not export relevant.
    call function 'Z_DETER_EXPORT_REL'
         exporting
              salesorder = it_material-vbeln
              lineitem   = it_material-posnr
         importing
              flag       = v_export.
    if v_export = ' '.
      delete it_material index v_tabix.
      continue.
    endif.
* Populating IT_OUTPUT from IT_MATERIAL.
    move-corresponding it_material to it_output.
 
*Populating SecondLine In the Output
    select single herkl
                  stawn
                  from marc
                  into (it_output2-herkl,
                       it_output2-stawn)
                  where matnr = it_material-matnr and
                        werks = it_material-werks .
    if sy-subrc  = 0.
      shift it_material-vbeln left deleting leading '0'.
      concatenate it_material-vbeln
                  it_material-posnr
             into it_output2-vbpos
             separated by '/'.
      append it_output2.
    endif.
* If Errors Only Check Box is checked.
    if p_errors = 'X'.
      clear : v_herkl, v_stawn.
      concatenate : it_output2-herkl it_material-herkl into v_herkl,
                    it_output2-stawn it_material-stawn into v_stawn.
      condense : v_herkl, v_stawn.
      if v_herkl is initial or v_stawn is initial.  
      else.
        delete it_material index v_tabix.
        continue.
      endif.
    endif.
* Country Description
    select single landx
                  from t005t
                  into it_output-landx
                  where spras = 'EN'  and
                  land1 = it_material-herkl.
* HTS Description
    select single text1
                  from t604t
                  into it_output-text1
                  where spras = 'EN'  and
                  land1 = it_material-herkl and
                  stawn = it_material-stawn.
*VBELN/POSNR
    shift it_material-vbeln left deleting leading '0'.
    concatenate it_material-vbeln
                it_material-posnr
           into it_output-vbpos
           separated by '/'.
    append it_output.
    clear it_output.
  endloop.
endform.                    " SELECT_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*        Display Report
*----------------------------------------------------------------------*
form display_output.
 
  data : l_pf_formname   type slis_formname value 'PF_STATUS',
         l_user_formname type slis_formname value 'USER_COMMAND',
         keyinfo type slis_keyinfo_alv.
 
  v_repid = sy-repid.
* populate fieldcatalog
  perform build_fieldcatalog.
* Populate events internal table
  perform build_events.
* Layout initialization.
  perform layout using x_layout.
  x_layout-info_fieldname    = 'LINE_COLOR'.
* Specifying KeyFields for List.
  keyinfo-header01 = 'VBPOS'.
  keyinfo-item01   = 'VBPOS'.
  call function 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
       exporting
            i_callback_program       = v_repid
            i_callback_pf_status_set = l_pf_formname
            i_callback_user_command  = l_user_formname
            is_layout                = x_layout
            it_fieldcat              = it_fieldcat[]
            it_events                = it_events[]
            i_tabname_header         = 'IT_OUTPUT'
            i_tabname_item           = 'IT_OUTPUT2'
            is_keyinfo               = keyinfo
       tables
            t_outtab_header          = it_output
            t_outtab_item            = it_output2
       exceptions
            program_error            = 1
            others                   = 2.
endform.                    " DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  TOP-OF-LIST
*&---------------------------------------------------------------------*
*        For Top of list
*----------------------------------------------------------------------*
form top-of-list.
* Display Steelcase header
  call function 'Z_HEADER'.
endform.                    " TOP-OF-LIST
 
 
*---------------------------------------------------------------------*
*       FORM LAYOUT                                                   *
*---------------------------------------------------------------------*
form layout using l_layout type slis_layout_alv.
  l_layout-box_fieldname      = 'CHECK'.
  l_layout-box_tabname        = 'IT_OUTPUT'.
  l_layout-colwidth_optimize  = 'X'.
endform.
*---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*      Processing User command
*----------------------------------------------------------------------*
*      -->P_UCOMM     Screens, function code triggered by PAI
*      -->P_SELFIELD  information cursor position ALV
*----------------------------------------------------------------------*
form user_command using    p_ucomm    like sy-ucomm
                            p_selfield type slis_selfield.
 
  data : l_index like sy-tabix.
  l_index = p_selfield-tabindex.
  case p_ucomm.
    when 'SAVE'.
      perform validate_input.
      perform save_sales_docu.
      p_selfield-refresh = 'X'.
*Display Messages
      if it_errmsgs[] is initial.
        message s899 with 'Record(s) Successfully Updated'.
      else.
        perform display_errors.
      endif.
    when '&IC1'.
* On Double click display the sales order.
      read table it_output index l_index.
      set parameter  id 'AUN' field it_output-vbeln.
      call transaction 'VA03' and skip first screen.
  endcase.
endform.                    " USER_COMMAND
*---------------------------------------------------------------------*
*       FORM pf_status                                                *
*---------------------------------------------------------------------*
*       Set pf status
*----------------------------------------------------------------------*
*  -->  p_extab    excluding Fcode table
*---------------------------------------------------------------------*
form pf_status using    p_extab type slis_t_extab.
  data : l_extab type slis_extab.
  set pf-status 'STANDARD' excluding p_extab.
endform.                    " PF_STATUS_SET
 
*&---------------------------------------------------------------------*
*&      Form  SAVE_SALES_DOCU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_sales_docu.
  data v_tabix like sy-tabix.
  refresh   it_errmsgs.
  clear     it_errmsgs.
*Setting the flag field as update
  x_orderitemx-updateflag = 'U'.
  loop at it_output.
    v_tabix = sy-tabix.
    refresh : it_bapireturn1,
              it_bapireturn2,
              it_bapiparex,
              itmfld,
              itmupd.
    clear   : it_bapireturn1,
              it_bapireturn2,
              it_bapiparex,
              itmfld,
              itmupd,
              it_bape,
              it_bapex.
    if it_output-check = ' '.
      continue.
    endif.
* if the sales order is checked populate IT_BAPIREX.
    it_bape-structure = 'BAPE_VBAP'.
    it_bape-vbeln     = it_output-vbeln.
    it_bape-posnr     = it_output-posnr.
    it_bape-zzherkl   = it_output-herkl.
    it_bape-zzstawn   = it_output-stawn.
    append it_bape to it_bapiparex.
 
    it_bapex-structure = 'BAPE_VBAPX'.
    it_bapex-vbeln     = it_output-vbeln.
    it_bapex-posnr     = it_output-posnr.
    it_bapex-zzherkl   = 'X'.
    it_bapex-zzstawn   = 'X'.
    append it_bapex to it_bapiparex.
 
    itmfld-itm_number = it_output-posnr.
    append itmfld.
    itmupd-itm_number = it_output-posnr.
    itmupd-updateflag = 'U'.
    append itmupd.
 
    call function 'BAPI_SALESORDER_CHANGE'
         exporting
              salesdocument    = it_output-vbeln
              order_header_inx = x_orderitemx
         tables
              return           = it_bapireturn1
              order_item_in    = itmfld
              order_item_inx   = itmupd
              extensionin      = it_bapiparex.
*Store the error messages in internal table
    loop at it_bapireturn1 where type = 'E'.
      it_errmsgs-vbeln = it_output-vbeln.
      it_errmsgs-posnr = it_output-posnr.
      it_errmsgs-message = it_bapireturn1-message.
      append it_errmsgs.
      clear it_errmsgs.
      it_output-line_color = 'C600'.
    endloop.
*Commit the bapi transaction if no error messages are there.
    if sy-subrc <> 0.
      refresh it_bapireturn2.
      clear it_bapireturn2.
      call function 'BAPI_TRANSACTION_COMMIT'
           exporting
                wait   = 'X'
           importing
                return = it_bapireturn2.
*If commit is not succesful capture the error messages.
      if  not it_bapireturn2 is  initial.
        it_errmsgs-vbeln = it_output-vbeln.
        it_errmsgs-posnr = it_output-posnr.
        it_errmsgs-message = it_bapireturn2-message.
        append it_errmsgs.
        clear it_errmsgs.
        it_output-line_color = 'C600'.
      else.
*If salesOrder is updated refresh the data from the database.
        it_output-line_color = ' '.
        select single zzherkl
                      zzstawn
              from vbap
              into (it_output-herkl ,
                    it_output-stawn)
              where vbeln = it_output-vbeln and
                    posnr = it_output-posnr.
      endif.
    endif.
* Make the checkboxes unchecked after updating the salesorder.
    it_output-check = ' '.
    modify it_output index v_tabix.
  endloop.
endform.                    " SAVE_SALES_DOCU
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_INPUT
*&---------------------------------------------------------------------*
*      To Validate Input Fields
*----------------------------------------------------------------------*
form validate_input.
  loop at it_output.
    v_tabix = sy-tabix.
* check if the Country of origin exists.
    if not it_output-herkl is initial.
      select single landx
                    from t005t
                    into t005t-landx
                    where spras = 'EN' and
                          land1 = it_output-herkl.
      if sy-subrc <> 0.
        message e899 with it_output-herkl text-011 .
        exit.
      endif.
* Move country description to display field
      move t005t-landx to it_output-landx.
    else.
      move space to it_output-landx.
    endif.
* check if the Commodity code exists.
    if not it_output-stawn is initial.
      select single text1
                    from t604t
                    into t604t-text1
                    where spras = 'EN' and
                          land1 = it_output-herkl and
                          stawn = it_output-stawn.
      if sy-subrc <> 0.
        message e899 with it_output-stawn text-012 .
        exit.
      endif.
* Move commodity description to display field
      move t604t-text1 to it_output-text1.
    else .
      move space to it_output-text1.
    endif.
    modify it_output index v_tabix.
  endloop.
endform.                    " VALIDATE_INPUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ERRORS
*&---------------------------------------------------------------------*
*       Display PopUp Messages
*----------------------------------------------------------------------*
form display_errors.
*variables
  data : l_pos(1) type n value 1. " Field pos
* Fieldcatalog for popup
  data : it_fieldcat_pop type slis_t_fieldcat_alv with header line.
* Sales Order #
  it_fieldcat_pop-fieldname         = 'VBELN'.
  it_fieldcat_pop-tabname           = 'IT_ERRMSGS'.
  it_fieldcat_pop-col_pos           = l_pos.
  it_fieldcat_pop-seltext_m         = 'Sales Order# '.
  it_fieldcat_pop-ddictxt           = 'M'.
  it_fieldcat_pop-outputlen         = 10.
  it_fieldcat_pop-no_zero           = 'X'.
  append it_fieldcat_pop.
  clear  it_fieldcat_pop.
  l_pos                              = l_pos + 1.
* Message
  it_fieldcat_pop-fieldname         = 'MESSAGE'.
  it_fieldcat_pop-tabname           = 'IT_ERRMSGS'.
  it_fieldcat_pop-col_pos           = l_pos.
  it_fieldcat_pop-seltext_m         = 'Message'.
  it_fieldcat_pop-ddictxt           = 'M'.
  it_fieldcat_pop-outputlen         = 255.
  it_fieldcat_pop-no_zero           = 'X'.
  append it_fieldcat_pop.
  clear  it_fieldcat_pop.
 
  call function 'REUSE_ALV_POPUP_TO_SELECT'
       exporting
            i_title       = 'Errors'
            i_tabname     = 'IT_ERRMSGS'
            it_fieldcat   = it_fieldcat_pop[]
       tables
            t_outtab      = it_errmsgs
       exceptions
            program_error = 1
            others        = 2.
endform.                    " DISPLAY_ERRORS
 
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*      Builds FieldCatalog
*----------------------------------------------------------------------*
form build_fieldcatalog.
  data : l_pos(2) type n value 1.
  refresh it_fieldcat.
  clear   it_fieldcat.
* Field Catalog for first line in Output.
* Order/Line
  it_fieldcat-fieldname = 'VBPOS'.
  it_fieldcat-tabname   = 'IT_OUTPUT'.
  it_fieldcat-col_pos   = l_pos.
  it_fieldcat-outputlen = 17.
  it_fieldcat-seltext_m =  text-013.   "Order/Line
  append it_fieldcat.
  clear  it_fieldcat.
  l_pos = l_pos + 1.
* Material#
  it_fieldcat-fieldname  = 'MATNR'.
  it_fieldcat-tabname   = 'IT_OUTPUT'.
  it_fieldcat-col_pos   = l_pos.
  it_fieldcat-outputlen = 18.
  it_fieldcat-seltext_m =  text-006.   "Material#
  append it_fieldcat.
  clear  it_fieldcat.
  l_pos = l_pos + 1.
* Material Desc
  it_fieldcat-fieldname   = 'ARKTX'.
  it_fieldcat-tabname   = 'IT_OUTPUT'.
  it_fieldcat-col_pos   = l_pos.
  it_fieldcat-outputlen = 40.
  it_fieldcat-seltext_m =  text-007.   "Material Desc
  append it_fieldcat.
  clear  it_fieldcat.
  l_pos = l_pos + 1.
* Cnty of Origin
  it_fieldcat-fieldname   = 'HERKL'.
  it_fieldcat-tabname   = 'IT_OUTPUT'.
  it_fieldcat-input     = 'X'.
  it_fieldcat-col_pos   = l_pos.
  it_fieldcat-outputlen =  3.
  it_fieldcat-seltext_m =  text-008.   "Cnty of Origin
  append it_fieldcat.
  clear  it_fieldcat.
  l_pos = l_pos + 1.
* Country Description
  it_fieldcat-fieldname   = 'LANDX'.
  it_fieldcat-tabname   = 'IT_OUTPUT'.
  it_fieldcat-col_pos   = l_pos.
  it_fieldcat-outputlen = 15.
  it_fieldcat-seltext_m =  text-009.   "Description
  append it_fieldcat.
  clear  it_fieldcat.
  l_pos = l_pos + 1.
* HTS Code
  it_fieldcat-fieldname   = 'STAWN'.
  it_fieldcat-tabname   = 'IT_OUTPUT'.
  it_fieldcat-input     = 'X'.
  it_fieldcat-col_pos   = l_pos.
  it_fieldcat-outputlen = 17.
  it_fieldcat-seltext_m =  text-010.   "HTS Code
  append it_fieldcat.
  clear  it_fieldcat.
  l_pos = l_pos + 1.
* HTS Description
  it_fieldcat-fieldname   = 'TEXT1'.
  it_fieldcat-tabname   = 'IT_OUTPUT'.
  it_fieldcat-col_pos   = l_pos.
  it_fieldcat-outputlen = 15.
  it_fieldcat-seltext_m =  text-009.   "Description
  append it_fieldcat.
  clear  it_fieldcat.
* Field Catalog for second line in Output.
* Cnty of Origin
  l_pos = 1.
  it_fieldcat-fieldname = 'HERKL'.
  it_fieldcat-tabname   = 'IT_OUTPUT2'.
  it_fieldcat-col_pos   = '1'.
  it_fieldcat-outputlen =  18.
  it_fieldcat-seltext_m =  text-014.   "Cnty of Origin
  append it_fieldcat.
  clear  it_fieldcat.
  l_pos = l_pos + 1.
* HTS Code
  it_fieldcat-fieldname = 'STAWN'.
  it_fieldcat-tabname   = 'IT_OUTPUT2'.
  it_fieldcat-col_pos   = '2'.
  it_fieldcat-outputlen = 17.
  it_fieldcat-seltext_m =  text-010.   "HTS Code
  append it_fieldcat.
  clear  it_fieldcat.
endform.                    " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_EVENTS
*&---------------------------------------------------------------------*
*       Populate Events Table
*----------------------------------------------------------------------*
form build_events.
  refresh it_events.
  clear   it_events.
*ADD Top of Page event.
  it_events-name = 'TOP_OF_PAGE'.
  it_events-form = 'TOP_OF_PAGE'.
  append it_events.
  clear  it_events.
*ADD Top of LIST event.
  it_events-name = 'TOP_OF_LIST'.
  it_events-form = 'TOP-OF-LIST'.
  append it_events.
  clear  it_events.
endform.                    " BUILD_EVENTS
