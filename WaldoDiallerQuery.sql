SELECT B.name, B.TM, B.CCM, B.Department, A.dial_type, A.call_date, 
A.talk_Time, sum(C.Retention_NotionalProfit) as Retention_NotionalProfit, 
sum(C.RetentionHWCosts) as RetentionHWCosts, sum(C.RetentionAirCosts) as RetentionAirCosts, 
sum(C.Acquisition_NotionalProfit) as Acquisition_NotionalProfit, 
sum(C.AcquisitionHWCosts) as AcquisitionHWCosts, sum(C.AcquisitionAirCosts) as AcquisitionAirCosts, 
C.OrderMonth, C.OrderWeek, C.OrderDate 
from tblMasterDials_history A Join MIReferenceTables.dbo.Tbl_Agents B 
ON A.advisor = B.davox_user Join MIOutputs.dbo.tblInspireMarginDataSummaryACCORD_History C 
ON C.Agent = B.Name Join MIOutputs.dbo.tblInspireMarginDataSummaryACCORD_History ON C.OrderDate = A.Call_Date
where A.dial_type IN ('campaign','voda') and A.call_date > = '2010-09-01 00:00:00.000' and A.talk_Time > 9
GROUP BY B.name, B.TM, B.CCM, B.Department, A.dial_type, A.call_date, A.talk_Time, C.OrderMonth, 
C.OrderWeek, C.OrderDate


CREATE TABLE #tmpWalley (
AgentID VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Department VARCHAR(100),
DialType VARCHAR(100),
CallDate DATETIME,
CallWeek VARCHAR(100),
Callmonth VARCHAR(100),
Calls INT,
GrossNotionalProfit MONEY,
GrossHardwareCosts MONEY,
GrossAirtimeCosts MONEY )

TRUNCATE TABLE #tmpWalley

INSERT INTO #tmpWalley (AgentID, DialType, CallDate, Calls)
SELECT Advisor, Dial_Type, Call_Date,
SUM(CASE WHEN Talk_Time > 9 THEN 1 ELSE 0 END)
FROM MICampaignSupport.dbo.tblMasterDials_History
WHERE Call_Date > '09-30-2010'
AND dial_type IN ('campaign','voda')
GROUP BY Advisor, Dial_Type, Call_Date

UPDATE #tmpWalley
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Department = B.Department
FROM #tmpWalley A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.AgentID = B.Davox_User

UPDATE #tmpWalley
SET CallWeek = B.WeekText,
CallMonth = B.MonthText
FROM #tmpWalley A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.CallDate = B.NewDate


UPDATE #tmpWalley
SET GrossNotionalProfit = B.Retention_NotionalProfit,
GrossHardwareCosts = B.RetentionHWCosts,
GrossAirtimeCosts = B.RetentionAirCosts
FROM #tmpWalley A JOIN dbo.tblInspireMarginDataSummary_History B
ON A.CallDate = B.OrderDate AND A.Agent = B.Agent AND A.Team = B.TM
WHERE A.DialType = 'Voda'

UPDATE #tmpWalley
SET GrossNotionalProfit = B.Acquisition_NotionalProfit,
GrossHardwareCosts = B.AcquisitionHWCosts,
GrossAirtimeCosts = B.AcquisitionAirCosts
FROM #tmpWalley A JOIN dbo.tblInspireMarginDataSummary_History B
ON A.CallDate = B.OrderDate AND A.Agent = B.Agent AND A.Team = B.TM
WHERE A.DialType = 'Campaign'

SELECT * FROM #tmpWalley