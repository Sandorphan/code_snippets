DROP TABLE #EBURecRept
CREATE TABLE #EBURecRept (
CTN VARCHAR(100),
BAN VARCHAR(100),
inSpireDate DATETIME,
inSpireMonth VARCHAR(100),
inSpireAgentID VARCHAR(100),
inSpireAgent VARCHAR(100),
inSpireDepartment VARCHAR(100),
inSpireChannel VARCHAR(100),
inSpireBusUnit VARCHAR(100), 
inSpireContractPeriod INT,
inSpirePricePlan VARCHAR(100),
EDWDate DATETIME,
EDWMonth VARCHAR(100),
EDWChannel VARCHAR(100),
EDWSubChannel VARCHAR(100),
EDWDealer VARCHAR(100),
EDWSubDealer VARCHAR(100),
EDWConnectionFlag INT,
EDWDisconnectionFlag INT,
EDWNetTariffMigFlag INT,
EDW14DayRetFlag INT,
GeminiSubscriberStatus VARCHAR(20),
SBARPU MONEY,
SBBand VARCHAR(100),
SBSegment VARCHAR(100), 
SBChannel VARCHAR(100),
SBDealerName VARCHAR(100),
SBActDt DATETIME,
SBCommitKeyedDt DATETIME,
inSpire VARCHAR(5),
EDW VARCHAR(100),
SegBase VARCHAR(100),
ReportGroup VARCHAR(100))

TRUNCATE TABLE #EBURecRept

INSERT INTO #EBURecRept
SELECT CTN, BAN, OrderDate, NULL, AgentID, Agent, Department, Channel, BusinessUnit,
ContractGrossPeriod, PricePlanSOC, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Yes', 'No', 'No', 'inSpireOnly'
FROM tblinSpireSalesDataHistoryAccord
WHERE OrderDate > '01-31-2011'
AND OrderType = 'Acquisition'
AND (ContractGrossVolume > 0 OR SIMOnlyVolume > 0)

UPDATE #EBURecRept
SET EDWDate = B.Date,
EDWChannel = B.Acquistion_Channel,
EDWSubChannel = B.Acquistion_Channel_Sub,
EDWDealer = B.Acquisition_Dealer,
EDWSubDealer = B.Acquistion_Dealer_Sub,
EDWConnectionFlag = B.Connections,
EDWDisconnectionFlag = B.Disconnections,
EDWNetTariffMigFlag = B.Net_Tariff_Migration,
EDW14DayRetFlag = B.Return14,
EDW = 'Yes'
FROM #EBURecRept A JOIN vwCMCDataMTD B
ON A.CTN = B.CTN


UPDATE #EBURecRept
SET GeminiSubscriberStatus = B.Subscriber_Status
FROM #EBURecRept A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN


UPDATE #EBURecRept
SET inSPireMonth = B.MonthText
FROM #EBURecRept A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.inSPireDate = B.NewDate


UPDATE #EBURecRept
SET EDWMonth = B.MonthText
FROM #EBURecRept A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.EDWDate = B.NewDate

UPDATE #EBURecRept
SET SBARPU = B.ARPU,
SBBand = B.Band,
SBSegment = B.Segment,
SBChannel = B.Channel,
SBDealerName = B.InitDealerName,
SBActDt = B.ActDt,
SBCommitKeyedDt = B.CommitKeyedDt,
SegBase = 'Yes'
FROM #EBURecRept A JOIN MIStandardMetrics.dbo.tblEBUSegmentation B
ON A.CTN = B.CTN

TRUNCATE TABLE tblEBURecRept

INSERT INTO tblEBURecRept
SELECT * FROM #EBURecRept








SELECT 
inSPireDate, 
CASE WHEN inSpireDepartment IN ('Small Business Inbound Retention','Small Business Inbound Acquisition','Small Business Outbound Acquisition','Small Business Outbound Retention') THEN inSpireAgent
ELSE 'Other Agent/Store' END AS inSpireAgent, 
CASE WHEN inSpireDepartment IN ('Small Business Inbound Retention','Small Business Inbound Acquisition','Small Business Outbound Acquisition','Small Business Outbound Retention') THEN inSpireDepartment
ELSE 'Other Department' END AS inSpireDepartment, inSpireBusUnit,
CASE WHEN inSpireContractPeriod = 0 THEN 'SIMOnly' ELSE 'Contract' END AS ContractType,
GeminiSubscriberStatus,
SUM(SBARPU) AS ARPU, SBSegment, SBChannel, SBDealerName,
CASE
	WHEN inSpire = 'Yes' AND SegBase = 'Yes' THEN 'Match'
	WHEN inSpire = 'Yes' AND SegBase = 'No' THEN 'inSpireOnly' END AS 'TypeFlag',
COUNT(CTN) AS ContractVolume,
SUM(CASE WHEN EDWDate IS NULL THEN 0 ELSE 1 END) AS EDWVolume,
SUM(CASE WHEN SBSegment IS NULL THEN 0 ELSE 1 END) AS SegVolume, inspiremonth
FROM tblEBURecRept WHERE inSpireDepartment LIKE 'Small Business%' OR SBSegment = 'Small Business'
GROUP BY inSPireDate, 
CASE WHEN inSpireDepartment IN ('Small Business Inbound Retention','Small Business Inbound Acquisition','Small Business Outbound Acquisition','Small Business Outbound Retention') THEN inSpireAgent
ELSE 'Other Agent/Store' END, 
CASE WHEN inSpireDepartment IN ('Small Business Inbound Retention','Small Business Inbound Acquisition','Small Business Outbound Acquisition','Small Business Outbound Retention') THEN inSpireDepartment
ELSE 'Other Department' END, inSpireBusUnit,
CASE WHEN inSpireContractPeriod = 0 THEN 'SIMOnly' ELSE 'Contract' END,
GeminiSubscriberStatus, SBSegment, SBChannel, SBDealerName,
CASE
	WHEN inSpire = 'Yes' AND SegBase = 'Yes' THEN 'Match'
	WHEN inSpire = 'Yes' AND SegBase = 'No' THEN 'inSpireOnly' END, inSpireMonth

