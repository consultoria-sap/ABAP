---
Nota: Todos los derechos reservados a éste debate y sus autores
Autor/es: https://sap4tech.net/update-characteristic-value-in-sap/
carpeta: true
---

This code will update characteristic value in SAP.
First, it checks if the characteristic is already exists or if has to be created.
Second, it updates the characteristic value.

### Update characteristic value SAP Signature

The following code sample is a class’s method with these parameters:

Importing :
* IV_OBJECTKEY TYPE OBJNUM
* IV_KLART TYPE KLASSENART
* IV_ATNAM TYPE ATNAM
* IV_VALUE_NEW TYPE ATWRT

Exporting :
* ET_RETURN TYPE BAPIRETTAB

![Update characteristic value SAP Signature](https://sap4tech.b-cdn.net/wp-content/uploads/2015/06/Classification_02-e1446590728624.png)

### Update characteristic value ABAP Sample

The following part is the Sample ABAP Method will help you update SAP Customer Characteristic in SAP.
The steps required to perform Characteristic update for customer are:

* Get Class Type and Object Table for this Characteristic.
* Get the Class Num of Characteristic
* Check if this Characteristic exist : Update or Creation ?
* Fill the new Characteristic value
* Update Characteristic Value in Sap
* If no error occurs, commit work to Update Characteristic Value in Sap

## Code

View Code [v1.abap](https://github.com/consultoria-sap/ABAP/blob/master/codigos/update-characteristic-value-in-sap/v1.abap)

***

Copyright © 2008-2018 - [www.Consultoria-SAP.com](http://www.Consultoria-SAP.com)
