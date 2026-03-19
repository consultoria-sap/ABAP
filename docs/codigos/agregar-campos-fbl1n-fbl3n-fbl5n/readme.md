---
Nota: Todos los derechos reservados a éste debate y sus autores
Autor/es: https://people.sap.com/manojkumar.pradhan
carpeta: true
---

This blog talks about how to add some extra fields like Vendor Number, Customer Number, separate fields for credit & debit indicators and opening balance , closing balance per posting date wise in the output screen of SAP standard transactions FBL3N/FBL1N/FBL5N.

# Solution
We can use openFI 1650 (BTE) to add any fields to ALV output list in FBL3N/FBL1N/FBL5N at the same time.

SAP has already provided the place for Open FI BTE (1650) in the standard program that will trigger the custom function module assigned to the event 1650 in FIBF T-code.

* FBL3N:  G/L Account Line Item Display
* FBL1N:  Vendor Line Item Display
* FBL5N:  Customer Line Item Display

## Step 1
Create all required fields using append structure in structures RFPOS, RFPOSX

## Step 2
Create a custom function module by copying the same interface parameters of FM SAMPLE_INTERFACE_00001650.

## Step 3
Write the logic to populate the extra fields inside this custom function module as per your requirement.

https://github.com/SidVal/ABAP/blob/master/codigos/agregar-campos-fbl1n-fbl3n-fbl5n/zfi_fm_fbl3n.abap

## Step 4
Activate Open FI: t-CODE – FIBF & Create product of a customer by inputting product name, text & activate the same.

## Step 5
Create P/S MODULES of a customer in FIBF and assign custom function module to event 1650 & product.

## Step 6
Finally run standard program RFPOSXEXTEND to regenerate structure & run program BALVBUFDEL to clear ALV.

>Note: These two programs can only be run by user who has admin authority. Contact Basis user or IT administrator for assistance
After the completion of the above steps, we will be able to view these extra fields on execution of T-codes FBL3N/FBL1N/FBL5N. 
>
>Fuente del código:
https://blogs.sap.com/2012/08/30/enhancing-sap-standard-transactions-fbl3nfbl1nfbl5n-with-extra-fields-in-the-output-list-via-bte/
>
>Ampliar info:
http://www.saptutorial.org/how-to-add-additional-fields-in-fbl3n/



***

Copyright © 2008-2019 - [www.Consultoria-SAP.com](https://www.Consultoria-SAP.com)
