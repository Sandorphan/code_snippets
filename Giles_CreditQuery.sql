CREATE TABLE #SalesData (
CTN VARCHAR(100),
BAN VARCHAR(100),
OrderDate DATETIME,
OrderType VARCHAR(100),
SalesAgent VARCHAR(100),
SalesTM VARCHAR(100),
SalesCCM VARCHAR(100),
SalesDepartment VARCHAR(100),
SalesSite VARCHAR(100),
SalesChannel VARCHAR(100),
SalesBusUnit VARCHAR(100),
CreditNoteDate DATETIME,
CreditNoteCode VARCHAR(100),
CreditNoteValue VARCHAR(100),
CreditNoteAgent VARCHAR(100),
CreditNoteTM VARCHAR(100),
CreditNoteCCM VARCHAR(100),
CreditNoteDepartment VARCHAR(100),
CreditNoteSite VARCHAR(100),
CreditNoteChannel VARCHAR(100),
CreditNoteBusUnit VARCHAR(100))

INSERT INTO #SalesData
SELECT CTN, BAN, OrderDate, OrderType, Agent, Team, CCM, Department, Site, Channel, BusinessUnit, NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
FROM tblinspiresalesdatahistoryaccord WHERE BusinessUnit = 'CBU' AND Channel = 'Call Centre - Sales'
AND ContractGrossVolume = 1 AND OrderDate BETWEEN '05-01-2012' AND '08-31-2012'

UPDATE #SalesData
SET CreditNoteDate = B.Activity_Date,
CreditNoteCode = B.Reason_Code,
CreditNoteValue = B.Amount,
CreditNoteAgent = B.Agent,
CreditNoteTM = B.Team,
CreditNoteCCM = B.CCM,
CreditNoteDepartment = B.Department,
CreditNoteSite = B.Site,
CreditNoteChannel = B.Channel,
CreditNoteBusUnit = B.Business_Unit
FROM #SalesData A JOIN MIStandardMetrics.dbo.tblCreditNotes_History B
ON A.BAN = B.BAN
WHERE B.Activity_Date >= A.OrderDate
AND B.Reason_Code IN ('BILERR', 'BLCERR')


SELECT * FROM #SalesData


SELECT Min(OrderDate), Max(OrderDate) FROM 
tblinspiresalesdatahistoryaccord