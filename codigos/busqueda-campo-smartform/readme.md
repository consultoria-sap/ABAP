---
Todos los derechos reservados a éste debate y su autor:
http://foros.consultoria-sap.com/t/busqueda-de-un-campo/4673
Autor: @Naoto_Amari
---

Buenas amigos saperos, saben que tengo un smartforms que tiene un loop, el cual tiene un tabla interna ITEMS INTO W_ITEMS la cual la declaran del tipo en Datos Globales type ZFIES_BNKCON y en la parte de inicializacion lo usan en:

```abap
LOOP AT items INTO w_items.
  CLEAR: tam, hkont.
  tam = STRLEN( w_items-nrcta0 ).
  tam = tam - 1.
  CONCATENATE w_items-nrcta0(tam) '2' INTO hkont.
  w_hkont-sign = 'I'.
  w_hkont-option = 'BT'.
  w_hkont-low    = w_items-nrcta0.
  w_hkont-high   = hkont.
  APPEND w_hkont TO r_hkont.
ENDLOOP.
```


***

Copyright © 2008-2017 - [www.Consultoria-SAP.com](http://www.Consultoria-SAP.com)
