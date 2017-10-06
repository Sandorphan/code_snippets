SELECT ActivityMonth,CustomerSegment, SUM(VolumeCredits), SUM(ValueCredits) FROM dbo.tblCreditLeakageDetail_History
WHERE Agent = 'Unknown Agent' AND AgentID IS NOT NULL
GROUP BY ActivityMonth,CustomerSegment
ORDER BY ActivityMonth,CustomerSegment


SELECT DISTINCT AgentID, SUM(VolumeCredits), SUM(ValueCredits) FROM dbo.tblCreditLeakageDetail_History
WHERE Agent = 'Unknown Agent'
AND ActivityMonth = '201204 - April'
GROUP BY AgentID


UPDATE tblCreditLeakageDetail_History
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RptFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblCreditLeakageDetail_History A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID
WHERE Agent = 'Unknown Agent'

TRUNCATE TABLE MIOutputs.dbo.tblCreditLeakageDetail_History
INSERT INTO MIOutputs.dbo.tblCreditLeakageDetail_History
SELECT * FROM tblCreditLeakageDetail_History