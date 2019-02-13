---
Todos los derechos reservados a ésta página
Fuente: http://sgstocks.tripod.com/abap002.htm
Aún no se abre debate sobre esto en Ayuda SAP
---

# Display SAP Dictionary Table Information

The SAP transaction SE11 displays all the field information in a great detail. If only we could download the information into a file... or be able to search for a string...

The ABAP program below fulfills the above wishes. It is basically a report so you can download the output and search for a specific string.

You can supply a single table name (e.g., KNA1) in the selection screen. You can also run this program against multiple tables but the table names should come from an external file. Double clicking on the highlighted table name takes you to SE11 on that table!

I have the following text elements defined: 

`TEXT-001` = Specify a single table name here, or hit F8 to specify a `TEXT-002` = file name containing table names.

***

Copyright © 2008-2019 - [www.Consultoria-SAP.com](https://www.Consultoria-SAP.com)
