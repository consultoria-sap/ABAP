---
layout: base
title: SAP ABAP free examples
---

## Bienvenidos al repositorio de conocimiento libre de Consultoria-SAP.com

Solo para aclarar, el código compartido aquí es libre. Lo que significa que cualquier colaborador del repositorio puede subirlo, editarlo y/o modificarlo. Si bajas un desarrollo y no funciona, **debes** abrir un tema en el **[foro de AYUDA SAP](https://foros.consultoria-sap.com)** para que lo revisen otros colaboradores.


***

## Publicaciones destacadas

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>

***

## Índice de Códigos

{% include indice.md %}

