---
title: "Actualizacion Masiva Criticidad Excel"
description: "Les comparto un código ABAP, para actualizar de manera masiva la criticidad de un material cargando un archivo de excel, omitiendo el uso de un LSMW. ..."
fuente: "Archivo Histórico SAP"
---

# Actualización masiva la criticidad del Material

Les comparto un código ABAP, para actualizar de manera masiva la criticidad de un material cargando un archivo de excel, omitiendo el uso de un LSMW. El código ABAP va ordenado de la siguiente manera:

1. Archivo Principal (donde se invoca un FORM y un TOP).

<<< @/codigos/Actualizacion-masiva-criticidad-Excel/Principal.abap{abap}

2. Top (Declaración de estructuras, variables y tablas).

<<< @/codigos/Actualizacion-masiva-criticidad-Excel/zmm_criticidad_form.abap{abap}

3. Form (Desarrollo del proceso)

<<< @/codigos/Actualizacion-masiva-criticidad-Excel/zmm_criticidad_top.abap{abap}

***

Copyright © 2008-2019 - [www.Consultoria-SAP.com](https://www.Consultoria-SAP.com)