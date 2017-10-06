TRUNCATE TABLE dbo.tblSCMHardwareFeedCurrent

DELETE FROM tblSCMHardwareFeedHistoryFIX WHERE OrigOrderDate IN ('09-13-2011','09-14-2011')

INSERT INTO tblSCMHardwareFeedHistoryFIX
SELECT OrderNumber,OrigOrderNumber,ItemType,CTN,OrderSelection,BAN,OrigOrderDate,OrderStatus,OrderType,OrderTime,OrderUser,ModifiedDate, ModifiedUser,DealerCode,
ProductID, ProductDescription, ProductQuantity, ProductCost, ProductPrice, ProductOverridePrice, ProductIDNumber, WarehouseStatus, ProductStatus, OrigOrderDate,
BookedDate, DespatchDate, CancelledDate, ReturnDate, ExchangeFlag, ReturnProcessUser, ReturnProcessStartDate
FROM dbo.tblSCMHardwareFeedHistory
WHERE OrigOrderDate IN ('09-13-2011','09-14-2011')
GROUP BY OrderNumber,OrigOrderNumber,ItemType,CTN,OrderSelection,BAN,OrigOrderDate,OrderStatus,OrderType,OrderTime,OrderUser,ModifiedDate, ModifiedUser,DealerCode,
ProductID, ProductDescription, ProductQuantity, ProductCost, ProductPrice, ProductOverridePrice, ProductIDNumber, WarehouseStatus, ProductStatus, OrigOrderDate,
BookedDate, DespatchDate, CancelledDate, ReturnDate, ExchangeFlag, ReturnProcessUser, ReturnProcessStartDate

INSERT INTO tblSCMHardwareFeedCurrent
SELECT OrderNumber,OrigOrderNumber,ItemType,CTN,OrderSelection,BAN,OrigOrderDate,NULL,OrderType,OrderTime,OrderUser,NULL, NULL,DealerCode,
ProductID, ProductDescription, ProductQuantity, ProductCost, ProductPrice, ProductOverridePrice, NULL, NULL, NULL, OrigOrderDate, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM dbo.tblSCMHardwareFeedHistoryFIX
GROUP BY OrderNumber,OrigOrderNumber,ItemType,CTN,OrderSelection,BAN,OrigOrderDate,OrderType,OrderTime,OrderUser,DealerCode,
ProductID, ProductDescription, ProductQuantity, ProductCost, ProductPrice, ProductOverridePrice,OrigOrderDate

DROP TABLE #FixMe


CREATE TABLE #FixMe (
OrderNumber VARCHAR(100),
OrderSelection VARCHAR(100),
ProductID VARCHAR(100),
ModifiedDate DATETIME,
ModifiedUser VARCHAR(100),
ProductIDNumber VARCHAR(100),
BookedDate DATETIME,
DespatchDate DATETIME,
CancelledDate DATETIME,
ReturnDate DATETIME )

INSERT INTO #FixMe
SELECT OrderNumber, OrderSelection, ProductID,
Max(ModifiedDate), ModifiedUser, Max(ProductIDNumber),
Min(BookedDate), Min(DespatchDate), Min(CancelledDate), Min(ReturnDate)
FROM tblSCMHardwareFeedHistoryFIX
GROUP BY OrderNumber, OrderSelection, ProductID, ModifiedUser


UPDATE tblSCMHardwareFeedCurrent
SET ModifiedDate = B.ModifiedDate,
ModifiedUser = B.ModifiedUser,
ProductIDNumber = B.ProductIDNumber,
BookedDate = B.BookedDate,
DespatchDate = B.DespatchDate,
CancelledDate = B.CancelledDate,
ReturnDate = B.ReturnDate
FROM tblSCMHardwareFeedCurrent A JOIN #FixMe B
ON A.OrderNumber = B.OrderNumber
AND A.OrderSelection = B.OrderSelection
AND A.ProductID = B.ProductID


SELECT * FROm tblSCMHardwareFeedCurrent
ORDER BY bookeddate


SELECT BookedDate, Count(BookedDate) FROM tblSCMHardwareFeedCurrent GROUP BY BookedDate
ORDER BY BookedDate


DELETE FROM tblSCMHardwareFeedHistory WHERE OrigOrderDate > '08-31-2011'

SELECT * FROM tblSCMHardwareFeedHistory WHERE OrderNumber = '131461196-1'


UPDATE tblSCMHardwareFeedHistory
SET OrderStatus = B.OrderStatus,
WarehouseStatus = CASE WHEN A.ReturnDate IS NOT NULL THEN 'S11' WHEN A.DespatchDate IS NOT NULL THEN 'S02' WHEN A.BookedDate IS NOT NULL THEN 'S01' ELSE NULL END,
ExchangeFlag = B.ExchangeFlag,
ReturnProcessUser = B.ReturnProcessUser,
ReturnProcessStartDate = B.ReturnProcessStartDate
FROM tblSCMHardwareFeedHistory A JOIN tblSCMHardwareFeedHistoryFIX B
ON A.OrderNumber = B.OrderNumber
AND A.OrderSelection = B.OrderSelection
AND A.ProductID = B.ProductID

UPDATE tblSCMHardwareFeedHistory
SET ProductStatus = CASE WHEN WarehouseStatus = 'S01' THEN 'Booked' WHEN WarehouseStatus = 'S02' THEN 'Despatched' WHEN CancelledDate IS NOT NULL THEN 'Cancelled' WHEN WarehouseStatus IS NULL THEN 'Quote' WHEN ReturnDate IS NOT NULL THEN 'Return' ELSE NULL END

SELECT DISTINCT WarehouseStatus, ProductStatus FROM tblSCMHardwareFeedHistory