
CREATE TABLE #tblOnlineOrderCheck (
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
BAN VARCHAR(100),
DealerCode VARCHAR(100),
DealerName VARCHAR(100),
BookedDate DATETIME,
DespatchDate DATETIME,
ProductCode VARCHAR(100),
ProductDescription VARCHAR(100),
ActiveContract INT,
ReservedContract INT,
SuspendedContract INT,
CancelledContract INT)

INSERT INTO #tblOnlineOrderCheck
SELECT OrderNumber, CTN, BAN, DealerCode, NULL, BookedDate, DespatchDate, ProductID, ProductDescription,
NULL, NULL, NULL, NULL
FROM dbo.tblSCMFrontierHardwareFeedHistory
WHERE ItemType = 'HandsetItem' AND BookedDate > '05-31-2012' AND
(OrderNumber LIKE 'Web%' OR OrderNumber LIKE 'O%' OR OrderNumber LIKE 'WB%')

UPDATE #tblOnlineOrderCheck
SET OrderNumber = REPLACE(OrderNumber, ':ESHOPVENDOR', '')

UPDATE #tblOnlineOrderCheck
SET ActiveContract = 1
WHERE CTN IN (SELECT Subscriber_CTN FROM MIReporting.dbo.rep_000805_Current WHERE Subscriber_Status = 'A')

UPDATE #tblOnlineOrderCheck
SET ReservedContract = 1
WHERE CTN IN (SELECT Subscriber_CTN FROM MIReporting.dbo.rep_000805_Current WHERE Subscriber_Status = 'R')


UPDATE #tblOnlineOrderCheck
SET CancelledContract = 1
WHERE CTN IN (SELECT Subscriber_CTN FROM MIReporting.dbo.rep_000805_Current WHERE Subscriber_Status = 'C')



UPDATE #tblOnlineOrderCheck
SET SuspendedContract = 1
WHERE CTN IN (SELECT Subscriber_CTN FROM MIReporting.dbo.rep_000805_Current WHERE Subscriber_Status = 'S')

UPDATE #tblOnlineOrderCheck
SET DealerName = B.Dealer_Name
FROM #tblOnlineOrderCheck A JOIN MIReferenceTables.dbo.vw_gemini_dealercode B
ON A.DealerCode = B.Dealer_Code


CREATE TABLE #tblOnlineOrderSummary (
OrderDate DATETIME,
DealerCode VARCHAR(100),
DealerName VARCHAR(100),
TotalOrdersPicked INT,
TotalOrdersDespatched INT,
CustomersConnected INT,
CustomersReserved INT,
CustomersSuspended INT,
CustomersCancelled INT )

INSERT INTO #tblOnlineOrderSummary
SELECT BookedDate, DealerCode, DealerName, 
Count(BookedDate),
SUM(CASE WHEN DespatchDate IS NOT NULL THEN 1 ELSE 0 END),
SUM(ISNULL(ActiveContract,0)), SUM(ISNULL(ReservedContract,0)),SUM(ISNULL(SuspendedContract,0)),SUM(ISNULL(CancelledContract,0))
FROM #tblOnlineOrderCheck
GROUP BY BookedDate, DealerCode, DealerName
ORDER BY BookedDate

select * from #tblOnlineOrderCheck WHERE (ReservedContract = 1 OR CancelledContract = 1)
SELECT * FROM #tblOnlineOrderSummary