---
layout: post
title: Reversar Pedidos Ventas - SAP SD
url: /reversar-pedidos-ventas/
category: sap-sd
published: true
date: 2019-03-20T13:11:54-03:00
---

Buen día a toda la comunidad, navegando en busca de más conocimiento me encontré con el siguiente código ABAP, con información muy importante para usar la bapi BAPI_BILLINGDOC_CANCEL1 para cancelar/reversar documentos de facturación del área de ventas (SAP SD).
<!--more-->

Esta bapi cumple la misma labor que la transacción VF11.

{% highlight abap %}
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
{% endhighlight %}

***

[Ver código completo](https://github.com/consultoria-sap/ABAP/blob/master/codigos/bapi_billingdoc_cancel1/billing-doc-cancel.abap)

***

:heart: [Agradecer al autor Daniel Panaro](https://danielpanaro.wordpress.com/2019/02/28/funcion-para-cancelar-reversar-facturaciones-de-ventas-sd/)
