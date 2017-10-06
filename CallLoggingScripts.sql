SELECT * FROM  dbo.tblACDCallLogs


CREATE TABLE tblCallLoggingCompliance (
CallDate DATETIME,
SwitchID VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
Reporting_Function VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
CallsTaken INT,
CallsLogged INT ) 

TRUNCATE TABLE tblCallLoggingCompliance

INSERT INTO tblCallLoggingCompliance
SELECT CallDate, AgentLogin, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
ACDCalls, NULL
FROM dbo.tblACDDataSummaryHistory 
WHERE AgentLogin IN
(SELECT SwitchID FROM tblACDCallLogs)
AND CallDate >= '06-13-2011'

UPDATE tblCallLoggingCompliance
SET CallsLogged = B.VolCalls
FROM tblCallLoggingCompliance A JOIN tblACDCallLogs B
ON A.SwitchID = B.SwitchID 
AND A.CallDate = b.LogDate

UPDATE tblCallLoggingCompliance
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
Reporting_Function = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblCallLoggingCompliance A JOIN MIReferenceTables.dbo.tbl_Agents B
ON A.SwitchID = B.Switch_ID


SELECT * FROM tblCallLoggingCompliance ORDER BY CallDate