---
Todos los derechos reservados a éste debate y sus autores
Autor/es: @Alvan1
Mirror: https://gist.github.com/Alvan1991/e22d669985b22e066c67370f3b63bff7
---

Hola comunidad, el tema de hoy se trata acerca de los bloqueos que uno puede crear para limitar el acceso a los usuarios en ciertos momentos que esto se requiera. El manejo de estos bloqueos nos ayudara a siempre mantener la integridad de nuestra información.

Por ejemplo supongamos que tenemos una transacción que es muy utilizada por los usuarios y ademas desde ella se actualizan registros. Debemos de tener mucho cuidado con la integridad de la información, para evitar por ejemplo el visualizar algún registro que en ese momento se le esta actualizando la información, o por ejemplo evitar que 2 usuarios modifiquen la información al mismo tiempo, etc.

Y para esos casos nos ayudaran los bloqueos que a continuación muestro paso a paso.

* [Ver paso a paso en SAP](https://foros.consultoria-sap.com/t/creacion-de-bloqueos-enqueue-y-dequeue/3475)
* [Ver código](https://github.com/SidVal/ABAP/blob/master/codigos/creacion-de-bloqueos-enqueue-y-dequeue/zprb1.abap)

***

Copyright © 2008-2019 - [www.Consultoria-SAP.com](https://www.Consultoria-SAP.com)
