DROP TABLE #tblO2BaseSummary

CREATE TABLE #tblO2BaseSummary (
CTN VARCHAR(100),
BAN VARCHAR(100),
SubscriberStatus VARCHAR(10),
AccountType VARCHAR(10),
AccountGroup VARCHAR(100),
TeamID VARCHAR(100),
Network VARCHAR(10),
CustomerName VARCHAR(200),
ConnectionDate DATETIME,
CommitmentStartDate DATETIME,
CommitmentEndDate DATETIME,
DisconnectionDate DATETIME, 
CurrentPricePlan VARCHAR(100) )


INSERT INTO #tblO2BaseSummary
SELECT Subscriber_CTN, BAN, Subscriber_Status, Account_Type, NULL, Team_ID,
Network, NULL, Connection_Date, Commitment_Start_Date, Commitment_End_Date, Disconnection_Date,
NULL FROM MIReporting.dbo.rep_000805_Current
WHERE Network = 'O2'

UPDATE #tblO2BaseSummary
SET AccountGroup = B.Grouping
FROM #tblO2BaseSummary A JOIN MIReferenceTables.dbo.tbl_Gemini_AccountTypes B
ON A.AccountType = B.Account_Type

UPDATE #tblO2BaseSummary
SET CustomerName = B.Name_Title + ' ' + B.First_Name + ' ' + B.Last_Name
FROM #tblO2BaseSummary A JOIN MIReporting.dbo.rep_000852_Current B
ON A.CTN = B.Subscriber_No

UPDATE #tblO2BaseSummary
SET CurrentPricePlan = B.SOC_Code
FROM #tblO2BaseSummary A JOIN MIReporting.dbo.rep_000839_PricePlans B
ON A.CTN = B.Subscriber_CTN
WHERE B.SOC_Service_Type = 'P'


SELECT * FROM #tblO2BaseSummary

