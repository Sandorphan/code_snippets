UPDATE tbl_Transaction_History
SET Dl_Agent = [Name],
DL_Team = TM,
DL_CCM = CCM,
DL_Department = Department,
DL_Site = Site,
Dl_SiteManager = Site_Manager,
Dl_Function = [Reporting_Function],
Dl_Channel = Channel,
Dl_Segment = Segment,
Dl_BusinessUnit = Business_Unit,
Dl_Flag_C = 'AgentTable'
FROM tbl_Transaction_History JOIN MIReferenceTables.dbo.tbl_Agents
ON dl_Agent_id = Crystal_Login
WHERE Order_Date > '11-30-2010'

UPDATE tbl_Transaction_History
SET Dl_Agent = [Name],
DL_Team = TM,
DL_CCM = CCM,
DL_Department = Department,
DL_Site = Site,
Dl_SiteManager = Site_Manager,
Dl_Function = [Reporting_Function],
Dl_Channel = Channel,
Dl_Segment = Segment,
Dl_BusinessUnit = Business_Unit,
Dl_Flag_C = 'AgentTable'
FROM tbl_Transaction_History JOIN MIReferenceTables.dbo.tbl_Agents
ON dl_Agent_id = Gemini_ID
WHERE Order_Date > '11-30-2010'



UPDATE tbl_Transaction_Summary
SET Agent = B.Name,
Team = B.TM,
CCManager = B.CCM,
Site = B.Site,
Department = B.Department,
Reporting_Function = B.Reporting_Function,
Channel = B.Channel,
Business_Unit = B.Business_Unit
FROM tbl_Transaction_Summary A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.Agent_ID = B.Crystal_Login
WHERE Order_Date > '11-30-2010'


UPDATE tbl_Transaction_Summary
SET Agent = B.Name,
Team = B.TM,
CCManager = B.CCM,
Site = B.Site,
Department = B.Department,
Reporting_Function = B.Reporting_Function,
Channel = B.Channel,
Business_Unit = B.Business_Unit
FROM tbl_Transaction_Summary A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.Agent_ID = B.Gemini_ID
WHERE Order_Date > '11-30-2010'


UPDATE tblinSpireSalesDataHistoryAccord
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblinSpireSalesDataHistoryAccord A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.AgentID = B.Crystal_Login
WHERE OrderDate > '11-30-2010'

UPDATE tblinSpireSalesDataHistoryAccord
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblinSpireSalesDataHistoryAccord A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.AgentID = B.Gemini_ID
WHERE OrderDate > '11-30-2010'

UPDATE tblInSpireCallsFeedHIstory
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireCallsFeedHIstory A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.AgentLogin = B.Switch_ID
WHERE CallDate > '11-30-2010'



EXEC dbo.spInspireOrderTypeUpdate