---
Todos los derechos reservados a éste debate y su autor:
http://foros.consultoria-sap.com/t/funcion-rzl-read-dir-local-solo-retorna-10000-line/4728
Autor: @silver
---

## funcion-rzl-read-dir-local

### EL ASUNTO
Resulta que tengo una aplicación no estándar de monitor de facturación electrónica, crea XML, sella, timbra y toda la cosa, esto se almacena en una tablita que llamaremos ZSD_TCFDI, la cual tiene 11500 lineas, y todo bien divino.

### EL PROBLEMA
Tengo la opción de descargar el XML ya timbrado esta opción usa la función RZL_READ_DIR_LOCAL para darme los documentos y después filtrar por nombre de documento, para finalmente darme un archivo.

SUCEDE QUE SOLO ME TRAE 10,000 LINEAS EN LAS CUALES NO ESTA INCLUIDO EL DOCUMENTO QUE QUIERO Y OTROS CONSECUTIVOS. POR LO QUE NO ME DESCARGA EL XML.

tengo entendido que la definición de tabla interna soporta mas de mis 11,500 registros. así que atribuí el desorden a la función.

Si alguien tiene algún comentario de oro, de esos que pesan por cada letra. se los agradecería.

Saludos. cordiales.


***

Copyright © 2008-2017 - [www.Consultoria-SAP.com](http://www.Consultoria-SAP.com)
