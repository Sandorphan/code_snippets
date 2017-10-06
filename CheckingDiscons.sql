SELECT 
CustomerSegment,
BusinessUnit,
Channel,
Department,
Site,
SUM(SameDay),
SUM(OneDay), 
SUM(ShortFuse),
SUM(Notice)
FROM dbo.tblDisconnectionLeakageSummary_History
WHERE RequestWeek = '05/02/2012'
GROUP BY CustomerSegment,
BusinessUnit,
Channel,
Department,
Site



SELECT * FROM dbo.tblDisconnectionLeakageDetail_History
WHERE DisconnectionWeek = '05/02/2012'

DROP TABLE #TempCheck

CREATE TABLE #TempCheck (
CustomerSegment VARCHAR(100),
BusinessUnit VARCHAR(100),
Channel VARCHAR(100), 
Department VARCHAR(100),
Site VARCHAR(100),
CTN VARCHAR(100),
BAN VARCHAR(100),
PlannedDisconnectionDate DATETIME,
DisconnectionType VARCHAR(100),
SameDay INT,
OneDay INT,
ShortFuse INT,
Notice INT,
CurrentSubscriberState VARCHAR(100),
ActualDisconnectionDate DATETIME)

INSERT INTO #TempCheck
SELECT CustomerSegment, BusinessUnit, Channel, Department, Site, CTN, BAN, DisconnectionDate, DisconnectionType, SameDay, OneDay, ShortFuse, Notice, NULL, NULL
FROM dbo.tblDisconnectionLeakageDetail_History
WHERE DisconnectionWeek = '05/02/2012'


UPDATE #TempCheck
SET CurrentSubscriberState = B.Subscriber_Status,
ActualDisconnectionDate = B.Disconnection_Date
FROM #TempCheck A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN


SELECT * FROM #TempCheck ORDER BY CTN