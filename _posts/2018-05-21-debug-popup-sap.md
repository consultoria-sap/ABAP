---
layout: post
title: Debug Popup SAP
url: /debug-popup-sap/
category: sap-mm
published: true
date: 2018-05-21T11:51:54-03:00
---

Buen día a toda la comunidad, para ampliar el artículo sobre "POPUP en SAP" de Ser Consultor SAP, les traigo el código para realizar depuración directa a través del debugging dentro del programa SAP.

<!--more-->

## Paso por paso

* Copiamos el siguiente texto:

{% highlight txt %}
[FUNCTION] 
Command=/H 
Title=Debugger 
Type=SystemCommand 
{% endhighlight %}

* Lo guardamos como TXT
* Lo dejamos en un lugar accesible (como en el escritorio) para poder arrastrarlo y soltarlo arriba del popup de SAP.
