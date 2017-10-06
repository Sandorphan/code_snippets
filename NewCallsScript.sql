
CREATE TABLE #TmpCalls (
CampaignType VARCHAR(100), ACDSource VARCHAR(100), CallType VARCHAR(100), CallDate DATETIME, CallWeek VARCHAR(100), CallMonth VARCHAR(100), 
AgentID VARCHAR(100), Agent VARCHAR(100), Team VARCHAR(100), CCM VARCHAR(100), Site VARCHAR(100), Department VARCHAR(100), RFunction VARCHAR(100), Channel VARCHAR(100), BusUnit VARCHAR(100),
Calls INT, ValidCalls INT, DMC INT, ACDTime VARCHAR(8), ACWTime VARCHAR(8), OthTime VARCHAR(8), AuxTime VARCHAR(8), AvailTime VARCHAR(8),  StaffTime VARCHAR(8), ACDOthTime VARCHAR(8), ACWOutTime VARCHAR(8), AuxOutTime VARCHAR(8))

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Stoke', 'Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_Append
WHERE Date > DATEADD(d,-5,@CallDate)

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Warrington','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_WarringtonSaves
WHERE Date > DATEADD(d,-5,@CallDate)

INSERT INTO #TmpCalls
SELECT 'Non Campaign','EBU','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_Ebu
WHERE Date > DATEADD(d,-5,@CallDate)

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Garlands','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
FROM SPSVRSQL01.MICampaignSupport.dbo.tblGarlandsCalls_New_Agent_Group_Summary_Garlands
WHERE Date > DATEADD(d,-5,@CallDate) AND  ACDTime > 0



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

--Update EBU AgentInfo


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



UPDATE #TmpCalls
SET ACDTime = '00:00:00', ACWTime = '00:00:00', OthTime = '00:00:00', AuxTime = '00:00:00', AvailTime = '00:00:00', StaffTime = '00:00:00', ACDOthTime = '00:00:00', ACWOutTime = '00:00:00', AuxOutTime = '00:00:00'
WHERE Department IN ('Outbound Retention','Outbound Telesales')

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
FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCLAGentStateTimes_RET_agent_performance
WHERE Date > DATEADD(d,-5,'09-20-2009')

UPDATE #TmpOBCalls
SET ValidCalls = B.Over20Secs
FROM #TmpOBCalls A JOIN MICampaignSupport.dbo.tblOutboundCallsLengthOfCall B
ON A.AgentID = B.GeminiID


