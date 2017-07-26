FUNCTION zfi_fm_fbl3n.

*”———————————————————————-
*”*”Local Interface:
*”  IMPORTING
*”     VALUE(I_POSTAB) LIKE  RFPOS STRUCTURE  RFPOS
*”  EXPORTING
*”     VALUE(E_POSTAB) LIKE  RFPOS STRUCTURE  RFPOS
*”———————————————————————-
*& Function Module Name :   ZFI_FM_FBL3N
*& Module                        :   FI
*& Functional Consultant  :
*& Author Name :                 Manoj Kumar Pradhan
*& Date Of Creation         :    24/07/2012
*& Description                 :    This fm populates values for additional fields
*                                         like vendor,customer, separate fields for debit & credit
*                                         indicator which will be displayed in FBL3N/FBL1N/FBL5N
*                                         output list.
*
*                                        It triggers from T-codes FBL3N/FBL1N/FBL5N
*                                        for BTE event 00001650 & configured
*                                        in FIBF T-code for customer products Z1650 for the event 00001650.
*& Transport Request     : 
*& Tcode                 :  NA

**********************************************
***** Data Declaration***************
**********************************************

  DATA : e_fiscal_yr           TYPE bapi0002_4-fiscal_year,
         e_period              TYPE bapi0002_4-fiscal_period,
         e_prev_period         TYPE bapi0002_4-fiscal_period,
         e_ret                 TYPE bapireturn1,
         e_first_day_of_period TYPE bapi0002_4-posting_date,
         lf_prev_day_of_post_date TYPE budat,
         e_ret2                TYPE bapireturn1,
         e_ret3                TYPE bapireturn,
         e_ret4                TYPE bapireturn,
         lf_sum_dmbtr          TYPE dmbtr,
         lf_sum_dmbtr_k        TYPE dmbtr,
         lf_sum_dmbtr_d        TYPE dmbtr.
 
  e_postab = i_postab.
  SELECT SINGLE lifnr kunnr
     FROM bseg
     INTO (e_postab-zzlifnr, e_postab-zzkunnr)
     WHERE bukrs = i_postab-bukrs
       AND gjahr = i_postab-gjahr
       AND belnr = i_postab-belnr
       AND ( kunnr  <> ” OR lifnr <> ” )
  IF i_postab-shkzg = ‘S’.
    e_postab-zzdeb_ind = ‘S’.
  ELSEIF i_postab-shkzg = ‘H’.
    e_postab-zzcr_ind = ‘H’.
  ENDIF.
  
*********************************************
