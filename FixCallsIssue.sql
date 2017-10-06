
DELETE FROM MICampaignSupport.dbo.tblOutboundCallsLengthOfCall
WHERE Call_date > '09-30-2010'

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
AND A.Call_Date > '09-30-2010'
GROUP BY A.call_Date, A.advisor, B.Gemini_ID, B.[name], B.department, B.site, B.TM, B.CCM



TRUNCATE TABLE tblinSpireCallsFeedCurrent
INSERT INTO tblinSpireCallsFeedCurrent
SELECT CallDate, NULL, NULL,
AgentLogin, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
ACDCalls, 0, 0, 0, 0, 0, 0, 
CAST(StaffTime as DECIMAL(18,5))/86400, 0, 0,
CAST(ACDTime as DECIMAL(18,5))/86400, 0, 0,
CAST(ACWTime as DECIMAL(18,5))/86400, 0, 0,
CAST(AvailTime as DECIMAL(18,5))/86400, 0, 0,
CAST(OtherTime as DECIMAL(18,5))/86400, CAST(AuxTime as DECIMAL(18,5))/86400, 
CAST(HoldTime as DECIMAL(18,5))/86400, CAST(Aux0Time as DECIMAL(18,5))/86400, 
CAST(Aux1Time as DECIMAL(18,5))/86400, CAST(Aux2Time as DECIMAL(18,5))/86400, 
CAST(Aux3Time as DECIMAL(18,5))/86400, CAST(Aux4Time as DECIMAL(18,5))/86400, 
CAST(Aux5Time as DECIMAL(18,5))/86400, CAST(Aux6Time as DECIMAL(18,5))/86400, 
CAST(Aux7Time as DECIMAL(18,5))/86400, CAST(Aux8Time as DECIMAL(18,5))/86400, 
CAST(Aux9Time as DECIMAL(18,5))/86400, 
ExtOutCalls, CAST(ExtOutTime as DECIMAL(18,5))/86400, TransferedCalls, 
CAST(ACDOtherTime as DECIMAL(18,5))/86400,
CAST(ACWOutTime as DECIMAL(18,5))/86400, CAST(AuxOutTime as DECIMAL(18,5))/86400,
0, 0, 0, 0
FROM MICampaignSupport.dbo.tblACDDataSummaryHistory
WHERE CallDate > '09-30-2010'

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
WHERE Date > '09-30-2010'
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
WHERE Date  > '09-30-2010'
GROUP BY Name,[Team Manager],Sub_department,department,Date, GeminiID, ACD_Time, ACW_Time, Connects, DMCs, Avail_Time, Logged_On_Time

UPDATE #TmpOBCalls
SET AgentID = B.Switch_ID
FROM #TmpOBCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID


UPDATE tblinSpireCallsFeedCurrent
SET OBDCalls = B.Calls,
OBDCallsConv = B.ValidCalls,
OBDCallsDMC = B.DMC,
OBDStaffTime = B.StaffTime,
OBDTime = B.ACDTime,
OBDACWTime = B.ACWTime, 
OBDAvailTime = B.AvailTime
FROM tblinSpireCallsFeedCurrent A JOIN #TmpOBCalls B
ON A.AgentLogin = B.AgentID
AND A.CallDate = B.CallDate
WHERE CallType = 'Outbound'

UPDATE tblinSpireCallsFeedCurrent
SET IBDCalls = B.Calls,
IBDCallsConv = B.ValidCalls,
IBDCallsDMC = B.DMC,
IBDStaffTime = B.StaffTime,
IBDTime = B.ACDTime,
IBDACWTime = B.ACWTime, 
IBDAvailTime = B.AvailTime
FROM tblinSpireCallsFeedCurrent A JOIN #TmpOBCalls B
ON A.AgentLogin = B.AgentID
AND A.CallDate = B.CallDate
WHERE CallType = 'Inbound'

UPDATE tblinSpireCallsFeedCurrent
SET StaffTime = CASE WHEN StaffTime - (OBDStaffTime + IBDStaffTime) < 0 THEN 0 ELSE
							StaffTime - (OBDStaffTime + IBDStaffTime) END


UPDATE tblinSpireCallsFeedCurrent
SET CallWeek = B.WeekText, CallMonth = B.MonthText
FROM tblinSpireCallsFeedCurrent A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.CallDate = B.NewDate

UPDATE tblinSpireCallsFeedCurrent
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblinSpireCallsFeedCurrent A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentLogin = B.Switch_ID

UPDATE tblinSpireCallsFeedCurrent
SET EfficiencyMandays = B.Expr1
FROM tblinSpireCallsFeedCurrent A
JOIN MIShrinkage.dbo.vwScheduledEfficiency B
ON A.AgentLogin = B.Agent_ID
AND A.CallDate = B.Sched_Date

UPDATE tblinSpireCallsFeedCurrent
SET EfficiencyMandays = CASE WHEN EfficiencyMandays IS NULL THEN 0 ELSE (EfficiencyMandays / 1440) END

UPDATE tblinSpireCallsFeedCurrent
SET InAdherance = (CAST(B.TotalInAdh AS DECIMAL(18,5))/86400),
OutAdherance = (CAST(B.TotalOutAdh AS DECIMAL(18,5))/86400),
Conformance = (CAST(B.TotalAct AS DECIMAL(18,5))/86400) - (CAST(B.TotalSched AS DECIMAL(18,5))/86400)
FROM tblinSpireCallsFeedCurrent A JOIN 
MICampaignSupport.dbo.tblAdheranceHistory B
ON A.AgentLogin = B.LogonID
AND A.CallDate = B.SchedDate

DELETE FROM tblinSpireCallsFeedHistory
WHERE CallDate IN (SELECT CallDate FROM tblinSpireCallsFeedCurrent)

INSERT INTO tblinSpireCallsFeedHistory
SELECT * FROM tblinSpireCallsFeedCurrent

UPDATE tblinSpireCallsFeedHistory
SET EfficiencyMandays = B.Expr1
FROM tblinSpireCallsFeedHistory A
JOIN MIShrinkage.dbo.vwScheduledEfficiency B
ON A.AgentLogin = B.Agent_ID
AND A.CallDate = B.Sched_Date

UPDATE tblinSpireCallsFeedHistory
SET EfficiencyMandays = CASE WHEN EfficiencyMandays IS NULL THEN 0 ELSE (EfficiencyMandays / 1440) END

UPDATE tblinSpireCallsFeedHistory
SET InAdherance = (CAST(B.TotalInAdh AS DECIMAL(18,5))/86400),
OutAdherance = (CAST(B.TotalOutAdh AS DECIMAL(18,5))/86400),
Conformance = (CAST(B.TotalAct AS DECIMAL(18,5))/86400) - (CAST(B.TotalSched AS DECIMAL(18,5))/86400)
FROM tblinSpireCallsFeedHistory A JOIN 
MICampaignSupport.dbo.tblAdheranceHistory B
ON A.AgentLogin = B.LogonID
AND A.CallDate = B.SchedDate