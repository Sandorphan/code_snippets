CREATE TABLE tblCPWValidation (
CTN VARCHAR(100),
SubscriberStatus VARCHAR(10),
CurrentCommStartDate DATETIME,
CurrCommEndDate DATETIME,
ConnectionDate DATETIME,
LastUpgradeDate DATETIME,
LastUpgradeID VARCHAR(100),
LastUpgradeAgent VARCHAR(100),
LastUpgradeDepartment VARCHAR(100),
LastUpgradeDealerCode VARCHAR(100),
LastUpgradeDealerCodeDetail VARCHAR(100),
LastUpgradeTariff VARCHAR(100),
LastUpgradeGrossContractLength INT,
LastUpgradeNetContractLength INT,
SummaryOrder1 VARCHAR(100),
SummaryOrder2 VARCHAR(100),
SummaryOrder3 VARCHAR(100) )

TRUNCATE TABLE tblCPWValidation


INSERT INTO tblCPWValidation (CTN)
SELECT CTN FROM CPWCTN



UPDATE tblCPWValidation
SET SubscriberStatus = B.Subscriber_Status,
CurrentCommStartDate = B.Commitment_Start_Date,
CurrCommEndDate = B.Commitment_End_Date,
ConnectionDate = B.Connection_Date,
LastUpgradeDealerCode = B.Dealer_Code
FROM tblCPWValidation A JOIN MIReporting.dbo.Rep_000805_Current B
ON A.CTN = B.Subscriber_CTN

UPDATE tblCPWValidation
SET SubscriberStatus = ISNULL(SubscriberStatus,'Not on Libra')

UPDATE tblCPWValidation
SET LastUpgradeDate = B.Order_Date,
LastUpgradeID = B.Agent_ID,
LastUpgradeDealerCode = B.Dealer_Code,
LastUpgradeGrossContractLength = B.Gross_Contract_Length,
LastUpgradeNetContractLength = B.Net_Contract_Length
FROM tblCPWValidation A JOIN dbo.tbl_Contract_Upgrades_History B 
ON A.CTN = B.CTN
WHERE Order_Date > '07-31-2009'
AND Gross_Contract_Length > 11

UPDATE tblCPWValidation
SET LastUpgradeDate = B.Order_Date,
LastUpgradeID = B.Agent_ID,
LastUpgradeDealerCode = B.Dealer_Code,
LastUpgradeGrossContractLength = B.Gross_Contract_Length,
LastUpgradeNetContractLength = B.Net_Contract_Length
FROM tblCPWValidation A JOIN dbo.tbl_Contract_Upgrades_History B 
ON A.CTN = B.CTN
WHERE Order_Date > '07-31-2009'
AND Gross_Contract_Length < 12
AND A.LastUpgradeGrossContractLength IS NULL


UPDATE tblCPWValidation
SET LastUpgradeAgent = B.Name,
LastUpgradeDepartment = B.Department
FROM tblCPWValidation A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.LastUpgradeID = B.Gemini_ID 


UPDATE tblCPWValidation
SET LastUpgradeAgent = B.User_Name,
LastUpgradeDepartment = B.Department
FROM tblCPWValidation A JOIN MIReporting.dbo.rep_000836_Current B
ON A.LastUpgradeID =  B.User_ID 

UPDATE tblCPWValidation
SET LastUpgradeDealerCodeDetail = B.Dealer_Name
FROM tblCPWValidation A JOIN MIReferenceTables.dbo.Tbl_Dealers B
ON A.LastUpgradeDealerCode = B.Dealer_Code

UPDATE tblCPWValidation
SET LastUpgradeTariff = B.SOC_Code
FROM tblCPWValidation A JOIN MIReporting.dbo.rep_000839_PricePlans B
ON A.CTN = B.Subscriber_CTN


SELECT * FROM tblCPWValidation WHERE SummaryOrder1 IS NULL

UPDATE tblCPWValidation
SET SummaryOrder1 = 'RecentContract'
WHERE CurrentCommStartDate > '07-31-2009'
AND LastUpgradeGrossContractLength > 11

UPDATE tblCPWValidation
SET SummaryOrder1 = 'RecentContract'
WHERE CurrentCommStartDate > '07-31-2009'
AND CurrCommEndDate IS NULL

UPDATE tblCPWValidation
SET SummaryOrder1 = 'NoRecentContract'
WHERE CurrentCommStartDate < '07-31-2009'



SELECT * FROM MIReporting.dbo.rep_000802_History WHERE CTN IN (
'07879635160',
'07818274586',
'07747040564',
'07939214924',
'07974349659',
'07825516470',
'07990517546'
)
