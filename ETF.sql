DROP TABLE #ETF

CREATE TABLE #ETF (
BAN VARCHAR(50),
CTN VARCHAR(50),
MemoType VARCHAR(50),
MemoAgentID  VARCHAR(50),
MemoSystemText VARCHAR(250),
MemoDate DATETIME,
Agent VARCHAR(50),
Team VARCHAR(50),
CCM VARCHAR(50),
Site VARCHAR(50),
Department VARCHAR(50),
Channel VARCHAR(50),
BusinessUnit VARCHAR(50),
ETFValue MONEY,
CreditNoteValue MONEY)


INSERT INTO #ETF
SELECT BAN, CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, Amount, NULL
FROM dbo.Topical_2050_Man_Chg WHERE Code = 'PNETRM'
AND Memo_Date > '03-31-2012'

UPDATE #ETF
SET CreditNoteValue = B.Amount
FROM #ETF A JOIN MIStandardMetrics.dbo.tblCreditNotes_History B
ON A.BAN = B.BAN AND B.Activity_Date >= A.MemoDate

UPDATE #ETF
SET Agent = B.Name,
Team = B.tm,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM #ETF A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.MemoAgentID = B.Gemini_ID


SELECT * FROM #ETF


