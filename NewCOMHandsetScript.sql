
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

INSERT INTO tblSCMOrderHeaderAllHistory
SELECT * FROM tblSCMOrderHeaderAllCurrent



--HANDSET DATA


ALTER PROCEDURE spSCMHardwareFeed @OrderDate DATETIME AS

INSERT INTO tblSCMHardwareFeedHistory
SELECT B.OrderNumber, SUBSTRING(B.OrderNumber,1,9), fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderStatus, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
NULL, NULL,B.DealerCode, '0' + Fld5, fld6, fld7,  CAST(fld10 AS Money), CAST(fld11 AS Money), CAST(fld9 AS MONEY), NULL, NULL,
'Quote', OrderCreatedDate, NULL, NULL, NULL, NULL,'New'
FROM tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderAllCurrent) B
ON SUBSTRING(fld2,1,9) = SUBSTRING(B.OrderNumber,1,9)
--AND fld3 = B.SelectionNumber
WHERE fld1 IN ('HandsetItem','SIMItem','AccessoryItem','DeliveryItem') 
AND B.OrderCreatedDate = @OrderDate
AND B.DateLastModified = @OrderDate
AND B.CTN IS NOT NULL
GROUP BY B.OrderNumber,fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate,  B.OrderStatus,B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DealerCode, '0' + Fld5, fld6, fld7,  fld10, fld11, fld9
ORDER BY CTN

--SELECT * FROM tblSCMHardwareFeedHistory

--Update Handsets and accessories in PICK (Booked) Status
UPDATE tblSCMHardwareFeedHistory
SET BookedDate = C.DateLastModified,
WarehouseStatus = fld15,
ProductStatus = 'Booked'
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllCurrent C
ON A.OrderNumber = C.OrderNumber
WHERE fld15 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Picking')
AND ItemType IN ('HandsetItem','AccessoryItem','SIMItem')

--Update delivery mechanism for picked items
UPDATE tblSCMHardwareFeedHistory
SET BookedDate = C.DateLastModified,
WarehouseStatus = fld19,
ProductStatus = 'Booked',
ProductIDNumber = fld18
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllCurrent C
ON A.OrderNumber = C.OrderNumber
WHERE fld19 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Picking')
AND ItemType IN ('DeliveryItem')


--Update Handsets and accessories in DESPATCHED Status
UPDATE tblSCMHardwareFeedHistory
SET DespatchDate = C.DateLastModified,
WarehouseStatus = fld15,
ProductStatus = 'Despatched',
ProductIDNumber = fld14
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllCurrent C
ON A.OrderNumber = C.OrderNumber
WHERE fld15 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Despatched')
AND ItemType IN ('HandsetItem','AccessoryItem','SIMItem')

--Update Handsets and accessories in DESPATCHED Status
UPDATE tblSCMHardwareFeedHistory
SET DespatchDate = C.DateLastModified,
WarehouseStatus = fld19,
ProductStatus = 'Despatched',
ProductIDNumber = fld18
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllCurrent C
ON A.OrderNumber = C.OrderNumber
WHERE fld19 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Despatched')
AND ItemType IN ('DeliveryItem')

UPDATE tblSCMHardwareFeedHistory
SET BookedDate = DespatchDate
WHERE BookedDate IS NULL and DespatchDate IS NOT NULL

--Update delivery mechanism for returned items
UPDATE tblSCMHardwareFeedHistory
SET ReturnDate = C.DateLastModified,
WarehouseStatus = fld15,
ProductStatus = 'Returned'
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
AND A.ProductIDNumber = fld14
JOIN tblSCMOrderHeaderAllCurrent C
ON A.OrderNumber = C.OrderNumber
WHERE fld15 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Returned')
AND ItemType IN ('HandsetItem','AccessoryItem','SIMItem')

UPDATE tblSCMHardwareFeedHistory
SET ProductStatus = 'Cancelled'
WHERE OrderStatus = 'Cancelled'

UPDATE tblSCMHardwareFeedHistory
SET ExchangeFlag = 'Exchange'
WHERE ProductDescription LIKE '%Exchange%'



--Tidy up Existing SIM and itesm without a product code
DELETE FROM tblSCMHardwareFeedHistory WHERE ProductID IS NULL

DROP TABLE #TmpExchange
CREATE TABLE #TmpExchange (
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
Exchange VARCHAR(100))

INSERT INTO #TmpExchange
SELECT OrderNumber, CTN, ExchangeFlag
FROM tblSCMHardwareFeedHistory WHERE ExchangeFlag = 'Exchange'
AND ProductStatus IN ('Booked','Despatched','Cancelled','Returned')

UPDATE tblSCMHardwareFeedHistory
SET ExchangeFlag = B.Exchange
FROM tblSCMHardwareFeedHistory A JOIN #TmpExchange B
ON A.OrderNumber = B.OrderNumber AND A.CTN = B.CTN
WHERE A.ProductStatus IN ('Booked','Despatched','Cancelled','Returned')




