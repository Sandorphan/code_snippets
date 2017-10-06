spInspireCallsSummary '09-21-2010'


ALTER                             PROCEDURE [dbo].[spInspireCallsSummary] @CallDate DATETIME AS

--exec spInspireCalls '20100824'
--Change this variable depending on how many days you wish to reprocess
DROP TABLE #tblInSpireCallsSummaryDaily
DROP TABLE #TmpOBCalls
DROP TABLE #TmpCalls
DROP TABLE #TmpCallsFormat

DECLARE @CallDate DATETIME
SET @CallDate = '10-03-2010'

DECLARE @NoDays AS INT
SET @NoDays = 30


/*            CHECK IF STILL NEEDED



DELETE FROM MICampaignSupport.dbo.tblOutboundCallsLengthOfCall
WHERE Call_date > getdate()-@NoDays

INSERT MICampaignSupport.dbo.tblOutboundCallsLengthOfCall
SELECT 		A.call_date
	,	A.advisor
	,	Isnull(B.Gemini_ID, 'unknown')
	,	Isnull(B.[name], 'unknown')
	,	Isnull(B.department, 'unknown')
	,	Isnull(B.site, 'unknown')
	,	Isnull(B.TM, 'unknown')
	,	Isnull(B.CCM, 'unknown')
	, 	Count(*) as Connects
	,	Sum(Case WHEN talk_time > 19 THEN 1 ELSE 0 END) 
	,	Sum(Case WHEN talk_time <= 19 THEN 1 ELSE 0 END) 
	,	Sum(Case WHEN talk_time > 14 THEN 1 ELSE 0 END) 
	,	Sum(Case WHEN talk_time <= 14 THEN 1 ELSE 0 END) 
	,	Sum(Case WHEN talk_time > 9 THEN 1 ELSE 0 END) 
	,	Sum(Case WHEN talk_time <= 9 THEN 1 ELSE 0 END) 
	,	Sum(Case WHEN talk_time > 4 THEN 1 ELSE 0 END) 
	,	Sum(Case WHEN talk_time <= 4 THEN 1 ELSE 0 END)
--	,	Sum(Case WHEN job_name = 'voda_a4' THEN 1 ELSE 0 END)
	,	Sum(Case WHEN talk_time <= 9 THEN 1 ELSE 0 END)
FROM MICampaignSupport.dbo.tblMasterDials_History A
	LEFT OUTER JOIN
		MIreferenceTables.dbo.tbl_agents B
ON A.Advisor = B.Davox_user
WHERE A.advisor not like ''
AND
A.advisor is not null
AND A.Call_Date > Getdate()-@NoDays
GROUP BY A.call_Date, A.advisor, B.Gemini_ID, B.[name], B.department, B.site, B.TM, B.CCM



*/

--SELECT * FROM MICampaignsupport.dbo.tblOutboundCallsLengthOfCallPlusjobName



--tblOutboundCallsLengthOfCallPlusjobName

CREATE TABLE #TmpCalls (
CampaignType VARCHAR(100), ACDSource VARCHAR(100), CallType VARCHAR(100), CallDate DATETIME, CallWeek VARCHAR(100), CallMonth VARCHAR(100), 
AgentID VARCHAR(100), Agent VARCHAR(100), Team VARCHAR(100), CCM VARCHAR(100), Site VARCHAR(100), Department VARCHAR(100), RFunction VARCHAR(100), Channel VARCHAR(100), BusUnit VARCHAR(100),
Calls INT, ValidCalls INT, DMC INT, ACDTime VARCHAR(8), ACWTime VARCHAR(8), OthTime VARCHAR(8), AuxTime VARCHAR(8), AvailTime VARCHAR(8),  StaffTime VARCHAR(8), ACDOthTime VARCHAR(8), ACWOutTime VARCHAR(8), AuxOutTime VARCHAR(8))

CREATE TABLE #TmpCallsFormat (
CampaignType VARCHAR(100), ACDSource VARCHAR(100), CallType VARCHAR(100), CallDate DATETIME, CallWeek VARCHAR(100), CallMonth VARCHAR(100), 
AgentID VARCHAR(100), Agent VARCHAR(100), Team VARCHAR(100), CCM VARCHAR(100), Site VARCHAR(100), Department VARCHAR(100), RFunction VARCHAR(100), Channel VARCHAR(100), BusUnit VARCHAR(100),
Calls INT, ValidCalls INT, DMC INT, ACDTime DECIMAL(18,5), ACWTime DECIMAL(18,5), OthTime DECIMAL(18,5), AuxTime DECIMAL(18,5), AvailTime DECIMAL(18,5),  StaffTime DECIMAL(18,5), ACDOthTime DECIMAL(18,5), ACWOutTime DECIMAL(18,5), AuxOutTime DECIMAL(18,5))



INSERT INTO #TmpCalls
SELECT 'Non Campaign','Stoke', 'Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_Append
WHERE Date > DATEADD(d,-@NoDays,@CallDate)
--WHERE Date > DATEADD(d,-5,'09-22-2009')

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Warrington','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_WarringtonSaves
WHERE Date > DATEADD(d,-@NoDays,@CallDate)

INSERT INTO #TmpCalls
SELECT 'Non Campaign','EBU','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
FROM MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_Ebu
WHERE Date > DATEADD(d,-@NoDays,@CallDate)

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Garlands','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
FROM MICampaignSupport.dbo.tblGarlandsCalls_New_Agent_Group_Summary_Garlands
WHERE Date > DATEADD(d,-@NoDays,@CallDate) AND  ACDTime > 0

INSERT INTO #TmpCalls
SELECT 'Non Campaign','TSC', 'Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_Sheffield
WHERE Date > DATEADD(d,-@NoDays,@CallDate)
--WHERE Date > DATEADD(d,-5,'09-22-2009')
--

--Fix up outbound areas to remove staff time

UPDATE #TmpCalls
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction  = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #TmpCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Switch_ID
AND A.ACDSource = B.Site

--UPDATED BY MAULTY FOR WF4477

UPDATE #TmpCalls
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction  = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #TmpCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Egain
AND A.ACDSource = B.Site


--EBU 
UPDATE #TmpCalls
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction  = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #TmpCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Switch_ID
WHERE A.ACDSource = 'EBU'
AND A.Agent is NULL
AND B.Business_Unit = 'EBU'

--UPDATED BY MAULTY FOR WF4477

UPDATE #TmpCalls
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction  = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #TmpCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Egain
WHERE A.ACDSource = 'EBU'
AND A.Agent is NULL
AND B.Business_Unit = 'EBU'

/*   REMOVE UNTIL TESTED
UPDATE #TmpCalls
SET ACDTime = '00:00:00', ACWTime = '00:00:00', OthTime = '00:00:00', AuxTime = '00:00:00', AvailTime = '00:00:00', StaffTime = '00:00:00', ACDOthTime = '00:00:00', ACWOutTime = '00:00:00', AuxOutTime = '00:00:00'
WHERE Department IN ('Outbound Retention','Outbound Telesales')

*/

--Create table for dialler summary
CREATE TABLE #TmpOBCalls (
CampaignType VARCHAR(100), ACDSource VARCHAR(100), CallType VARCHAR(100), CallDate DATETIME, CallWeek VARCHAR(100), CallMonth VARCHAR(100), 
AgentID VARCHAR(100), Agent VARCHAR(100), Team VARCHAR(100), CCM VARCHAR(100), Site VARCHAR(100), Department VARCHAR(100), RFunction VARCHAR(100), Channel VARCHAR(100), BusUnit VARCHAR(100),
Calls INT, ValidCalls INT, DMC INT, ACDTime VARCHAR(8), ACWTime VARCHAR(8), OthTime VARCHAR(8), AuxTime VARCHAR(8), AvailTime VARCHAR(8),  StaffTime VARCHAR(8), ACDOthTime VARCHAR(8), ACWOutTime VARCHAR(8), AuxOutTime VARCHAR(8))

INSERT INTO #TmpOBCalls
SELECT 'Campaign','Dialler','Outbound',Date, NULL, NULL, 
GeminiID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
connects, 0, DMCs, CAST(CAST(ACD_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)), CAST(CAST(ACW_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)),
0, 0, CAST(CAST(avail_time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)), CAST(CAST(Logged_On_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)),0,0,0
FROM MICampaignSupport.dbo.tblCCLAGentStateTimes_RET_agent_performance
WHERE Date > DATEADD(d,-@NoDays,@CallDate)
GROUP BY Date, GeminiID, ACD_Time, ACW_Time, Connects, DMCs, Avail_Time, Logged_On_Time

UPDATE #TmpOBCalls
SET ValidCalls = B.EligibleCalls
FROM #TmpOBCalls A JOIN (SELECT GeminiID, Call_Date, IsNull(Total_Connects,0) - IsNull(Total_Ineligible_Calls,0) AS EligibleCalls FROM MICampaignSupport.dbo.tblOutboundCallsLengthOfCall) B
ON A.AgentID = B.GeminiID
AND A.CallDate = B.Call_Date

INSERT INTO #TmpOBCalls
SELECT 'Campaign','InboundDialler','Inbound',Date, NULL, NULL, GeminiID, Name, [Team Manager], Sub_department, NULL, department, NULL, NULL, NULL,
connects, 0, DMCs, 
CAST(CAST(ACD_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)), CAST(CAST(ACW_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)),
0, 0, CAST(CAST(avail_time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)), CAST(CAST(Logged_On_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)),0,0,0
FROM MICampaignSupport.dbo.tblDiallerAGentStateTimes_RET_agent_performance
WHERE Date > DATEADD(d,-@NoDays,@CallDate)
GROUP BY Name,[Team Manager],Sub_department,department,Date, GeminiID, ACD_Time, ACW_Time, Connects, DMCs, Avail_Time, Logged_On_Time

UPDATE #TmpOBCalls
SET AgentID = B.Switch_ID
FROM #TmpOBCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID

--SELECT * FROM #TmpCalls
--SELECT * FROM #TmpOBCalls


CREATE TABLE #tblInSpireCallsSummaryDaily (
CallDate DATETIME,
CallWeek VARCHAR(100),
CallMonth VARCHAR(100),
AgentID VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusUnit VARCHAR(100),
ACDCalls INT,
ACDValidCalls INT,
ACDDMC INT,
ACDTime DECIMAL(18,5),
ACWTime  DECIMAL(18,5),
OthTime DECIMAL(18,5),
AuxTime DECIMAL(18,5),
AvailTime DECIMAL(18,5),
StaffTime DECIMAL(18,5),
ACDOthTime DECIMAL(18,5),
ACWOutTime DECIMAL(18,5),
AuxOutTime DECIMAL(18,5),
OBDiallerCalls INT,
OBDiallerValidCalls INT,
OBDiallerDMC INT,
OBDiallerTime DECIMAL(18,5),
OBDiallerACWTime DECIMAL(18,5),
OBDiallerAvailTime DECIMAL(18,5),
OBDiallerStaffTime DECIMAL(18,5),
IBDiallerCalls INT,
IBDiallerValidCalls INT,
IBDiallerDMC INT,
IBDiallerTime DECIMAL(18,5),
IBDiallerACWTime DECIMAL(18,5),
IBDiallerAvailTime DECIMAL(18,5),
IBDiallerStaffTime DECIMAL(18,5),
ScheduledTime DECIMAL(18,5)
)

INSERT INTO #tblInSpireCallsSummaryDaily
(CallDate, AgentID, OBDiallerCalls, OBDiallerValidCalls, OBDiallerDMC,
OBDiallerTime, OBDiallerACWTime, OBDiallerAvailTime, OBDiallerStaffTime)
SELECT CallDate, AgentID, Calls, ValidCalls, DMC, ACDTime, ACWTime, AvailTime, StaffTime
FROM #TmpOBCalls WHERE CallType = 'Outbound'

UPDATE #tblInSpireCallsSummaryDaily
SET IBDiallerCalls = B.Calls,
IBDiallerValidCalls = B.ValidCalls,
IBDiallerDMC = B.DMC,
IBDiallerTime = B.ACDTime,
IBDiallerACWTime = B.ACWTime,
IBDiallerAvailTime = B.AvailTime,
IBDiallerStaffTime = B.StaffTime
FROM #tblInSpireCallsSummaryDaily A
JOIN #TmpOBCalls B ON A.AgentID = B.AgentID
AND A.CallDate = B.CallDate
WHERE CallType = 'Inbound'



INSERT INTO #TmpCallsFormat
SELECT CampaignType, ACDSource , CallType, CallDate, CallWeek, CallMonth, 
AgentID, Agent, Team , CCM , Site , Department , RFunction , Channel, BusUnit,
Calls , ValidCalls, DMC , dbo.fnTimetoDec(ACDTime), dbo.fnTimetoDec(ACWTime), dbo.fnTimetoDec(OthTime), 
dbo.fnTimetoDec(AuxTime), dbo.fnTimetoDec(AvailTime),  dbo.fnTimetoDec(StaffTime), 
dbo.fnTimetoDec(ACDOthTime), dbo.fnTimetoDec(ACWOutTime), dbo.fnTimetoDec(AuxOutTime)
FROM #TmpCalls



UPDATE #tblInSpireCallsSummaryDaily
SET ACDCalls = B.Calls,
ACDValidCalls = B.ValidCalls,
ACDDMC = B.DMC,
ACDTime = B.ACDTime,
ACWTime = B.ACWTime,
OthTime = B.OthTime,
AuxTime = B.AuxTime,
AvailTime = B.AvailTime,
StaffTime = B.StaffTime,
ACDOthTime = B.ACDOthTime,
ACWOutTime = B.ACWOutTime,
AuxOutTime = B.AuxOutTime
FROM #tblInSpireCallsSummaryDaily A
JOIN #TmpCallsFormat B ON A.AgentID = B.AgentID
AND A.CallDate = B.CallDate
WHERE CallType = 'Inbound'


INSERT INTO #tblInSpireCallsSummaryDaily (CallDate, AgentID, ACDCalls, ACDValidCalls, ACDDMC, ACDTime, ACWTime,
OthTime, AuxTime, AvailTime, StaffTime, ACDOthTime, ACWOutTime, AuxOutTime)
SELECT A.CallDate, A.AgentID, A.Calls, A.ValidCalls, A.DMC, A.ACDTime, A.ACWTime, A.OthTime, A.AuxTime, A.AvailTime, A.StaffTime,
A.ACDOthTime, A.ACWOutTime, A.AuxOutTime
FROM #TmpCallsFormat A
LEFT OUTER JOIN #tblInSpireCallsSummaryDaily B
ON A.AgentID = B.AgentID AND A.CallDate = B.CallDate
WHERE B.CallDate IS NULL

UPDATE #tblInSpireCallsSummaryDaily
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction  = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #tblInSpireCallsSummaryDaily A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Switch_ID

UPDATE #tblInSpireCallsSummaryDaily
SET StaffTime = CASE WHEN StaffTime - (IsNull(OBDiallerStaffTime,0) + IsNull(IBDiallerStaffTime,0)) < 0 THEN 0 ELSE StaffTime - (IsNull(OBDiallerStaffTime,0) + IsNull(IBDiallerStaffTime,0)) END


UPDATE #tblInSpireCallsSummaryDaily
SET ScheduledTime = B.Expr1
FROM #tblInSpireCallsSummaryDaily A
JOIN MIShrinkage.dbo.vwScheduledEfficiency B
ON A.AgentID = B.Agent_ID
AND A.CallDate = B.Sched_Date


UPDATE #tblInSpireCallsSummaryDaily
SET ScheduledTime = CASE WHEN Scheduledtime IS NULL THEN 0 ELSE (ScheduledTime / 1440) END

UPDATE #tblInSpireCallsSummaryDaily
SET CallWeek = B.WeekText,
CallMonth = B.MonthText
FROM #tblInSpireCallsSummaryDaily A
JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.CallDate = B.NewDate

SELECT * FROM #tblInSpireCallsSummaryDaily WHERE Department IN ('Customer Retention','Outbound Retention')
ORDER BY CallDate