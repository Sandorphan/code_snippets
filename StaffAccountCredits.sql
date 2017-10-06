

CREATE TABLE #tblStaffAccountCredits (
TxnDate DATETIME,
CTN VARCHAR(100),
BAN VARCHAR(100),
Agent_ID VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
ProductType VARCHAR(100),
ProductCode VARCHAR(100),
ProductDescription VARCHAR(100),
CreditValue Money,
AccountType VARCHAR(100))

INSERT INTO tblStaffAccountCredits
SELECT Order_Date, CTN, BAN, Txn_Agent_ID, NULL, NULL ,NULL, NULL,NULL, NULL ,NULL, NULL,
Txn_ProductType, Txn_ProductCode, Txn_ProductDescription, Txn_OneOff_Cost, NULL
FROM tbl_Transaction_History
WHERE Txn_ProductType LIKE '%Credit%'
AND ORder_Date > '12-31-2010'


UPDATE tblStaffAccountCredits
SET AccountType = B.Team_ID
FROM tblStaffAccountCredits A JOIN MIReporting.dbo.rep_000805_Current B
ON A.BAN = B.BAN

DELETE FROM tblStaffAccountCredits WHERE AccountType NOT LIKE '%STAF%' OR AccountType IS NULL

UPDATE tblStaffAccountCredits
SET Agent = B.Name, 
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department, 
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblStaffAccountCredits A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.Agent_ID = B.Gemini_ID


UPDATE tblStaffAccountCredits
SET Agent = B.Name, 
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department, 
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblStaffAccountCredits A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.Agent_ID = B.Crystal_Login

SELECT * FROM tblStaffAccountCredits


