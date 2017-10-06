DROP TABLE tblinSpireCostofResolution

CREATE TABLE tblinSpireCostofResolution (
OrderDate DATETIME,
OrderWeek VARCHAR(100),
OrderMonth VARCHAR(100),
OrderType VARCHAR(100),
AgentID VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusUnit VARCHAR(100),
TotalOrders INT,
NoCallbacks INT,
Cat0Callbacks INT,
Cat0Cost MONEY,
Cat1Callbacks INT,
Cat1Cost MONEY,
Cat2Callbacks INT,
Cat2Cost MONEY,
Cat3Callbacks INT,
Cat3Cost MONEY,
Cat4Callbacks INT,
Cat4Cost MONEY,
Cat5Callbacks INT,
Cat5Cost MONEY,
Cat6Callbacks INT,
Cat6Cost MONEY,
Cat7Callbacks INT,
Cat7Cost MONEY,
Cat8Callbacks INT,
Cat8Cost MONEY,
Cat9Callbacks INT,
Cat9Cost MONEY,
Cat10Callbacks INT,
Cat10Cost MONEY )

INSERT INTO tblinSpireCostofResolution
SELECT OrderDate, NULL, NULL, OrderType, AgentID,
Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit,
COUNT(CTN),
SUM(CASE WHEN Callback_Department IS NULL THEN 1 ELSE 0 END),
--Cat0
SUM(CASE WHEN Callback_Department NOT IN ('Small Business','Operations PAYT','ECS','Customer Retention Centre BCS','Digital Service Operations Dept','EBU Small SME Acquisition Small SME Acquisition','EBU TAM','Enterprise Customer Management','One Net - Customer Service','Small Business Inbound Acquisition','Small Business Inbound Retention','Small Business Outbound Retention','SME','SSME','2nd Line Technical','Nursery','1st Line technical','Technical Customer Services','Technical Support','Account management','Complete Care','Customer Care','Post pay','High Value plus','CSA','Customer Services','Customer returns management','DSR/returns','Acquisitions','Customer retention','Direct Sales Inbound','Outbound Retention','Billing and Charging') THEN 1 ELSE 0 END),
0,
--Cat1
SUM(CASE WHEN Callback_Department IN ('Small Business','Operations PAYT','ECS','Customer Retention Centre BCS','Digital Service Operations Dept','EBU Small SME Acquisition Small SME Acquisition','EBU TAM','Enterprise Customer Management','One Net - Customer Service','Small Business Inbound Acquisition','Small Business Inbound Retention','Small Business Outbound Retention','SME','SSME') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('Small Business','Operations PAYT','ECS','Customer Retention Centre BCS','Digital Service Operations Dept','EBU Small SME Acquisition Small SME Acquisition','EBU TAM','Enterprise Customer Management','One Net - Customer Service','Small Business Inbound Acquisition','Small Business Inbound Retention','Small Business Outbound Retention','SME','SSME') THEN 2 ELSE 0 END),
--Cat2
SUM(CASE WHEN Callback_Department IN ('2nd Line Technical') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('2nd Line Technical') THEN 0 ELSE 0 END),
--Cat3
SUM(CASE WHEN Callback_Department IN ('Nursery') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('Nursery') THEN 2 ELSE 0 END),
--Cat4
SUM(CASE WHEN Callback_Department IN ('1st Line technical','Technical Customer Services','Technical Support') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('1st Line technical','Technical Customer Services','Technical Support') THEN 5 ELSE 0 END),
--Cat5
SUM(CASE WHEN Callback_Department IN ('Account management','Complete Care','Customer Care','Post pay','High Value plus','CSA','Customer Services') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('Account management','Complete Care','Customer Care','Post pay','High Value plus','CSA','Customer Services') THEN 10 ELSE 0 END),
--Cat6
SUM(CASE WHEN Callback_Department IN ('Customer returns management','DSR/returns') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('Customer returns management','DSR/returns') THEN 30 ELSE 0 END),
--Cat7
SUM(CASE WHEN Callback_Department IN ('Acquisitions','Customer retention','Direct Sales Inbound','Outbound Retention') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('Acquisitions','Customer retention','Direct Sales Inbound','Outbound Retention') THEN 20 ELSE 0 END),
--Cat8
SUM(CASE WHEN Callback_Department IN ('Billing and Charging') THEN 1 ELSE 0 END),
SUM(CASE WHEN Callback_Department IN ('Billing and Charging') THEN 5 ELSE 0 END),
0,0,
0,0
FROM AUKPIPAW.SIR.dbo.RP_DTL_SIR_SCORE
WHERE Department IN ('Direct Sales Inbound','Outbound Telesales','Outbound Retention','Customer Retention')
AND OrderDate > '06-30-2011'
GROUP BY OrderDate,  OrderType, AgentID, 
Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit


UPDATE tblinSpireCostofResolution
SET OrderWeek = B.WeekText,
OrderMonth = B.MonthText
FROM tblinSpireCostofResolution A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.OrderDate = B.NewDate


SELECT * FROM tblinSpireCostofResolution


