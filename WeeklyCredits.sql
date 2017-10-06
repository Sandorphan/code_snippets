DROP TABLE tblCreditLeakageExecSummary
DROP TABLE #AgentCount
DROP TABLE #AgentCount2

CREATE TABLE tblCreditLeakageExecSummary (
BusinessUnit VARCHAR(100),
Channel VARCHAR(100),
Department VARCHAR(100),
Site VARCHAR(100),
ActivityWeek VARCHAR(100),
VolumeAgents INT,
VolumeCredits INT,
ValueCredits MONEY)

INSERT INTO tblCreditLeakageExecSummary
SELECT BusinessUnit, Channel, Department, Site,  ActivityWeek, NULL, SUM(VolumeCredits), SUM(ValueCredits)
FROM dbo.tblCreditLeakageDetail_History
GROUP BY  BusinessUnit, Channel, Department, Site,  ActivityWeek

CREATE TABLE #AgentCount (
BusinessUnit VARCHAR(100),
Channel VARCHAR(100),
Department VARCHAR(100),
Site VARCHAR(100),
ActivityWeek VARCHAR(100),
AgentID VARCHAR(100))


INSERT INTO #AgentCount
SELECT DISTINCT  BusinessUnit, Channel, Department, Site, ActivityWeek, AgentID 
FROM tblCreditLeakageDetail_History

CREATE TABLE #AgentCount2 (
BusinessUnit VARCHAR(100),
Channel VARCHAR(100),
Department VARCHAR(100),
Site VARCHAR(100),
ActivityWeek VARCHAR(100),
AgentCount INT)

INSERT INTO #AgentCount2
SELECT BusinessUnit, Channel, Department, Site,
 ActivityWeek,  COUNT(AgentID)
FROM  #AgentCount
GROUP BY  BusinessUnit, Channel, Department, Site,
 ActivityWeek



UPDATE tblCreditLeakageExecSummary
SET VolumeAgents = B.AgentCount
FROM tblCreditLeakageExecSummary A JOIN #AgentCount2 B
ON A.BusinessUnit = B.BusinessUnit 
AND A.Channel = B.Channel
AND A.Department = B.Department
AND A.Site = B.Site
AND A.ActivityWeek = B.ActivityWeek


SELECT * FROM tblCreditLeakageExecSummary
where site = 'egypt' and activityweek = '20/11/2011'