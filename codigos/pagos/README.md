---
Nota: Todos los derechos reservados a sus autores
Autor/es: Varios 
carpeta: true
---

# Pagos Parciales SAP

## Compensar Partidas

La rutina COMPENSAR_PARTIDA realiza la contabilización y compensación de una partida financiera. Con rellenar la tabla `FTCLEAR` con los documentos que se quieren compensar se compensarán todos.

Las rutinas que se implementan son:

* COMPENSAR_PARTIDA : rutina general de proceso
* INICIAR_INTERFAZ: rutina que inicializa el posting interface.
* PROCESAR_INTERFAZ : rutina que realiza la compensación.
* CERRAR_INTERFAZ : rutina que cierra el posting interface.

>Notar que se emplea en la rutina la variable `P_AUGBL`. 

En función de si tenemos que compensar factura o abono, la variable tiene un valor u otro:
https://github.com/consultoria-sap/ABAP/blob/master/codigos/pagos/compensar.abap

## Traslado de Saldos

Fuente: https://foros.consultoria-sap.com/t/pagos-parciales-via-posting-interface-end/4605/31

El codigo que tengo y funciona bien para pagos parciales, completos y de varias facturas a las vez espero te sirva:

* [Z_92_traslado_saldos.abap](https://github.com/consultoria-sap/ABAP/blob/master/codigos/pagos/z_92_traslado_saldos.abap)

***

Copyright © 2008-2021 - [www.Consultoria-SAP.com](https://www.Consultoria-SAP.com)
