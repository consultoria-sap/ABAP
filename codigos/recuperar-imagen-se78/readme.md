---
Todos los derechos reservados a ésta página
Fuente: http://www.abap.es/foro/index.php?topic=60.0
Debate: https://foros.consultoria-sap.com/t/eliminar-una-imagen-de-un-formato-de-retencion/24479/8
---

El formato que yo trabajé en ECC 6 se creó con `SMARTFORMS`. Lo que hice fue crear la imagen (QR para facturación electrónica) en tiempo de ejecución y la guardé utilizando funciones de SAP de manejo de imágenes; éstas pueden visualizarse mediante la transacción `SE78`, mediante el nombre de la imagen y si esta está en blanco y negro o color y también el formato (BMP o JPG). 

Hay un programa Z (`ZRECUPERAR_IMAGEN_SE78`) que puedes descarga de aquí (`http://www.abap.es/foro/index.php?topic=60.02`) y que te permite descargar las imágenes guardadas para saber su contenido, ahora si con el nombre de la imagen (firma que quieres eliminar) es suficiente, entonces debes crear una imagen en blanco y sustuirla por la imagen de la firma.

Ver codigo ZRECUPERAR_IMAGEN_SE78.abap
