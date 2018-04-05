---
Todos los derechos reservados a ésta página
Fuente: http://www.abap.es/foro/index.php?topic=31.0
Aún no se abre debate sobre esto en Ayuda SAP
---

## v0
[Ver codigo del programa](https://github.com/consultoria-sap/ABAP/blob/master/codigos/enviar-email-externo/v0.abap)

Con este código podremos enviar de forma sencilla un correo a una dirección e-mail externa.

Hay que tener configurado el SAPconect para que el envío se haga de forma inmediata.

Fijaros en la línea donde pone: `wrecepient   = 'tu_correo@email.com'`. Hay que cambiar la dirección y poner una vuestra.

***

## v1
[Ver codigo del programa](https://github.com/consultoria-sap/ABAP/blob/master/codigos/enviar-email-externo/v1.abap)

Os dejo otro código que funciona siempre que el usuario tiene en su pc local instalado Outlook, de esta manera podemos enviar un correo sin tener configurado SAPConnect y además si trabajamos habitualmente con Outlook lo tendremos en Elementos Enviados.

