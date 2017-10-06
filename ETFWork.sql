CREATE TABLE tblInLifeRetention_Current (
ActivityDate DATETIME,
ActivityWeek VARCHAR(100),
ActivityMonth VARCHAR(100),
AgentID VARCHAR(100),
AgentPIN VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
ETFVolume INT,
ETFValue MONEY,
ETFCredits MONEY,
ETFPaidCC MONEY,
ETFDisconections INT,
PACRequests INT,
ContractVolume INT,
SIMOVolume INT,
HandsetVolume INT, 
TariffChanges INT, 
HardwareCost MONEY,
HardwareRevenue MONEY,
SalesCredits INT,
SalesCreditValue MONEY,
Discounts INT,
DiscountsValue MONEY )


CREATE TABLE #ETFFees (
AgentID VARCHAR(100),
Agent VARCHAR(100),
TM VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
MemoDate DATETIME,
VolumeCTN INT,
Value MONEY)


INSERT INTO #ETFFees
SELECT Memo_Agent_ID, B.Name, B.TM, B.CCM, B.Site, B.Department, B.Reporting_Function, B.Channel, B.Business_Unit, Memo_Date, COUNT(CTN), SUM(Amount) 
FROM Topical_2050_Man_Chg A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.Memo_Agent_ID = B.Gemini_ID
WHERE Code = 'PNETRM' AND B.Department = 'InLife Retention'
GROUP BY Memo_Agent_ID, B.Name, B.TM, B.CCM, B.Site, B.Department, B.Reporting_Function, B.Channel, B.Business_Unit, Memo_Date


SELECT * FROM #ETFFees

SELECT * FROm rep_000802_Current WHERE memo_type = '2007'

CREATE TABLE 