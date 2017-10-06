select * from tblscmhardwarefeedhistory

DROP TABLE #tblSCMReturnsData
CREATE TABLE #tblSCMReturnsData (
OrderID VARCHAR(100),
BookedDate DATETIME,
BookedMonth VARCHAR(100),
DespatchDate DATETIME, 
ReturnProcessStarted DATETIME,
ReturnDate DATETIME,
ReturnType VARCHAR(100),
DaysToReturnProcess INT,
DaysToReturnComplete INT,
ReturnReason VARCHAR(100),
ReturnCategory VARCHAR(100),
AgentID VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusUnit VARCHAR(100),
ReturnAgentID VARCHAR(100),
ReturnAgent VARCHAR(100),
ReturnTeam VARCHAR(100),
ReturnCCM VARCHAR(100),
ReturnSite VARCHAR(100),
ReturnDepartment VARCHAR(100),
ReturnRFunction VARCHAR(100),
ReturnChannel VARCHAR(100),
ReturnBusUnit VARCHAR(100),
CTN VARCHAR(100), 
BAN VARCHAR(100),
ProductCode VARCHAR(20),
ProductDesc VARCHAR(100),
ProductID VARCHAR(100))

INSERT INTO #tblSCMReturnsData
SELECT OrigOrderNumber, BookedDate, NULL, DespatchDate, NULL, ReturnDate, NULL, NULL, NULL, NULL, NULL, OrderUser, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
CTN, BAN, ProductID, ProductDescription, ProductIDNumber
FROM tblscmhardwarefeedhistory A
WHERE BookedDate >= '07-01-2010'
AND ItemType = 'HandsetItem'
AND BookedDate IS NOT NULL

--

UPDATE #tblSCMReturnsData
SET BookedMonth = B.MonthText
FROM #tblSCMReturnsData A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.BookedDate = B.NewDate

UPDATE #tblSCMReturnsData
SET ReturnProcessStarted = B.Date_Order_Raised,
ReturnType = 'Coll_Bag'
FROM #tblSCMReturnsData A JOIN MIReporting.dbo.tblKingfisherSales_History B
ON A.CTN = B.CTN
WHERE B.Date_Order_Raised >= A.BookedDate
AND B.Product_Code = '065046'
AND B.Date_Order_Raised < A.ReturnDate

UPDATE #tblSCMReturnsData
SET ReturnProcessStarted = B.Date_Order_Raised,
ReturnType = 'Coll_Bag'
FROM #tblSCMReturnsData A JOIN MIReporting.dbo.tblKingfisherSales_History B
ON A.CTN = B.CTN
WHERE B.Date_Order_Raised >= A.BookedDate
AND B.Product_Code = '065046'
AND A.ReturnDate IS NULL

-- Need section to identify exchange process

UPDATE #tblSCMReturnsData
SET ReturnType = 'Unknown'
WHERE ReturnDate IS NOT NULL 
AND ReturnProcessStarted IS NULL

UPDATE #tblSCMReturnsData
SET DaysToReturnProcess = DATEDIFF(d,BookedDate, ReturnProcessStarted)
WHERE ReturnProcessStarted IS NOT NULL

UPDATE #tblSCMReturnsData
SET DaysToReturnComplete = DATEDIFF(d,BookedDate, ReturnDate)
WHERE ReturnDate IS NOT NULL


UPDATE #tblSCMReturnsData
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #tblSCMReturnsData A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.AgentID = B.Crystal_Login

UPDATE #tblSCMReturnsData
SET ReturnType = 'None'
WHERE ReturnProcessStarted IS NULL AND ReturnDate IS NULL

DROP TABLE #tblSCMReturnsDataSummary

CREATE TABLE #tblSCMReturnsDataSummary (
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusUnit VARCHAR(100),
DeviceCode VARCHAR(100),
DeviceDescription VARCHAR(100),
VolumeSales INT,
VolumeUnreturned INT,
VolumeReturns INT,
VolumeReturns18 INT,
BookedMonth VARCHAR(100))

INSERT INTO #tblSCMReturnsDataSummary
SELECT Agent, Team, CCM, Site, Department, RFunction, Channel, BusUnit,
ProductCode, ProductDesc, Count(ProductDesc), 
SUM( CASE WHEN DaysToReturnComplete IS NULL THEN 1 ELSE 0 END ),
SUM( CASE WHEN DaysToReturnComplete IS NOT NULL THEN 1 ELSE 0 END ),
SUM( CASE WHEN DaysToReturnComplete < 19 THEN 1 ELSE 0 END ),
BookedMonth
FROM #tblSCMReturnsData
WHERE Agent IS NOT NULL
AND BusUnit = 'CBU' 
AND RFunction = 'Commercial Operations' 
GROUP BY Agent, Team, CCM, Site, Department, RFunction, Channel, BusUnit,
ProductCode, ProductDesc, BookedMonth


SELECT * FROM #tblSCMReturnsDataSummary


