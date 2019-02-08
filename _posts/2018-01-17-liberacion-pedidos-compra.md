---
layout: post
title: Status e Información sobre Liberación de OC
url: /liberacion-pedidos-compra/
category: sap-mm
published: true
date: 2018-01-17T11:11:54-03:00
---

Buen día a toda la comunidad, navegando en busca de más conocimiento me encontré con el siguiente código ABAP, para un reporte que nos muestra iniformación del las liberaciones en nuestros pedidos de Compra. Leyendo las tablas de pedidos (**EKKO** y **EKPO**), además el historial de modificaciones de los documentos

<!--more-->

>Nota: es requisito crear la estructura **ZMMY_PURCHASEMODIF**, como se detalla dentro del código del programa (allí están los detalles de los campos a incluir). Igualmente, en el código fuente se detallan los valores de los elementos de texto (Textos de selección y Símbolos de texto) necesarios también para ejecutar el programa correctamente.

{% highlight abap %}
********************************************************************

report  zmmy_po_history.

************************************************************************
* Tables
************************************************************************
tables : eket .

************************************************************************
* Types
************************************************************************
type-pools: slis.

************************************************************************
* selection screen
************************************************************************

data:
p_ekorg type ekko-ekorg,  " Organizacion compras
p_bukrs type ekko-bukrs,  " Sociedad
p_ekgrp type ekko-ekgrp,  " Grupo compras
p_bedat type ekko-bedat,  " Fecha Documento Compras
p_bsart type ekko-bsart,  " Clase Documento
p_ebeln type ekko-ebeln,  " Numero Documento Compras
p_procstat type ekko-procstat.  " Status tratamiento documento compras

selection-screen begin of block b1 with frame title text-001.

* Descripciones de los campos de seleccion
*S_BEDAT  Fecha documento
*S_BSART  Cl.documento compras
*S_BUKRS  Sociedad
*S_EBELN  Documento compras
*S_EKGRP  Grupo de compras
*S_EKORG  Organización compras
*S_PROC	Status tratamiento doc.
* Fin descripciones

select-options:
s_ekorg for p_ekorg,  " Organizacion compras
s_bukrs for p_bukrs,  " Sociedad
s_ekgrp for p_ekgrp,  " Grupo compras
s_bsart for p_bsart,  " Clase Documento
s_bedat for p_bedat,  " Fecha Documento Compras
s_ebeln for p_ebeln,  " PNumero Documento Compras
s_proc for p_procstat.  " Status tratamiento documento compras

selection-screen end of block b1.



************************************************************************
* Estructuras y tablas internas
************************************************************************
*CREAR LA ESTRUCTURA EN LA SE11 ANTES DE USAR EL PROGRAMA
*data: begin of zmmy_purchasemodif,

* ... Continúa el código  *

{% endhighlight %}

***

[Ver código completo](https://github.com/consultoria-sap/ABAP/blob/master/codigos/informacion-liberacion-pedidos-compra/zmmy_po_history.abap)

:heart: [Agradecer al autor en Consultoria-SAP](https://foros.consultoria-sap.com/t/status-e-informacion-de-liberacion-en-pedidos-comp/16468)
