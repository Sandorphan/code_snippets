SELECT OrderCreatedDate, Agent_Name, TM, Site, Department, Channel, 
Count(CTN) AS TotalReferals,
SUM(Deal_Given_To_Agent) AS AlreadyPaid,
SUM(Processed_By_Referral_Team) + SUM(Unallocated_Deal) AS ReferedOwing,
SUM(Deal_Given_To_Another_Agent) AS Overpaid
FROM dbo.tblCOMReferrals
GROUP BY OrderCreatedDate, Agent_Name, TM, Site, Department, Channel
ORDER BY OrderCreatedDate


SELECT Agent_Name, TM, Site, Department, Channel, 
Count(CTN) AS TotalReferals,
SUM(Deal_Given_To_Agent) AS AlreadyPaid,
SUM(Processed_By_Referral_Team) + SUM(Unallocated_Deal) AS ReferedOwing,
SUM(Deal_Given_To_Another_Agent) AS Overpaid
FROM dbo.tblCOMReferrals
WHERE OrderCreatedDate > '08-31-2009'
AND Department = 'Customer Retention'
GROUP BY  Agent_Name, TM, Site, Department, Channel


CREATE TABLE tblInSpireReferalSummary_History (
OrderDate DATETIME,
AgentLogin VARCHAR(100),
Agent VARCHAR(100),
TM VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
ReportingFunction VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
OrderType VARCHAR(100),
ReportedContracts INT,
ReportedSIMO INT,
ReportedGNP MONEY,
ReportedCosts MONEY,
ReferedDeals INT,
ReferedAlreadyPaid INT,
ReferedToBePaidExtra INT,
ReferedToBeRemoved INT,
ReferedNetVolume INT)

INSERT INTO tblInSpireReferalSummary_History
SELECT A.OrderCreatedDate, A.OrderCreator, A.Agent_Name, A.TM, NULL, a.Site, A.Department, NULL, A.Channel, NULL, ISNULL(B.OrderType,'Retention'),
NULL, NULL, NULL, NULL,
Count(A.CTN) AS TotalReferals,
SUM(Deal_Given_To_Agent) AS AlreadyPaid,
SUM(Processed_By_Referral_Team) + SUM(Unallocated_Deal) AS ReferedOwing,
SUM(Deal_Given_To_Another_Agent) AS Overpaid,
NULL
FROM dbo.tblCOMReferrals A LEFT OUTER JOIN tblInSpireSalesDataHistory B
ON A.CTN = B.CTN
GROUP BY A.OrderCreatedDate, A.OrderCreator, A.Agent_Name, A.TM,  A.Site, A.Department, A.Channel,  B.OrderType

SELECT * FROM tblInSpireReferalSummary_History

UPDATE tblInSpireReferalSummary_History
SET CCM = B.CCM,
ReportingFunction = B.Reporting_Function,
BusinessUnit = B.Business_Unit
FROM tblInSpireReferalSummary_History A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentLogin = B.Crystal_Login

UPDATE tblInSpireReferalSummary_History
SET ReportedContracts = B.RetentionContracts,
ReportedSIMO = B.Retention_SIMOnly,
ReportedGNP = B.Retention_NotionalProfit,
ReportedCosts = B.RetentionHWCosts + B.RetentionAirCosts
FROM tblInSpireReferalSummary_History A JOIN tblInSpireMarginDataSummary_History B
ON A.OrderDate = B.OrderDate AND A.Agent = B.Agent AND A.TM = B.TM
WHERE OrderType = 'Retention'

UPDATE tblInSpireReferalSummary_History
SET ReportedContracts = B.AcquisitionContracts,
ReportedSIMO = B.Acquisition_SIMOnly,
ReportedGNP = B.Acquisition_NotionalProfit,
ReportedCosts = B.AcquisitionHWCosts + B.AcquisitionAirCosts
FROM tblInSpireReferalSummary_History A JOIN tblInSpireMarginDataSummary_History B
ON A.OrderDate = B.OrderDate AND A.Agent = B.Agent AND A.TM = B.TM
WHERE OrderType = 'Acquisition'

UPDATE tblInSpireReferalSummary_History
SET ReportedContracts = B.MaintenanceVolume,
ReportedSIMO = 0,
ReportedGNP = 0,
ReportedCosts = B.MaintenanceCosts
FROM tblInSpireReferalSummary_History A JOIN tblInSpireMarginDataSummary_History B
ON A.OrderDate = B.OrderDate AND A.Agent = B.Agent AND A.TM = B.TM
WHERE OrderType = 'Maintenance'
