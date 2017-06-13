report  zsree_po_alv no standard page heading line-size 220
                                           message-id zsree.
 
 
***********************************************************************
*              D A T A   D E C L A R A T I O N
***********************************************************************
 
***********************************************************************
*          T Y P E S   D E C L A R A T I O N
***********************************************************************
 
type-pools: slis.  " SAP standard type pools
 
types: begin of t_tab,
        vbeln type vbak-vbeln, " Sales and distribution document number
        erdat type vbak-erdat, " Date on which the record was created
        kunnr type vbak-kunnr, " Sold-to party 1
        vdatu type vbak-vdatu, " Requested delivery date
       end of t_tab.
 
types: begin of t_tab1,
        vbeln type vbap-vbeln,   " Sales and distribution
                                         " document number
        posnr type vbap-posnr,   " Sales document item
        matnr type vbap-matnr,   " Material number
        arktx type vbap-arktx,   " Short text for sales order item
        kwmeng type vbap-kwmeng, " Cumulative order quantity
                                              " in sales units
       end of t_tab1.
 
types: begin of t_tab2,
        bstkd type vbkd-bstkd, " Customer purchase order number
        vbeln type vbkd-vbeln, " Sales and distribution document number
       end of t_tab2.
 
types: begin of t_tab3,
        vbeln type vbep-vbeln, " Sales and distribution document number
        posnr type vbep-posnr, " Sales document item
        etenr type vbep-etenr, " Schedule line
        bddat type vbep-bddat, " Requirement date
                                   " (deadline for procurement)
        bmeng type vbep-bmeng, " Confirmed quantity
        vrkme type vbep-vrkme, " Sales unit
       end of t_tab3.
 
types: begin of t_tab4,
        kunnr type kna1-kunnr,  " Customer number
        name1 type kna1-name1,                              " Name
       end of t_tab4.
 
types: begin of t_tab5,
        vbeln type vbuk-vbeln,  " Sales and distribution document number
        lfgsk type vbuk-lfgsk,  " Overall delivery status for all items
       end of t_tab5.
 
types: begin of t_tab6,
        vbeln type vbup-vbeln, " Sales and distribution document number
        posnr type vbup-posnr, " Item number of the SD document
       end of t_tab6.
 
types: begin of t_tab8,
        vbeln type vbak-vbeln, " Sales and distribution document number
       end of t_tab8.
 
***********************************************************************
*               G L O B A L   V A R I A B L E S
***********************************************************************
 
data: v_repid          type sy-repid,  " Program name
*---  To store the internal table name
      v_tabname        type slis_tabname,
*---  Internal table to get PO catalog details
      it_fieldcat1     type slis_t_fieldcat_alv,
*---  Internal table to get SO catalog details
      it_fieldcat2     type slis_t_fieldcat_alv,
*---  Internal table to get SE catalog details
      it_fieldcat3     type slis_t_fieldcat_alv,
*---  Work area to change field catalog.
      wa_fieldcat1     type slis_fieldcat_alv,
*---  Internal table to get Events
      it_events        type slis_t_event,
*---  Internal table to get Events
      it_events1       type slis_t_event,
*---  Internal table to get Events
      it_events2       type slis_t_event,
*---  Work area for Events
      wa_events        type slis_alv_event,
*---  Work area for Layout
      wa_layout        type slis_layout_alv,
*---  Internal table for Keyinfo
      it_keyinfo       type slis_keyinfo_alv,
*---  To store the selected field value
      v_selfield_value type slis_selfield-value,
*---  To store the variant types
      i_variant        like disvariant,
*---  To store the hierarchical layout types
      i_variant1       like disvariant,
*---  To get the total lines of table IT_VBEP1
      v_linc type i.
 
 
***********************************************************************
*       V A R I A B L E S   F O R   S E L E C T -  O P T I O N S
***********************************************************************
 
data: v_auart  type vbak-auart,  " Sales document
      v_erdat  type vbak-erdat,  " Date on which the record was created
      v_ernam  type vbak-ernam,  " Name of person who created the object
      v_vkorg  type vbak-vkorg,  " Sales organization
      v_vtweg  type vbak-vtweg,  " Distribution channel
      v_spart  type vbak-spart,  " Division
      v_vbeln  type vbak-vbeln,  " Sales document
      v_bstkd  type vbkd-bstkd,  " Customer purchase order number
      v_kunnr  type vbak-kunnr,  " Customer number 1
      v_werks  type vbap-werks,  " Plant (own or external)
      v_lifsk  type vbak-lifsk,  " Delivery block
      v_lfgsk  type vbuk-lfgsk,  " Delivery block (Document Header)
      v_lfgsa  type vbup-lfgsa,  " Overall delivery status of the item
      v_spart1 type vbap-spart,  " Division
      v_prctr  type vbap-prctr.  " Profit Center
 
***********************************************************************
*              F L A G S   D E C L A R A T I O N
***********************************************************************
data: fg_error.        " Flag to check whether the data populated or not
 
***********************************************************************
*      I N T E R N A L   T A B L E S   D E C L A R A T I O N
***********************************************************************
 
*---Declaring Internal Table IT_VBAK Of type T_TAB
data: it_vbak type standard table of t_tab with header line.
 
*---Declaring Internal Table IT_VBAP Of type T_TAB1
data: it_vbap type standard table of t_tab1 with header line.
 
*---Declaring Internal Table IT_VBKD Of type T_TAB2
data: it_vbkd type standard table of t_tab2 with header line.
 
*---Declaring Internal Table IT_VBEP Of type T_TAB3
data: it_vbep type standard table of t_tab3 with header line.
 
*---Declaring Internal Table IT_VBEP1 Of Type T_TAB3
data: it_vbep1 type standard table of t_tab3 with header line.
 
*---Declaring Internal Table IT_KNA1 Of type T_TAB4
data: it_kna1 type standard table of t_tab4 with header line.
 
*---Declaring Internal Table IT_VBUK Of type T_TAB5
data: it_vbuk type standard table of t_tab5 with header line.
 
*---Declaring Internal Table IT_VBUP Of type T_TAB6
data: it_vbup type standard table of t_tab6 with header line.
 
*---Declaring Internal Table of type VBAK
data: it_vbak1 type standard table of t_tab8 with header line.
 
*---Declaring a final internal table which contains PO details
data: begin of it_final1 occurs 0,
        bstkd like vbkd-bstkd,  " Customer purchase order number
        kunnr like vbak-kunnr,  " Customer number
        name1 like kna1-name1,  " Name
        vdatu like vbak-vdatu,  " Requested delivery date
      end of it_final1.
 
*---Declaring a final internal table which contains SO details
data: begin of it_final2 occurs 0,
        vbeln like vbak-vbeln,  " Sales and distribution document number
        vdatu like vbak-vdatu,  " Requested delivery date
        erdat like vbak-erdat,  " Date on which the record was created
        lfgsk like vbuk-lfgsk,  " Overall delivery status for all items
        check,
      end of it_final2.
 
*---Declaring a final internal table which contains SE details
data: begin of it_final3 occurs 0,
        vbeln  like vbep-vbeln,  " Sales and distribution
                                           " document number
        posnr  like vbep-posnr,  " Sales document item
        etenr  like vbep-etenr,  " Schedule line
        matnr  like vbap-matnr,  " Material number
        arktx  like vbap-arktx,  " Short text for sales order item
        bddat  like vbep-bddat,  " Requirement date
                                   " (deadline for procurement)
        kwmeng like vbap-kwmeng, " Cumulative order quantity
                                   " in sales units
        bmeng  like vbep-bmeng,  " Confirmed quantity
      end of it_final3.
 
*---Declaring an internal table which contains SO details of selected PO
data: begin of it_final4 occurs 0,
        vbeln like vbak-vbeln,  " Sales and distribution
                                  " document number
        vdatu like vbak-vdatu,  " Requested delivery date
        erdat like vbak-erdat,  " Date on which the record was created
        lfgsk like vbuk-lfgsk,  " Overall delivery status for all items
        check,
      end of it_final4.
 
*---Declaring an internal table which contains SE details of selected PO
data: begin of it_final5 occurs 0,
        vbeln  like vbep-vbeln, " Sales and distribution
                                  " document number
        posnr  like vbep-posnr, " Item number of the SD document
        etenr  like vbep-etenr, " Schedule line
        matnr  like vbap-matnr, " Material number
        arktx  like vbap-arktx, " Short text for sales order item
        bddat  like vbep-bddat, " Requirement date
                                  " (deadline for procurement)
        kwmeng like vbap-kwmeng, " Cumulative order quantity in
                                   " sales unit
        bmeng  like vbep-bmeng, "  Confirmed quantity
      end of it_final5.
 
 
***********************************************************************
*                S E L E C T I O N    S C R E E N
***********************************************************************
 
*---Selection screen tab 1
selection-screen begin of block b1 with frame title text-001.
select-options:  s_auart for v_auart,  " Sales document type
                 s_erdat for v_erdat,  " Date on which the
                                              " record was created
                 s_ernam for v_ernam no intervals no-extension.
" Name of Person who Created the Object
selection-screen end of block b1.
 
*---Selection screen tab 2
selection-screen begin of block b2 with frame title text-002.
select-options:  s_vkorg for v_vkorg,  " Sales organization
                 s_vtweg for v_vtweg,  " Distribution channel
                 s_spart for v_spart.  " Division
selection-screen end of block b2.
 
*---Subscreen 1
selection-screen begin of screen 110 as subscreen.
selection-screen begin of block b3 with frame.
select-options:  s_vbeln for v_vbeln,  " Sales document
                 s_bstkd for v_bstkd,  " Customer purchase
                                                 " order number
                 s_kunnr for v_kunnr,  " Customer number
                 s_werks for v_werks,  " Plant (Own or External)
                 s_lifsk for v_lifsk.  " Delivery block
" (document header)
selection-screen end of block b3.
selection-screen end of screen 110.
 
*---Subscreen 2
selection-screen begin of screen 120 as subscreen.
selection-screen begin of block b4 with frame.
select-options:  s_lfgsk for v_lfgsk,  " Delivery block
                                               " (document header)
                 s_lfgsa for v_lfgsa,  " Overall delivery
                                               " status of the item
                 s_spart1 for v_spart1, " Division
                 s_prctr for v_prctr.  " Profit center
selection-screen end of block b4.
selection-screen end of screen 120.
 
*---Tab 3 for Selection screen
selection-screen: begin of tabbed block mytab for 7 lines,
                  tab (20) button1 user-command push1,
                  tab (20) button2 user-command push2,
                  end of block mytab.
 
*---Selection screen to choose the type of the list to be displayed
selection-screen begin of block b6 with frame title text-005.
selection-screen begin of line.
selection-screen comment 1(18) text-006 for field p_radio1.
parameters: p_radio1 radiobutton group g1 default 'X' user-command sree.
selection-screen comment 35(20) text-007 for field p_radio2.
parameters: p_radio2 radiobutton group g1.
selection-screen end of line.
selection-screen end of block b6.
 
*---Selection screen to choose the list typr from a variant
selection-screen begin of block b7 with frame title text-008.
parameters: p_var type disvariant-variant modif id abc.
selection-screen end of block b7.
 
***********************************************************************
*                I N I T I A L I Z A T I O N
***********************************************************************
 
initialization.
 
  perform initialization. " Initializes different fields
 
***********************************************************************
*            A T   S E L E C T I O N   S C R E E N
***********************************************************************
 
at selection-screen.
 
  perform at_selection_screen. " At selection screen validations
 
 
***********************************************************************
*       A T   S E L E C T I O N   S C R E E N   O U T P U T
***********************************************************************
 
at selection-screen output.
 
*---If radio button 1 is clicked disables the parameter P_VAR
  if p_radio1 = 'X'.
    loop at screen.
      check screen-group1 = 'ABC'.
      screen-active = 0.
      modify screen.
    endloop.
  endif.
 
***********************************************************************
* A T  S E L E C T I O N   S C R E E N   O N   V A L U E  R E Q U E S T
***********************************************************************
at selection-screen on value-request for p_var.
 
  perform f4_for_variant. " Gets the variant to select the layout
 
 
***********************************************************************
*             S T A R T   O F   S E L E C T I O N
***********************************************************************
 
start-of-selection.
 
  perform get_data. " Gets the data into the internal tables
  perform get_final_data. " Gets the final data to be displayed
 
  if it_vbkd[] is initial.  " If no data found gives an information msg
    message i003.
    fg_error = 'X'.
    stop.
  endif.
 
***********************************************************************
*             E N D   O F   S E L E C T I O N
***********************************************************************
end-of-selection.
 
  perform key_info. " Gets the header and item key info
 
  if not fg_error = 'X'.
 
    if p_radio1 = 'X'.
 
      perform get_events. " Gets the events
 
      v_tabname = 'IT_FINAL1'.
*---  Populates the field catalog for PO details using table IT_FINAL1
      perform fieldcatalog_merge1 using v_tabname
                                       it_fieldcat1.
*---  Modifies the field catalog for PO details
      perform modify_fldcat.
 
      v_tabname = 'IT_FINAL2'.
*---  Populates the field catalog for SO details using table IT_FINAL2
      perform fieldcatalog_merge1 using v_tabname
                                        it_fieldcat2.
      v_tabname = 'IT_FINAL3'.
*---  Populates the field catalog for SE details using table IT_FINAL3
      perform fieldcatalog_merge1 using v_tabname
                                        it_fieldcat2.
*---  Gets the User command and sets the pf-status
      perform alv_init.
 
*---  Modifies the layout into alternative colors
      wa_layout-zebra = 'X'.
 
      v_tabname = 'IT_FINAL1'.
*---  Populates the Blocked List info for PO details
      perform block_list using  wa_layout
                                it_fieldcat1
                                v_tabname
                                it_events.
*---  Gets the events for the Hierarchical list of SO and SE details
      perform get_events1.
 
*---  Modifies the field catalog for Hierarchical list
      perform modify_fieldcat_hirarchical.
 
*---  Appends the Hierarchical list to the Blocked list
      perform block_list_hs.
 
*---  Displays the Blocked list
      perform block_display.
 
    elseif p_radio2 = 'X'.
 
*---  Makes the hierarchical list in expand all mode
      wa_layout-expand_fieldname = 'CHECK'.
 
*---  Gets the events of the Hierarchical list
      perform get_events2.
 
      v_tabname = 'IT_FINAL2'.
*---  Populates the field catalog for SO details using table IT_FINAL2
      perform fieldcatalog_merge1 using v_tabname
                                        it_fieldcat2.
      v_tabname = 'IT_FINAL3'.
*---  Populates the field catalog for SE details using table IT_FINAL3
      perform fieldcatalog_merge1 using v_tabname
                                        it_fieldcat2.
*---  Modifies the field catalog for Hierarchical list
      perform modify_fieldcat_hirarchical.
 
*---  Displays SO and SE details in a Hierarchical list format
      perform hierarchical_display tables it_final2
                                          it_final3
                                   using  it_fieldcat2
                                          it_events2
                                          'IT_FINAL2'
                                          'IT_FINAL3'.
 
 
    endif.
 
  endif.
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       Initializes the selection screen
*----------------------------------------------------------------------*
form initialization .
 
  button1 = text-003.            " Button1 Text
  button2 = text-004.            " Button2 Text
  mytab-prog = sy-repid.         " Program Name
  mytab-dynnr = 110.             " Default Screen
  mytab-activetab = 'BUTTON1'.   " Default Tab
 
  perform variant_init.
 
endform.                    " INITIALIZATION
 
*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*   Chooses a particular screen when clicking on a particular button
*----------------------------------------------------------------------*
form at_selection_screen .
 
  case sy-ucomm.
    when 'PUSH1'.
      mytab-dynnr = 110.
      mytab-activetab = 'BUTTON1'.
    when 'PUSH2'.
      mytab-dynnr = 120.
      mytab-activetab = 'BUTTON2'.
  endcase.
 
endform.                    " AT_SELECTION_SCREEN
 
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Populates the Internal tables
*----------------------------------------------------------------------*
form get_data .
 
*---Selecting the VBELN from VBAK into a temporary table to reduce
*---                                             database access
  select vbeln " Sales and distribution document number
    from vbak
    into table it_vbak1
   where vbeln in s_vbeln
     and erdat in s_erdat
     and ernam in s_ernam
     and auart in s_auart
     and lifsk in s_lifsk
     and vkorg in s_vkorg
     and vtweg in s_vtweg
     and spart in s_spart
     and kunnr in s_kunnr.
 
*---Selecting VBELN POSNR ETENR BDDAT WMENG BMENG VRKME from VBEP Into
*---                                                             IT_VBEP
  if not it_vbak1[] is initial.
    select vbeln  " Sales and distribution document number
           posnr  " Sales document item
           etenr  " Schedule line
           bddat  " Requirement date (Deadline for procurement)
           bmeng  " Confirmed quantity
           vrkme  " Sales unit
      from vbep
        into table it_vbep
    for all entries in it_vbak1
     where vbeln = it_vbak1-vbeln.
  endif.
*---Selecting VBELN POSNR MATNR ARKTX from VBAP Into IT_VBAP
  if not it_vbep[] is initial.
    select vbeln  " Sales and distribution document number
           posnr  " Sales document item
           matnr  " Material number
           arktx  " Short text for sales order item
           kwmeng " Cumulative order quantity in sales units
      from vbap
      into table it_vbap
       for all entries in it_vbep
     where vbeln = it_vbep-vbeln
       and posnr = it_vbep-posnr
       and werks in s_werks
       and spart in s_spart1
       and prctr in s_prctr.
  endif.
 
*---Selecting VBELN POSNR from VBUP Into IT_VBUP
  if not it_vbap[] is initial.
    select vbeln  " Sales and distribution document number
           posnr  " Item number of the SD document
      from vbup
      into table it_vbup
       for all entries in it_vbap
     where vbeln = it_vbap-vbeln
       and posnr = it_vbap-posnr
       and lfgsa in s_lfgsa.
  endif.
 
*---Selecting VBELN ERDAT VDATU KUNNR from VBAK Into IT_VBAK
  if not it_vbup[] is initial.
    select vbeln
           erdat
           kunnr
           vdatu
      from vbak
      into table it_vbak
       for all entries in it_vbup
     where vbeln = it_vbup-vbeln
       and erdat in s_erdat
       and ernam in s_ernam
       and auart in s_auart
       and vkorg in s_vkorg
       and vtweg in s_vtweg
       and spart in s_spart
       and kunnr in s_kunnr
       and lifsk in s_lifsk.
    if sy-subrc = 0.
      sort it_vbak by vbeln descending.
    endif.
  endif.
 
*---Selecting VBELN LFGSK from VBUK Into IT_VBUK
  if not it_vbak[] is initial.
    select vbeln
           lfgsk
      from vbuk
      into table it_vbuk
       for all entries in it_vbak
     where vbeln = it_vbak-vbeln
       and lfgsk in s_lfgsk.
 
    select kunnr
           name1
      from kna1
      into table it_kna1
       for all entries in it_vbak
     where kunnr = it_vbak-kunnr.
  endif.
 
*---Selecting BSTKD VBELN from VBKD Into IT_VBKD
  if not it_vbuk[] is initial.
    select bstkd
           vbeln
      from vbkd
      into table it_vbkd
       for all entries in it_vbuk
     where vbeln = it_vbuk-vbeln
       and bstkd in s_bstkd.
    if sy-subrc = 0.
      sort it_vbkd by vbeln bstkd descending.
      delete adjacent duplicates from it_vbkd comparing vbeln.
      sort it_vbkd by bstkd descending.
    endif.
  endif.
 
endform.                    " GET_DATA
 
*&---------------------------------------------------------------------*
*&      Form  GET_FINAL_DATA
*&---------------------------------------------------------------------*
*    Populates the final data to be displayed into internal tables
*----------------------------------------------------------------------*
form get_final_data .
 
*---Moving the PO details into a final table IT_FINAL1
  data: lv_tabix type sy-tabix.
  loop at it_vbkd.
    at new bstkd.
      lv_tabix = sy-tabix.
      clear it_vbkd.
      read table it_vbkd index lv_tabix.
      if sy-subrc = 0.
        clear it_vbak.
        read table it_vbak with key vbeln = it_vbkd-vbeln.
        clear it_kna1.
        read table it_kna1 with key kunnr = it_vbak-kunnr.
        if sy-subrc = 0.
          it_final1-bstkd = it_vbkd-bstkd.
          it_final1-kunnr = it_vbak-kunnr.
          it_final1-name1 = it_kna1-name1.
          it_final1-vdatu = it_vbak-vdatu.
          append it_final1.
          clear it_final1.
        endif.
      endif.
    endat.
  endloop.
 
*---Moving the SO details into a final table IT_FINAL2
  loop at it_vbkd.
    loop at it_vbak where vbeln = it_vbkd-vbeln.
      clear it_vbuk.
      read table it_vbuk with key vbeln = it_vbak-vbeln.
      it_final2-vbeln = it_vbak-vbeln.
      it_final2-vdatu = it_vbak-vdatu.
      it_final2-erdat = it_vbak-erdat.
      it_final2-lfgsk = it_vbuk-lfgsk.
      it_final2-check = 'X'.
      append it_final2.
      clear it_final2.
    endloop.
  endloop.
 
*---Moving the SE details into a final table IT_FINAL3
  refresh it_vbep1.
  clear it_vbep1.
  loop at it_vbap.
    loop at it_vbep where vbeln = it_vbap-vbeln
                      and posnr = it_vbap-posnr.
      it_vbep1 = it_vbep.
      append it_vbep1.
      clear it_vbep1.
    endloop.
 
    describe table it_vbep1 lines v_linc.
    if v_linc = 1.
      clear it_vbep1.
      read table it_vbep1 index 1.
      it_final3-vbeln  = it_vbep-vbeln.
      it_final3-posnr  = it_vbep1-posnr.
      it_final3-etenr  = it_vbep1-etenr.
      it_final3-matnr  = it_vbap-matnr.
      it_final3-arktx  = it_vbap-arktx.
      it_final3-bddat  = it_vbep1-bddat.
      it_final3-kwmeng = it_vbap-kwmeng.
      it_final3-bmeng  = it_vbep1-bmeng.
      append it_final3.
      clear it_final3.
 
    else.
      loop at it_vbep1 where bmeng <> 0.
        it_final3-vbeln  = it_vbep-vbeln.
        it_final3-posnr  = it_vbep1-posnr.
        it_final3-etenr  = it_vbep1-etenr.
        it_final3-matnr  = it_vbap-matnr.
        it_final3-arktx  = it_vbap-arktx.
        it_final3-bddat  = it_vbep1-bddat.
        it_final3-kwmeng = it_vbap-kwmeng.
        it_final3-bmeng  = it_vbep1-bmeng.
        append it_final3.
        clear it_final3.
 
      endloop.
    endif.
    refresh it_vbep1.
    clear it_vbep1.
 
  endloop.
 
endform.                    " GET_FINAL_DATA
 
 
*&---------------------------------------------------------------------*
*&      Form  FIELDCATALOG_MERGE1
*&---------------------------------------------------------------------*
*      Fills the field catalog by depending on the tables given
*----------------------------------------------------------------------*
form fieldcatalog_merge1 using v_tab type slis_tabname
                               v_field type slis_t_fieldcat_alv.
 
  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
      i_program_name         = v_repid
      i_internal_tabname     = v_tab
      i_inclname             = v_repid
    changing
      ct_fieldcat            = v_field
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.
 
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
endform.                    " FIELDCATALOG_MERGE1
 
*&---------------------------------------------------------------------*
*&      Form  KEY_INFO
*&---------------------------------------------------------------------*
*       Gets the Header and Item key into details
*----------------------------------------------------------------------*
form key_info .
 
  it_keyinfo-header01 = 'VBELN'.
  it_keyinfo-item01 = 'VBELN'.
 
endform.                    " KEY_INFO
 
 
*&---------------------------------------------------------------------*
*&      Form  HIERARCHICAL_DISPLAY
*&---------------------------------------------------------------------*
*       Displays the SO & SE details in a hierarchical list format
*----------------------------------------------------------------------*
form hierarchical_display   tables p_tab1 p_tab2
                            using  p_fieldcat type slis_t_fieldcat_alv
                                   p_events   type slis_t_event
                                   p_table1   type slis_tabname
                                   p_table2   type slis_tabname.
 
  i_variant1-variant = p_var.
 
  call function 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    exporting
      i_callback_program       = v_repid
      i_callback_pf_status_set = 'PF_STATUS'
      is_layout                = wa_layout
*     I_CALLBACK_USER_COMMAND  = ' '
      it_fieldcat              = p_fieldcat
      i_save                   = 'X'
      is_variant               = i_variant1
      it_events                = p_events
      i_tabname_header         = p_table1
      i_tabname_item           = p_table2
      is_keyinfo               = it_keyinfo
    tables
      t_outtab_header          = p_tab1
      t_outtab_item            = p_tab2
    exceptions
      program_error            = 1
      others                   = 2.
 
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
endform.                    " HIERARCHICAL_DISPLAY
 
 
*&---------------------------------------------------------------------*
*&      Form  ALV_INIT
*&---------------------------------------------------------------------*
*       Gets the User command and sets the pf-status
*----------------------------------------------------------------------*
form alv_init .
 
  call function 'REUSE_ALV_BLOCK_LIST_INIT'
    exporting
      i_callback_program       = v_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'PO_USER_COMMAND'.
 
endform.                    " ALV_INIT
 
*&---------------------------------------------------------------------*
*&      Form  BLOCK_LIST
*&---------------------------------------------------------------------*
*       Appends the PO details into the Blocked list
*----------------------------------------------------------------------*
form block_list  using    p_wa_layout type slis_layout_alv
                          p_it_fieldcat1 type slis_t_fieldcat_alv
                          p_v_tabname type slis_tabname
                          p_it_events type slis_t_event.
 
  call function 'REUSE_ALV_BLOCK_LIST_APPEND'
    exporting
      is_layout                  = p_wa_layout
      it_fieldcat                = p_it_fieldcat1
      i_tabname                  = p_v_tabname
      it_events                  = p_it_events
    tables
      t_outtab                   = it_final1
    exceptions
      program_error              = 1
      maximum_of_appends_reached = 2
      others                     = 3.
 
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
  wa_layout-expand_fieldname = 'CHECK'.
 
endform.                    " BLOCK_LIST
 
*&---------------------------------------------------------------------*
*&      Form  BLOCK_LIST_HS
*&---------------------------------------------------------------------*
*       Appends the SO & SE details to the blocked list
*----------------------------------------------------------------------*
form block_list_hs .
 
  call function 'REUSE_ALV_BLOCK_LIST_HS_APPEND'
    exporting
      is_layout                  = wa_layout
      it_fieldcat                = it_fieldcat2
      is_keyinfo                 = it_keyinfo
      i_header_tabname           = 'IT_FINAL2'
      i_item_tabname             = 'IT_FINAL3'
      it_events                  = it_events1
    tables
      t_outtab_header            = it_final2
      t_outtab_item              = it_final3
    exceptions
      program_error              = 1
      maximum_of_appends_reached = 2
      others                     = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
 
endform.                    " BLOCK_LIST_HS
 
*&---------------------------------------------------------------------*
*&      Form  BLOCK_DISPLAY
*&---------------------------------------------------------------------*
*       Displays the Blocked list
*----------------------------------------------------------------------*
form block_display .
 
  call function 'REUSE_ALV_BLOCK_LIST_DISPLAY'
    exceptions
      program_error = 1
      others        = 2.
 
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
endform.                    " BLOCK_DISPLAY
 
 
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FLDCAT
*&---------------------------------------------------------------------*
*       Modifies the field catalog of PO details
*----------------------------------------------------------------------*
 
form modify_fldcat .
 
  loop at it_fieldcat1 into wa_fieldcat1 .
    case wa_fieldcat1-fieldname .
      when 'BSTKD' .
        wa_fieldcat1-seltext_l = 'PO Number'(010).
        wa_fieldcat1-outputlen = 35 .
        wa_fieldcat1-ddictxt = 'L' .
      when 'KUNNR' .
        wa_fieldcat1-outputlen = 15 .
        wa_fieldcat1-seltext_l = 'Sold-To Pt.'(011).
        wa_fieldcat1-ddictxt = 'L' .
      when 'NAME1' .
        wa_fieldcat1-outputlen = 35 .
        wa_fieldcat1-seltext_l = 'Name1'(012).
        wa_fieldcat1-ddictxt = 'L' .
      when 'VDATU' .
        wa_fieldcat1-outputlen = 15 .
        wa_fieldcat1-seltext_l = 'Req.Dlv.Dt.'(013).
        wa_fieldcat1-ddictxt = 'L' .
    endcase .
    modify it_fieldcat1 from wa_fieldcat1 .
  endloop.
 
endform.                    " MODIFY_FLDCAT
 
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCAT_HIRARCHICAL
*&---------------------------------------------------------------------*
*       Modifies the field catalog of SO & SE details
*----------------------------------------------------------------------*
 
form modify_fieldcat_hirarchical.
 
  loop at it_fieldcat2 into wa_fieldcat1.
    case wa_fieldcat1-fieldname.
      when 'VBELN' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'SD Doc'(014).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'VDATU' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'Req.Dlv.Dt'(015).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'ERDAT' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'Rec Created Date'(016).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'LFGSK' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'Dlv Status'(017).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'CHECK'.
        wa_fieldcat1-no_out    = 'X'.
    endcase .
    modify it_fieldcat2 from wa_fieldcat1.
  endloop.
 
endform.                    " MODIFY_FIELDCAT_HIRARCHICAL
 
*&---------------------------------------------------------------------*
*&      Form  GET_EVENTS
*&---------------------------------------------------------------------*
*       Gets the events for the list
*----------------------------------------------------------------------*
form get_events.
 
  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type     = 2
    importing
      et_events       = it_events
    exceptions
      list_type_wrong = 1
      others          = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
  read table it_events into wa_events
                       with key name = slis_ev_top_of_list.
  if sy-subrc = 0.
    wa_events-form = 'TOP_OF_LIST'.
    modify it_events from wa_events index sy-tabix.
  endif.
 
  read table it_events into wa_events
                     with key name = slis_ev_user_command.
  if sy-subrc = 0.
    wa_events-form = 'PO_USER_COMMAND'.
    modify it_events from wa_events index sy-tabix.
  endif.
 
endform.                    " GET_EVENTS
 
*&---------------------------------------------------------------------*
*&      Form  GET_EVENTS1
*&---------------------------------------------------------------------*
*     Gets the events for the list
*----------------------------------------------------------------------*
form get_events1 .
 
  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type     = 3
    importing
      et_events       = it_events1
    exceptions
      list_type_wrong = 1
      others          = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
  clear wa_events.
  read table it_events1 into wa_events
                       with key name = slis_ev_top_of_list.
  if sy-subrc = 0.
    wa_events-form = 'TOP_OF_LIST1'.
    modify it_events1 from wa_events index sy-tabix.
  endif.
 
endform.                    " GET_EVENTS1
 
*---------------------------------------------------------------------*
*     T O P  -  O F  -  L I S T
*---------------------------------------------------------------------*
*     Displays the Top of list of PO details
*----------------------------------------------------------------------*
 
form top_of_list.
 
  skip.
  write 'SYRATECH CORPORATION'(025).
  skip.
  write:/ 'System  :'(021), sy-mandt,
        / 'User    :'(022), sy-uname,
        / 'Date    :'(023), sy-datum,
        / 'Time    :'(024), sy-uzeit.
  skip.
  write:/ 'PO DETAILS'(019).
 
endform.                    "TOP_OF_LIST
 
*---------------------------------------------------------------------*
*     T O P   O F   L I S T 1
*---------------------------------------------------------------------*
*     Displays the Top of list of SO & SE details
*----------------------------------------------------------------------*
 
form top_of_list1.
 
  write:/ 'SO & SE DETAILS'(020).
 
endform.                    "TOP_OF_LIST1
 
*---------------------------------------------------------------------*
*     P F - S T A T U S
*---------------------------------------------------------------------*
*     Sets the Pf-Status
*----------------------------------------------------------------------*
 
form pf_status using rt_extab type slis_t_extab.
 
  set pf-status 'ZSREEPO'.
 
endform.                    "PF_STATUS
 
*---------------------------------------------------------------------*
*     U S E R   C O M M A N D
*---------------------------------------------------------------------*
*     Gets the user command and perform different operations
*----------------------------------------------------------------------*
 
form po_user_command using p_ucomm    type sy-ucomm
                           p_selfield type slis_selfield.
 
  case p_selfield-tabname.
 
    when 'IT_FINAL1'.
*---If user clicks on PO number, displays the SO and SE details of that
*---                                               particular PO number
      v_selfield_value = p_selfield-value.
*--- Gets the current layout details and process appropriate action
      perform display_secondary_list.
 
    when 'IT_FINAL2'.
*---If user clicks on the sales order number in the SO level the
*---                      transaction VA03 will open in a new window
      if p_selfield-fieldname = 'VBELN'.
        perform call_transaction_va03. " Calls the transaction in a
        " separate window
      endif.
 
    when 'IT_FINAL3'.
*---If user clicks on the sales order number in the Line Item the
*---               Intelligroup home page will open in a new browser
      if p_selfield-fieldname = 'VBELN'.
        perform open_browser. " Opens the Browser in a new window
      endif.
 
  endcase.
 
endform.                    "USER_COMMAND
 
 
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION_VA03
*&---------------------------------------------------------------------*
*       Calls the transaction VA03 in a new session
*----------------------------------------------------------------------*
form call_transaction_va03 .
 
  call function 'ABAP4_CALL_TRANSACTION' starting new task 'TEST'
    destination 'NONE'
    exporting
      tcode                   = 'VA03'
    exceptions
      call_transaction_denied = 1
      tcode_invalid           = 2
      others                  = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
endform.                    " CALL_TRANSACTION_VL10
 
*&---------------------------------------------------------------------*
*&      Form  GET_EVENTS2
*&---------------------------------------------------------------------*
*       Gets the events for SO & SE details
*----------------------------------------------------------------------*
form get_events2 .
 
  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type     = 1
    importing
      et_events       = it_events2
    exceptions
      list_type_wrong = 1
      others          = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
  clear wa_events.
  read table it_events2 into wa_events
                        with key name = slis_ev_top_of_list.
  if sy-subrc = 0.
    wa_events-form = 'TOP_OF_LIST1'.
    modify it_events2 from wa_events index sy-tabix.
  endif.
 
  read table it_events2 into wa_events
                        with key name = slis_ev_user_command.
  if sy-subrc = 0.
    wa_events-form = 'PO_USER_COMMAND'.
    modify it_events2 from wa_events index sy-tabix.
  endif.
 
endform.                    " GET_EVENTS2
 
*&---------------------------------------------------------------------*
*&      Form  OPEN_BROWSER
*&---------------------------------------------------------------------*
*       Opens the Intelligroup home page in a new browser
*----------------------------------------------------------------------*
form open_browser .
 
  call function 'CALL_BROWSER'
    exporting
      url                    = 'WWW.INTELLIGROUP.COM'
      new_window             = 'X'
    exceptions
      frontend_not_supported = 1
      frontend_error         = 2
      prog_not_found         = 3
      no_batch               = 4
      unspecified_error      = 5
      others                 = 6.
 
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
endform.                    " OPEN_BROWSER
 
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_SO_SE_DETAILS
*&---------------------------------------------------------------------*
*       Displays the
*----------------------------------------------------------------------*
form display_so_se_details using p_selfield type slis_selfield-value.
 
  refresh: it_final4, it_final5.
*---Moving the SO details into a final table IT_FINAL4
  loop at it_vbkd where bstkd = p_selfield.
    loop at it_vbak where vbeln = it_vbkd-vbeln.
      clear it_vbuk.
      read table it_vbuk with key vbeln = it_vbak-vbeln.
      it_final4-vbeln = it_vbak-vbeln.
      it_final4-vdatu = it_vbak-vdatu.
      it_final4-erdat = it_vbak-erdat.
      it_final4-lfgsk = it_vbuk-lfgsk.
      it_final4-check = 'X'.
      append it_final4.
      clear it_final4.
    endloop.
  endloop.
 
  loop at it_final4.
    loop at it_vbap where vbeln = it_final4-vbeln.
      loop at it_vbep where vbeln = it_vbap-vbeln
                        and posnr = it_vbap-posnr.
        it_vbep1 = it_vbep.
        append it_vbep1.
        clear it_vbep1.
      endloop.
 
*---Moving the SE details into a final table IT_FINAL5
 
      describe table it_vbep1 lines v_linc.
      if v_linc = 1.
        clear it_vbep1.
        read table it_vbep1 index 1.
        it_final5-vbeln  = it_vbep-vbeln.
        it_final5-posnr  = it_vbep1-posnr.
        it_final5-etenr  = it_vbep1-etenr.
        it_final5-matnr  = it_vbap-matnr.
        it_final5-arktx  = it_vbap-arktx.
        it_final5-bddat  = it_vbep1-bddat.
        it_final5-kwmeng = it_vbap-kwmeng.
        it_final5-bmeng  = it_vbep1-bmeng.
        append it_final5.
        clear it_final5.
 
      else.
        loop at it_vbep1 where bmeng <> 0.
          it_final5-vbeln  = it_vbep-vbeln.
          it_final5-posnr  = it_vbep1-posnr.
          it_final5-etenr  = it_vbep1-etenr.
          it_final5-matnr  = it_vbap-matnr.
          it_final5-arktx  = it_vbap-arktx.
          it_final5-bddat  = it_vbep1-bddat.
          it_final5-kwmeng = it_vbap-kwmeng.
          it_final5-bmeng  = it_vbep1-bmeng.
          append it_final5.
          clear it_final5.
        endloop.
      endif.
      refresh it_vbep1.
      clear it_vbep1.
    endloop.
  endloop.
 
  v_tabname = 'IT_FINAL4'.
*---Populates the field catalog for SO details
  perform fieldcatalog_merge1 using v_tabname
                                    it_fieldcat3.
 
  v_tabname = 'IT_FINAL5'.
*---Populates the field catalog for SE details
  perform fieldcatalog_merge1 using v_tabname
                                    it_fieldcat3.
 
  perform modify_fieldcat_hirarchical2.
 
*---Displays the SO & SE details in a hierarchical format
  perform hierarchical_display tables it_final4
                                      it_final5
                               using  it_fieldcat3
                                      it_events2
                                     'IT_FINAL4'
                                     'IT_FINAL5'.
 
endform.                    " GET_SECLIST_DATA
 
*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       Gets the variant
*----------------------------------------------------------------------*
form variant_init.
 
  v_repid = sy-repid.
  clear i_variant.
  i_variant-report = v_repid.
 
endform.                    " VARIANT_INIT
 
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*     Gets the variant to select the layout
*----------------------------------------------------------------------*
form f4_for_variant.
 
  data: lv_save(1)        type c, " To save the variant
        lv_exit(1)        type c. " To get Dialog cancelled by user
 
  call function 'REUSE_ALV_VARIANT_F4'
    exporting
      is_variant    = i_variant
      i_save        = lv_save
    importing
      e_exit        = lv_exit
      es_variant    = i_variant1
    exceptions
      not_found     = 1
      program_error = 2
      others        = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    if lv_exit = space.
      p_var = i_variant1-variant.
    endif.
  endif.
 
endform.                    " F4_FOR_VARIANT
 
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_SECONDARY_LIST
*&---------------------------------------------------------------------*
*       Gets the current layout and process appropriate action
*----------------------------------------------------------------------*
form display_secondary_list .
 
  data: i_fieldcat1 type slis_t_fieldcat_alv, " Internal table for
                                               "temporary field catalog
        lv_fieldcat type slis_fieldcat_alv, " Work area for temporary
                                               " field catalog
        lv_colpos   type i, " To store the column position
        lv_colpos1  type i, " To store the column position
        lv_layout1  type slis_layout_alv. " Work Area for Layout
 
  clear i_fieldcat1.
  refresh i_fieldcat1.
 
  call function 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
    importing
      es_layout     = lv_layout1
      et_fieldcat   = i_fieldcat1
    exceptions
      no_infos      = 1
      program_error = 2
      others        = 3.
 
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
 
  clear: lv_colpos1, lv_colpos.
  lv_colpos1 = 2.
  lv_colpos  = 2.
 
*--- After changing the field catalog of PO details, user can get the
*---  list of SO & Line item details  in Hierarchical list form by
*---  clicking only on the Purchase Order number.
  loop at i_fieldcat1 into lv_fieldcat.
    if lv_fieldcat-no_out <> 'X'.
      lv_colpos1 = lv_colpos1 + lv_fieldcat-outputlen + 1.
      if lv_fieldcat-fieldname = 'BSTKD'.
        if  sy-cucol >= lv_colpos and sy-cucol <= lv_colpos1.
          perform display_so_se_details using v_selfield_value.
          clear v_selfield_value.
          exit.
        endif.
      endif.
      lv_colpos = lv_colpos + lv_fieldcat-outputlen + 1.
    endif.
  endloop.
endform.                    " DISPLAY_SECONDARY_LIST
 
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCAT_HIRARCHICAL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form modify_fieldcat_hirarchical2 .
 
 loop at it_fieldcat3 into wa_fieldcat1.
    case wa_fieldcat1-fieldname.
      when 'VBELN' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'SD Doc'(014).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'VDATU' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'Req.Dlv.Dt'(015).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'ERDAT' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'Rec Created Date'(016).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'LFGSK' .
        wa_fieldcat1-outputlen = 20.
        wa_fieldcat1-seltext_m = 'Dlv Status'(017).
        wa_fieldcat1-ddictxt   = 'M'.
      when 'CHECK'.
        wa_fieldcat1-no_out    = 'X'.
    endcase .
    modify it_fieldcat3 from wa_fieldcat1.
  endloop.
 
endform.                    " MODIFY_FIELDCAT_HIRARCHICAL2
