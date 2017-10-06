TRUNCATE TABLE tbl_Transaction_Current_Dev

INSERT INTO tbl_Transaction_Current_Dev
SELECT * FROM tbl_Transaction_History
WHERE Order_Date > '01-31-2009'

UPDATE tbl_Transaction_Current_Dev
SET Dl_Agent_ID = B.OrderCreator
FROM tbl_Transaction_Current_Dev A JOIN dbo.tblSCMOrderHeaderAllHistory B
ON A.CTN = B.CTN AND A.Order_Date = B.DateLastModified
WHERE B.OrderStatus IN (SELECT OrderStatus FROM tblSCMOrderStatus WHERE ValidOrder = 'True')

select * from tbl_Transaction_Current_Dev where ctn in (
'07899968735',
'07795624311',
'07775608559',
'07764983785',
'07747787347')

UPDATE tbl_Transaction_Current_Dev
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
Dl_Flag_C = 'COM_AgentTable'
FROM tbl_Transaction_Current_Dev JOIN MIReferenceTables.dbo.tbl_Agents
ON LTRIM(RTRIM(dl_Agent_id)) = [Crystal_Agent_Name]
WHERE 
dl_Agent_id IS NOT NULL
AND 
LEN([NAME]) <= 100


INSERT INTO tbl_Transaction_Summary_Dev
SELECT * FROM tbl_Transaction_Summary
WHERE Order_Date > '01-31-2009'

UPDATE tbl_Transaction_Summary_Dev
SET Agent_ID = B.Dl_Agent_ID,
Agent = B.Dl_Agent,
Team = B.Dl_Team,
CCmanager = B.Dl_CCM,
Site = B.Dl_Site,
Department = B.Dl_Department,
Reporting_Function = B.Dl_Function,
Channel = B.Dl_Channel,
Business_Unit = B.Dl_BusinessUnit
FROM tbl_Transaction_Summary_Dev A JOIN tbl_Transaction_Current_Dev B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN


select Agent, SUM(Contract_Gross_Volume) from tbl_Transaction_Summary_Dev 
WHERE Department = 'Customer Saves' AND Order_Date > '01-31-2009' GROUP BY Agent


DELETE FROM tbl_Transaction_History WHERE Order_Date > '01-31-2009'
DELETE FROM tbl_Transaction_Summary WHERE Order_Date > '01-31-2009'

INSERT INTO tbl_Transaction_History
SELECT * FROM tbl_Transaction_Current_Dev

INSERT INTO tbl_Transaction_Summary
SELECT * FROM tbl_Transaction_Summary_Dev

EXEC spNotionalProfit_History '02-01-2009'