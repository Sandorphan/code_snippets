SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderStatus, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  CAST(fld10 AS Money), CAST(fld11 AS Money), CAST(fld9 AS MONEY), fld14,fld12, 'Booked'
FROM tblSCMTempImport_History JOIN (SELECT * FROM tblSCMOrderHeaderHistory) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'HandsetItem'
AND DateLastModified > OrderCreatedDate
AND OrderCreatedDate > '10-31-2008'
AND B.OrderStatus IN (SELECT OrderStatus FROM tblSCMOrderStatus WHERE ValidOrder = 'True')
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate,  B.OrderStatus,B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  fld10, fld11, fld9, fld14,fld12


SELECT * FROM tblSCMTempImport_History WHERE fld1 = 'HandsetItem'
