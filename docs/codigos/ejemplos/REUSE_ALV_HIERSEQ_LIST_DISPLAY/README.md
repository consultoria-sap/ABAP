---
title: "Reuse_Alv_Hierseq_List_Display"
description: "I learned the program BALVHD01_GROUP but I alway got error"
fuente: "Archivo Histórico SAP"
---

# Reuse_Alv_Hierseq_List_Display

I learned the program BALVHD01_GROUP but I alway got error

Runtime Errors ITAB_ILLEGAL_COMPONENT

000690

000700 IF SY-SUBRC NE 0.

000710 RAISE SORTFIELD_NOT_FOUND.

000720 ENDIF.

000730 IF RFLG_AS_TEXT IS INITIAL AND RFLG_STABLE = 'X'.

SORT RT_OUTTAB STABLE

000750 BY (A01) ASCENDING

please help me~ thanks

> h_tps://archive.sap.com/discussions/thread/93748


***

Copyright © 2008-2019 - [www.Consultoria-SAP.com](https://www.Consultoria-SAP.com)
