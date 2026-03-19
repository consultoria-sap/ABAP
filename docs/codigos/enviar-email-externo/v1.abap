  Report ZMAIL.

  DATA: OUTLOOK TYPE OLE2_OBJECT.  "Outlook.Application
  DATA: ITEM TYPE OLE2_OBJECT.     "Outlook.MailItem
  DATA: LATTACH TYPE OLE2_OBJECT . "Outlook.Attachement
  DATA: SUBJECT(255) TYPE C.

*
*Enviar mail

  CREATE OBJECT OUTLOOK 'outlook.application'.

  CALL METHOD OF OUTLOOK 'CreateItem' = ITEM
    EXPORTING
      #1 = '0'.

  SET PROPERTY OF ITEM 'To' = 'la dirección de correo a la que queremos enviar'.

* Si queremos rellenar el cuerpo del mensaje
*  OPCION 1:
*    LOOP AT body_tab INTO wa_bodytab.
*      SET PROPERTY OF omail 'Body' = wa_bodytab.
*    ENDLOOP.
*  OPCION 2:
*  SET PROPERTY OF item 'Body' = ''.

  SET PROPERTY OF ITEM 'Subject' = 'Asunto del correo'.

  CALL METHOD OF ITEM 'Attachments' = 'Ruta al fichero si queremos adjuntar alguno'.

  CALL METHOD OF LATTACH 'Add'
    EXPORTING
      #1 = NOMBRE.

  CALL METHOD OF ITEM 'Send'.

  FREE OBJECT ITEM.
  FREE OBJECT OUTLOOK.
  FREE OBJECT LATTACH.
