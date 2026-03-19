DATA:
lv_doc         LIKE bapivbrksuccess–bill_doc,
lv_date       TYPE bf_datm1eb,
t_return      TYPE TABLE OF bapireturn1,
t_success    TYPE TABLE OF bapivbrksuccess.

lv_doc  = vbeln. “Número de factura SD que se quiere cancelar.
lv_date = fecha. “Fecha en la que se contabilizará la cancelación.

* Función que reversa el documento
CALL FUNCTION ‘BAPI_BILLINGDOC_CANCEL1‘
EXPORTING
billingdocument = lv_doc
billingdate  = lv_date
*testrun         =
*no_commit   =
TABLES
return  = t_return
success = t_success.

*La tabla t_return devuelve todos los mensajes ocurridos durante la cancelación.
*La tabla t_succes devuelve, entre otros datos, el número de la cancelación.

