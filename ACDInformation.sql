DECLARE @CallDate DATETIME
SET @CallDate = '04-03-2009'

DROP TABLE #TmpCalls
DROP TABLE #FixCalls
DROP TABLE #TmpOBCalls

CREATE TABLE #TmpCalls (
CampaignType VARCHAR(100), ACDSource VARCHAR(100), CallType VARCHAR(100), CallDate DATETIME, CallWeek VARCHAR(100), CallMonth VARCHAR(100), 
AgentID VARCHAR(100), Agent VARCHAR(100), Team VARCHAR(100), CCM VARCHAR(100), Site VARCHAR(100), Department VARCHAR(100), RFunction VARCHAR(100), Channel VARCHAR(100), BusUnit VARCHAR(100),
Calls INT, DMC INT, ACDTime VARCHAR(8), ACWTime VARCHAR(8), OthTime VARCHAR(8), AuxTime VARCHAR(8), AvailTime VARCHAR(8),  StaffTime VARCHAR(8), ACDOthTime VARCHAR(8), ACWOutTime VARCHAR(8), AuxOutTime VARCHAR(8))

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Stoke', 'Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_Append
WHERE Date = @CallDate

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Warrington','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_WarringtonSaves
WHERE Date = @CallDate

INSERT INTO #TmpCalls
SELECT 'Non Campaign','EBU','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCL_Agent_State_Times_New_Agent_Group_Summary_Ebu
WHERE Date = @CallDate

INSERT INTO #TmpCalls
SELECT 'Non Campaign','Garlands','Inbound', Date, NULL, NULL, Login_ID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
ACD_Calls, ACD_Calls,convert(varchar(8), ACDTime, 108), convert(varchar(8), ACWTime, 108), convert(varchar(8), OtherTime, 108), 
convert(varchar(8), AUXTime, 108), convert(varchar(8), AvailTime, 108), convert(varchar(8), StaffedTime, 108), 
convert(varchar(8), ACD_Other_Time, 108), convert(varchar(8), ACW_Out_Time, 108), convert(varchar(8), Aux_Out_Time, 108)
 FROM SPSVRSQL01.MICampaignSupport.dbo.tblGarlandsCalls_New_Agent_Group_Summary_Garlands
WHERE Date = @CallDate

--Create table for dialler summary
CREATE TABLE #TmpOBCalls (
CampaignType VARCHAR(100), ACDSource VARCHAR(100), CallType VARCHAR(100), CallDate DATETIME, CallWeek VARCHAR(100), CallMonth VARCHAR(100), 
AgentID VARCHAR(100), Agent VARCHAR(100), Team VARCHAR(100), CCM VARCHAR(100), Site VARCHAR(100), Department VARCHAR(100), RFunction VARCHAR(100), Channel VARCHAR(100), BusUnit VARCHAR(100),
Calls INT, DMC INT, ACDTime VARCHAR(8), ACWTime VARCHAR(8), OthTime VARCHAR(8), AuxTime VARCHAR(8), AvailTime VARCHAR(8),  StaffTime VARCHAR(8), ACDOthTime VARCHAR(8), ACWOutTime VARCHAR(8), AuxOutTime VARCHAR(8))

INSERT INTO #TmpOBCalls
SELECT 'Campaign','Dialler','Outbound',Date, NULL, NULL, 
GeminiID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
connects, DMCs, CAST(CAST(ACD_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)), CAST(CAST(ACW_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)),
0, 0, CAST(CAST(Logged_On_Time AS DECIMAL(18,2)) / 86400 AS DECIMAL(18,5)), 0,0,0,0
FROM SPSVRSQL01.MICampaignSupport.dbo.tblCCLAGentStateTimes_RET_agent_performance
WHERE Date = @CallDate


--Create final table of all call activity
CREATE TABLE #FixCalls (
CampaignType VARCHAR(100), ACDSource VARCHAR(100), CallDate DATETIME, CallWeek VARCHAR(100), CallMonth VARCHAR(100), 
AgentID VARCHAR(100), Agent VARCHAR(100), Team VARCHAR(100), CCM VARCHAR(100), Site VARCHAR(100), Department VARCHAR(100), RFunction VARCHAR(100), Channel VARCHAR(100), BusUnit VARCHAR(100),
Calls INT, DMC INT, ACDTime Decimal(18,5), ACWTime Decimal(18,5), OthTime Decimal(18,5), AuxTime Decimal(18,5), AvailTime Decimal(18,5),  StaffTime Decimal(18,5), ACDOthTime Decimal(18,5), ACWOutTime Decimal(18,5), AuxOutTime Decimal(18,5))

INSERT INTO #FixCalls
SELECT CampaignType, ACDSource, CallDate, CallWeek, CallMonth, AgentID, Agent, Team, CCM, Site, Department, RFunction, Channel, BusUnit, 
Calls, DMC, dbo.fnTimeToDec(ACDTime), dbo.fnTimeToDec(ACWTime), dbo.fnTimeToDec(OthTime), dbo.fnTimeToDec(AuxTime), dbo.fnTimeToDec(AvailTime),
dbo.fnTimeToDec(StaffTime), dbo.fnTimeToDec(ACDOthTime), dbo.fnTimeToDec(ACWOutTime), dbo.fnTimeToDec(AuxOutTime)
FROM #TmpCalls

INSERT INTO #FixCalls
SELECT CampaignType, ACDSource, CallDate, CallWeek, CallMonth, AgentID, Agent, Team, CCM, Site, Department, RFunction, Channel, BusUnit, 
Calls, DMC, ACDTime, ACWTime, OthTime, AuxTime, AvailTime, StaffTime, ACDOthTime, ACWOutTime, AuxOutTime
FROM #TmpOBCalls

UPDATE #FixCalls
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction  = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #FixCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Switch_ID
AND A.ACDSource = B.Site

UPDATE #FixCalls
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction  = B.Reporting_Function,
Channel = B.Channel,
BusUnit = B.Business_Unit
FROM #FixCalls A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID



SELECT * FROM #FixCalls WHERE Agent = 'Adam Boone'

--tblMasterDials = Outbound Dialler Calls - Call Volume, DMC, Job Name
--tblTopicalCampaignTypeByDials - Summary of campaign by CTN (Saves)
--ACD Outbound Summary on ACD, no campaign or call vol
