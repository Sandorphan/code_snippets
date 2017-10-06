DROP TABLE #TempGiles
CREATE TABLE TempGiles (
ContractDate DATETIME,
BAN VARCHAR(100),
CTN VARCHAR(100),
Agent VARCHAR(100),
Department VARCHAR(100),
Channel VARCHAR(100),
OrderType VARCHAR(100),
ContStart DATETIME,
ContEnd DATETIME,
CreditRaised DATETIME,
CreditAgent VARCHAR(100),
CreditDept VARCHAR(100),
CreditValue MONEY,
CreditReasonCode VARCHAR(100) )

INSERT INTO #TempGiles
SELECT Order_Date,BAN, CTN, Dl_Agent, Dl_Department, 
Txn_Producttype, Dl_ActivityType, Txn_Start_Date, Txn_End_Date, NULL, NULL, NULL, NULL, NULL 
FROM MIStandardMetrics.dbo.tbl_Transaction_History
WHERE Txn_ProductType = 'Contract'
AND Dl_Channel IN ('Call Centre - Sales','Call Centre - Customer','Online','Retail')
AND dl_BusinessUnit = 'CBU'
AND Order_Date BETWEEN '11-01-2011' AND '11-30-2011'

UPDATE #TempGiles
SET CreditRaised = B.Order_Date,
CreditAgent = B.Dl_Agent,
CreditDept = B.Dl_Department,
CreditValue = B.Txn_OneOff_Cost,
CreditReasonCode = B.Txn_ProductCode
FROM #TempGiles A JOIN MIStandardMetrics.dbo.Tbl_Transaction_History B
ON A.BAN = B.BAN
AND B.Order_Date BETWEEN '11-01-2011' AND '12-10-2011'
AND Txn_ProductType LIKE '%credit%'

INSERT INTO tempgiles
SELECT * FROM #TempGiles