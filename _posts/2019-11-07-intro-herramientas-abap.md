---
layout: post
title: Introducción a las herramientas de desarrollo ABAP
url: /intro-herramientas-abap/
category: sap-abap
published: true
date: 2019-11-07T10:30:54-03:00
---

Con la introducción del desarrollo ágil en ABAP, las Herramientas de desarrollo ABAP se han convertido rápidamente en una herramienta popular y fácil de usar al programar con ABAP.

En el pasado, lo más probable es que Object Navigator (Transacción **SE80**) le haya servido tan fielmente como a otros desarrolladores durante muchos años. Object Navigator no solo es un entorno de desarrollo estable, sino también uno al que te has acostumbrado, sobre todo por su claridad basada en formularios.

Sin embargo, el triunfo del desarrollo ágil no ha dejado al Object Navigator indemne. Aunque todavía puede mantenerse bien con respecto a la Unidad ABAP, se ha dejado atrás durante bastante tiempo en términos de refactorización. ¿Qué ha ocupado su lugar? Herramientas de desarrollo ABAP, anteriormente conocidas como **ABAP en Eclipse**.

<!--more-->

# Introducción a las herramientas de desarrollo ABAP

## Creando un proyecto

Con las herramientas de desarrollo ABAP, solo puede desarrollar una clase dentro de un proyecto ABAP. La forma más fácil es crear un proyecto ABAP basado en una conexión del sistema que ya existe en su inicio de sesión de SAP. Puede encontrar más detalles sobre las alternativas en la ayuda en Tareas> Tareas y herramientas fundamentales> Trabajar con proyectos ABAP.

Para crear un nuevo proyecto ABAP, proceda de la siguiente manera:

* Inicie la creación de un nuevo proyecto utilizando la ruta del menú Archivo> Nuevo> Proyecto ABAP.
* De las entradas de inicio de sesión de SAP que se muestran, seleccione su sistema de desarrollo y confirme con Siguiente.
* Luego inicia sesión en el sistema como de costumbre.

## Crear una clase de producto
Si su clase de producto (clase para abreviar) ya existe, ábrala en las Herramientas de desarrollo ABAP con la combinación de teclas <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>A</kbd>. Simplemente escriba una expresión regular como `"*CL*PROC*CH*CHECK*"` en el campo _Buscar_ y seleccione la clase de la lista generada automáticamente.

Si su clase aún no existe, créela usando la ruta del menú `Archivo > Nuevo > Clase ABAP`. Si su clase es una subclase, puede especificar la superclase al mismo tiempo. Las herramientas de desarrollo ABAP amplían la definición en consecuencia.

Las herramientas de desarrollo ABAP crean automáticamente la prueba de inclusión local para su clase. Accede a esta prueba incluida desde la pestaña Clases de prueba debajo de la ventana del editor de código fuente ABAP. Si es necesario, puede volver a la definición e implementación de su clase en la pestaña adyacente Global Class.

Puede escribir su clase de prueba en la prueba incluida. Alternativamente, primero puede crear una plantilla de código para las clases de prueba que puede reutilizar para otras clases de prueba en esta y otras pruebas incluidas.

Una plantilla de código es un patrón de código que puede editar. Si ingresa un nombre corto en el editor y la combinación de teclas <kbd>Ctrl</kbd> + <kbd>Espacio</kbd> para llamar a la finalización del código, se le ofrece la plantilla de código para transferir al código fuente. Alternativamente, puede arrastrar esta plantilla de código desde la vista de Plantillas y soltarla en la ventana del editor (ver más abajo).

## Crear Plantilla de código

* Los siguientes pasos son necesarios para crear una plantilla de código:
* Siga la ruta del menú `Ventana > Preferencias > Desarrollo ABAP > Editores > Editores de código fuente > Plantillas ABAP` y haga clic en el botón Nuevo.
* Por ejemplo, ingrese el nombre corto "`ltc`" en el campo _Nombre_ y la descripción _"Clase de prueba local"_ en el campo Descripción.
Ingrese el texto de la lista a continuación en el campo Patrón y haga clic en el botón Aceptar.

![Screen Template View](https://consultoria-sap.github.io/ABAP/img/screen_template_view.jpg)

La siguiente lista contiene las siguientes variables de Herramientas de desarrollo ABAP:

* `${enclosing_object}`: nombre de la clase de producto
* `${cursor}`: posición del cursor después de reemplazar todas las variables
* `${mut}`: nombre de la clase de prueba
* `${cut_ref}`: Referencia del objeto a probar
* `${cut_type}`: Tipo del objeto a probar

```ABAP
CLASS ${ltc} DEFINITION FINAL
     FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
          PRIVATE SECTION
               METHODS setup.
               METHODS setup_ok FOR TESTING.
               DATA ${cut_ref} TYPE REF TO ${cut_type}.
     ENDCLASS.

     CLASS ${ltc} IMPLEMENTATION.
          METHOD setup.
               ${cut_ref} = ${enclosing_object}=>create( ${cursor} ).
     ENDMETHOD.

     METHOD setup_ok.
          Cl_abap_unit_assert=>assert_bound( ${cut_ref} ).
     ENDMETHOD.
ENDCLASS.
```

Las herramientas de desarrollo ABAP le ayudan a reemplazar las variables marcando la primera variable en la plantilla de código. Después de cambiar el nombre de una variable y finalizar el cambio de nombre con la tecla <kbd>Tab</kbd>, salta inmediatamente a la siguiente variable. Si ha utilizado la variable `${cursor}` en la plantilla de código, establece el cursor en la posición correspondiente en el código transferido (aquí en la llamada al método del método de creación **CREATE**, que aún no es visible en la figura anterior debido a la variable pendiente de cambio de nombre).

## Documentación técnica

**ABAP Development Tools** ofrece no solo muchas funciones útiles, sino también una amplia ayuda (ruta de menú Ayuda> Contenido de la ayuda). En este blog, nos referimos y nos limitamos al contenido de la sección SAP (On-Premise) —ABAP Development User Guide. Por lo tanto, hemos acortado todas las rutas enumeradas por este nodo raíz.

A continuación se muestra un extracto de este contenido de ayuda especial.

![Screen Help Content](https://consultoria-sap.github.io/ABAP/img/screen_help_content.png)

### Conclusión

Ser ágil en su codificación ABAP es una habilidad importante, y las Herramientas de diseño ABAP pueden ayudarlo a lograr este objetivo. 

***

>Nota del editor: Esta publicación ha sido adaptada de una sección del libro Desarrollo guiado por pruebas con objetos ABAP de Winfried Schwarzmann.
>
>Nota de Traducción: esta traducción se llevó a cabo con Google Translator, y se adaptó el contenido de códigos e imágenes para que sea más fácil de entender. 
>
>Fuente original: https://blog.sap-press.com/an-introduction-to-abap-development-tools
