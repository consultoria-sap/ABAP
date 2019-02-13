---
Todos los derechos reservados a éste debate y su autor:
https://foros.consultoria-sap.com/t/valor-de-un-parameter-desde-una-variable/14349
Autor: Machord
---

De nuevo estoy aquí planteando dudas sobre **ABAP**.

## Problema ABAP

En esta ocasión, se me está cruzando la inclusión de valores anteriormente calculados en parameters. No se si es posible, creo que si, ya que en la primera pantalla de SAP aparece el campo mandante y el número del mandante.

El caso es, tengo un parameter que quiero que coja un valor anteriormente calculado con un "Describe", para que me impresione el número de ID que se va a dar de alta, pero no consigo que me marque nada.
Creo, por otra parte, que estoy utilizando incorrectamente los eventos.

El problema es en el pa_id, que no registra el valor de gv_reg.

## Solución

[Ver código final](https://github.com/SidVal/ABAP/blob/master/parameter-desde-una-variable/parameter.abap)


***

Copyright © 2008-2019 - [www.Consultoria-SAP.com](https://www.Consultoria-SAP.com)
