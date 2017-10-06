TRUNCATE TABLE tblSCMHardwareFeedHistory

spSCMHardwareFeedHistory '01-01-2009'

SELECT * FROM tblSCMHardwareFeedHistory AND fld2 = '107337232-2'
SELECT * FROM tblSCMTempImport_History WHERE fld24 > '01-01-2009 00:00:00.000' AND fld24 < '01-01-2009 23:59:00.000'
AND fld1 = 'WarehouseDataReportOrder'
SELECT * FROM tblSCMTempImport_History WHERE fld2 = '107337232-2'
ORDER BY fld1


ALTER PROCEDURE spSCMHardwareFeedHistory @OrderDate DATETIME AS

DELETE FROM tblSCMHardwareFeedHistory WHERE OrigOrderDate = @OrderDate

INSERT INTO tblSCMHardwareFeedHistory
SELECT B.OrderNumber, SUBSTRING(B.OrderNumber,1,9), fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderStatus, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
NULL, NULL,B.DealerCode, '0' + Fld5, fld6, fld7,  CAST(fld10 AS Money), CAST(fld11 AS Money), CAST(fld9 AS MONEY), NULL, NULL,
'Quote', OrderCreatedDate, NULL, NULL, NULL, NULL,'New'
FROM tblSCMTempImport_History JOIN (SELECT * FROM tblSCMOrderHeaderAllHistory WHERE DateLastModified = '01-01-2009') B
ON SUBSTRING(fld2,1,9) = SUBSTRING(B.OrderNumber,1,9)
--AND fld3 = B.SelectionNumber
WHERE fld1 IN ('HandsetItem','SIMItem','AccessoryItem','DeliveryItem') 
AND B.OrderCreatedDate = '01-01-2009'
AND B.CTN IS NOT NULL

GROUP BY B.OrderNumber,fld1, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate,  B.OrderStatus,B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DealerCode, '0' + Fld5, fld6, fld7,  fld10, fld11, fld9
ORDER BY CTN



--Update Handsets and accessories in PICK (Booked) Status
UPDATE tblSCMHardwareFeedHistory
SET BookedDate = C.DateLastModified,
WarehouseStatus = fld15,
ProductStatus = 'Booked'
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport_History
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllHistory C
ON A.OrderNumber = C.OrderNumber
WHERE fld15 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Picking')
AND ItemType IN ('HandsetItem','AccessoryItem','SIMItem')
AND C.DateLastModified = @OrderDate

--Update delivery mechanism for picked items
UPDATE tblSCMHardwareFeedHistory
SET BookedDate = C.DateLastModified,
WarehouseStatus = fld19,
ProductStatus = 'Booked',
ProductIDNumber = fld18
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport_History
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllHistory C
ON A.OrderNumber = C.OrderNumber
WHERE fld19 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Picking')
AND ItemType IN ('DeliveryItem')
AND C.DateLastModified = @OrderDate

--Update Handsets and accessories in DESPATCHED Status
UPDATE tblSCMHardwareFeedHistory
SET DespatchDate = C.DateLastModified,
WarehouseStatus = fld15,
ProductStatus = 'Despatched',
ProductIDNumber = fld14
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport_History
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllHistory C
ON A.OrderNumber = C.OrderNumber
WHERE fld15 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Despatched')
AND ItemType IN ('HandsetItem','AccessoryItem','SIMItem')
AND C.DateLastModified = @OrderDate

--Update Handsets and accessories in DESPATCHED Status
UPDATE tblSCMHardwareFeedHistory
SET DespatchDate = C.DateLastModified,
WarehouseStatus = fld19,
ProductStatus = 'Despatched',
ProductIDNumber = fld18
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport_History
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
JOIN tblSCMOrderHeaderAllHistory C
ON A.OrderNumber = C.OrderNumber
WHERE fld19 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Despatched')
AND ItemType IN ('DeliveryItem')
AND C.DateLastModified = @OrderDate

UPDATE tblSCMHardwareFeedHistory
SET BookedDate = DespatchDate
WHERE BookedDate IS NULL and DespatchDate IS NOT NULL

--Update delivery mechanism for returned items
UPDATE tblSCMHardwareFeedHistory
SET ReturnDate = C.DateLastModified,
WarehouseStatus = fld15,
ProductStatus = 'Returned'
FROM tblSCMHardwareFeedHistory A JOIN tblSCMTempImport_History
ON A.OrderNumber = fld2
AND A.ProductID = '0'+Fld5
AND A.ProductIDNumber = fld14
JOIN tblSCMOrderHeaderAllHistory C
ON A.OrderNumber = C.OrderNumber
WHERE fld15 IN (SELECT StatusChangeCode FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes WHERE StatusType = 'Returned')
AND ItemType IN ('HandsetItem','AccessoryItem','SIMItem')
AND C.DateLastModified = @OrderDate

UPDATE tblSCMHardwareFeedHistory
SET ProductStatus = 'Cancelled'
WHERE OrderStatus = 'Cancelled'


UPDATE tblSCMHardwareFeedHistory
SET ExchangeFlag = 'Exchange'
WHERE ProductDescription LIKE '%Exchange%'


--Tidy up Existing SIM and itesm without a product code
DELETE FROM tblSCMHardwareFeedHistory WHERE ProductID IS NULL AND OrigOrderDate = @OrderDate

--DROP TABLE #TmpExchange
CREATE TABLE #TmpExchange (
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
Exchange VARCHAR(100))

INSERT INTO #TmpExchange
SELECT OrderNumber, CTN, ExchangeFlag
FROM tblSCMHardwareFeedHistory WHERE ExchangeFlag = 'Exchange'
AND ProductStatus IN ('Booked','Despatched','Cancelled','Returned')
--AND C.DateLastModified = @OrderDate

UPDATE tblSCMHardwareFeedHistory
SET ExchangeFlag = B.Exchange
FROM tblSCMHardwareFeedHistory A JOIN #TmpExchange B
ON A.OrderNumber = B.OrderNumber AND A.CTN = B.CTN
WHERE A.ProductStatus IN ('Booked','Despatched','Cancelled','Returned')
--AND C.DateLastModified = @OrderDate




