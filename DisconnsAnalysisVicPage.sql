
CREATE TABLE #tblDisconnectionLeakageDetail_History(
	[CustomerSegment] [varchar](100) NULL,
	[BusinessUnit] [varchar](100) NULL,
	[Channel] [varchar](100) NULL,
	[RptFunction] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[Site] [varchar](100) NULL,
	[CCM] [varchar](100) NULL,
	[Team] [varchar](100) NULL,
	[Agent] [varchar](100) NULL,
	[AgentID] [varchar](100) NULL,
	[CTN] [varchar](100) NULL,
	[BAN] [varchar](100) NULL,
	[DisconnectionDate] [datetime] NULL,
	[DisconnectionMonth] [varchar](100) NULL,
	[DisconnectionWeek] [varchar](100) NULL,
	[RequestDate] [datetime] NULL,
	[DisconnectionType] [varchar](100) NULL,
	[SameDay] [int] NULL,
	[OneDay] [int] NULL,
	[ShortFuse] [int] NULL,
	[Notice] [int] NULL,
	ConnectionDate DATETIME
)
TRUNCATE TABLE #tblDisconnectionLeakageDetail_History
INSERT INTO #tblDisconnectionLeakageDetail_History

SELECT *, NULL FROM 
dbo.tblDisconnectionLeakageDetail_History
WHERE CustomerSegment = 'Consumer'
AND DisconnectionMonth = '201203 - March'
AND (SameDay = 1 OR OneDay = 1)

UPDATE #tblDisconnectionLeakageDetail_History
SET ConnectionDate = B.Connection_Date
FROM #tblDisconnectionLeakageDetail_History A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN

SELECT * FROM #tblDisconnectionLeakageDetail_History ORDER BY BusinessUnit