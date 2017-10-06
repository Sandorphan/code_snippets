
--CREATE ALL ORDER HEADERS REGARLDESS OF STATE

TRUNCATE TABLE tblSCMOrderHeaderAllCurrent
INSERT INTO tblSCMOrderHeaderAllCurrent
SELECT Fld2, Fld3, 
--Manipulation of the date/time creation field to split into two distinct fields - Date only and Tine only
CAST(SUBSTRING(Fld4,4,2) + '-' +  SUBSTRING(Fld4,1,2) + '-' + SUBSTRING(Fld4,7,4) + ' 00:00:00.000' AS DATETIME),
SUBSTRING(Fld4,12,10),
Fld5, Fld6, Fld7, Fld8, Fld9, Fld10, Fld11, Fld12, Fld13, NULL, Fld15, Fld16, Fld17,
Fld18, Fld19, Fld20, Fld21, 
--CTN and Selection Numbers from the TARIFF selection
B.CTN, B.Selection,
Fld22, Fld23,
CAST(SUBSTRING(Fld24,4,2) + '-' +  SUBSTRING(Fld24,1,2) + '-' + SUBSTRING(Fld24,7,4) AS DATETIME) ,
CAST(SUBSTRING(Fld24,12,10) AS VARCHAR(50)),
Fld25, CAST(Fld26 AS MONEY), Fld27
FROM tblSCMTempImport LEFT OUTER JOIN (SELECT Fld2 AS OrderNo, Fld10 AS CTN, Fld7 AS Selection FROM tblSCMTempImport WHERE Fld1 = 'TariffItem') B
ON Fld2 = B.OrderNo
WHERE Fld1 = 'WarehouseDataReportOrder'
AND fld27 LIKE 'Capture%'
GROUP BY Fld2, Fld3, 
--Manipulation of the date/time creation field to split into two distinct fields - Date only and Tine only
CAST(SUBSTRING(Fld4,4,2) + '-' +  SUBSTRING(Fld4,1,2) + '-' + SUBSTRING(Fld4,7,4) + ' 00:00:00.000' AS DATETIME),
SUBSTRING(Fld4,12,10),
Fld5, Fld6, Fld7, Fld8, Fld9, Fld10, Fld11, Fld12, Fld13, Fld15, Fld16, Fld17,
Fld18, Fld19, Fld20, Fld21, 
--CTN and Selection Numbers from the TARIFF selection
B.CTN, B.Selection,
Fld22, Fld23, Fld24, Fld25, CAST(Fld26 AS MONEY), Fld27

DELETE FROM tblSCMOrderHeaderAllHistory WHERE DateLastModified = @OrderDate 

INSERT INTO tblSCMOrderHeaderAllHistory
SELECT * FROM tblSCMOrderHeaderAllCurrent

--HANDSET DATA
DROP TABLE #TempHandsetTest

CREATE TABLE #TempHandsetTest (
	[OrderNumber] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrigOrderNumber] VARCHAR(100),
	[ItemType] VARCHAR(100),
	[CTN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderSelection] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[BAN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrigOrderDate] [datetime] NULL ,
	[OrderStatus] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderType] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderTime] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderUser] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[ModifiedDate] [datetime] NULL ,
	[ModifiedUser] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[DealerCode] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[ProductID] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[ProductDescription] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[ProductQuantity] [int] NULL ,
	[ProductCost] [money] NULL ,
	[ProductPrice] [money] NULL ,
	[ProductOverridePrice] [money] NULL ,
	[IMEINumber] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[WarehouseStatus] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[ProductStatus] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[QuoteDate] DATETIME, 
	[BookedDate] DATETIME, 	
	[DespatchDate] [datetime] NULL ,
	[CancelledDate] DATETIME NULL,
	[ReturnDate] [datetime] NULL,
	[ExchangeFlag] VARCHAR(10) NULL)


INSERT INTO #TempHandsetTest
SELECT B.OrderNumber, SUBSTRING(B.OrderNumber,1,9), fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderStatus, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  CAST(fld10 AS Money), CAST(fld11 AS Money), CAST(fld9 AS MONEY), fld14,fld15, 
'Quote', OrderCreatedDate, NULL, NULL, NULL, NULL,'New'
FROM tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderAllCurrent) B
ON SUBSTRING(fld2,1,9) = SUBSTRING(B.OrderNumber,1,9)
--AND fld3 = B.SelectionNumber
WHERE fld1 IN ('HandsetItem','SIMItem') 
GROUP BY B.OrderNumber,fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate,  B.OrderStatus,B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  fld10, fld11, fld9, fld14,fld15


INSERT INTO #TempHandsetTest
SELECT B.OrderNumber, SUBSTRING(B.OrderNumber,1,9), fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderStatus, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  CAST(fld10 AS Money), CAST(fld11 AS Money), CAST(fld9 AS MONEY), NULL,fld15,
'Quote', OrderCreatedDate, NULL, NULL, NULL, NULL, 'New'
FROM tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderAllCurrent) B
ON SUBSTRING(fld2,1,9) = SUBSTRING(B.OrderNumber,1,9)
--AND fld3 = B.SelectionNumber
WHERE fld1 IN ('DeliveryItem') 
GROUP BY B.OrderNumber,fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate,  B.OrderStatus,B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  fld10, fld11, fld9,  fld15

UPDATE #TempHandsetTest
SET ProductStatus = 'Booked',
BookedDate = ModifiedDate
WHERE WarehouseStatus = (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Picking')

UPDATE #TempHandsetTest
SET ProductStatus = 'Despatched',
DespatchDate = ModifiedDate
WHERE WarehouseStatus = (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Despatched')

UPDATE #TempHandsetTest
SET ProductStatus = 'Despatched',
DespatchDate = ModifiedDate
WHERE ItemType = 'DeliveryItem'

UPDATE #TempHandsetTest
SET BookedDate = DespatchDate
WHERE BookedDate IS NULL AND DespatchDate IS NOT NULL

UPDATE #TempHandsetTest
SET ProductStatus = 'Cancelled',
CancelledDate = ModifiedDate
WHERE WarehouseStatus IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Cancelled')
OR (OrderStatus = 'Return' AND IMEINumber IS NULL AND WarehouseStatus IS NULL AND ItemType IN ('HandsetItem','SIMItem'))

UPDATE #TempHandsetTest
SET ProductStatus = 'Returned',
ReturnDate = ModifiedDate
WHERE WarehouseStatus IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Returned')

UPDATE #TempHandsetTest
SET ProductStatus = 'Returned',
ReturnDate = ModifiedDate
WHERE OrderType = 'Return' AND WarehouseStatus IS NULL
AND IMEINumber IS NOT NULL
AND ItemType IN ('HandsetItem','SIMItem')

UPDATE #TempHandsetTest
SET ExchangeFlag = 'Exchange'
WHERE OrigOrderNumber IN (SELECT OrigOrderNumber FROM #TempHandsetTest WHERE ProductDescription LIKE '%Exchange%')


SELECT * FROM #TempHandsetTest ORDER BY OrderNumber



