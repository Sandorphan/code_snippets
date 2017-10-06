ALTER PROCEDURE spDailyProcessingSummary AS

--Created by Simon Robinson 10/09/2008
--To assist with daily monitoring of job and process completion
--Relies on logs being generated as part of the overnight and external core processes of job start and finish


TRUNCATE TABLE tblDailyProcessing


INSERT INTO tblDailyProcessing (ProcessName, ProcessGroup)
SELECT DISTINCT ProcessName,ProcessGroup FROM MIReporting.dbo.tblProcessLog
WHERE ProcessDate > GetDate()-30

UPDATE tblDailyProcessing
SET LastRan = B.LastDate
FROM tblDailyProcessing A JOIN (SELECT ProcessName, ProcessGroup, Max(ProcessDate) AS LastDate FROM MIReporting.dbo.tblProcessLog GROUP BY ProcessName, ProcessGroup) B
ON A.ProcessName = B.ProcessName AND A.ProcessGroup = B.ProcessGroup

CREATE TABLE #tmpAvgTimes (
ProcessName VARCHAR(100) NULL,
ProcessGroup VARCHAR(100) NULL,
StartTime VARCHAR(12) NULL,
StartHr VARCHAR(2) NULL,
StartMins VARCHAR(2) NULL,
Duration INT NULL)

INSERT INTO #tmpAvgTimes (ProcessName, ProcessGroup, StartTime, Duration)
SELECT ProcessName, ProcessGroup,
Convert(varchar(10), ProcessStart, 108),ProcessLength
FROM MIReporting.dbo.tblProcessLog
WHERE ProcessDate > GetDate()-30

UPDATE #tmpAvgTimes
SET StartHr = SUBSTRING(StartTime,1,2),
StartMins = SUBSTRING(StartTime,4,2)

CREATE TABLE #tmpAvgTimesSummary (
ProcessName VARCHAR(100) NULL,
ProcessGroup VARCHAR(100) NULL,
AvgStartHr VARCHAR(2) NULL,
AvgStartMins VARCHAR(2) NULL,
AvgDuration INT NULL)

INSERT INTO #tmpAvgTimesSummary
SELECT ProcessName,ProcessGroup, 
CASE WHEN
	LEN(CAST(AVG(CAST(StartHr AS INT))AS VARCHAR(2))) = 1 THEN '0' + CAST(AVG(CAST(StartHr AS INT))AS VARCHAR(2))
	ELSE CAST(AVG(CAST(StartHr AS INT))AS VARCHAR(2)) END,
CASE WHEN
	LEN(CAST(AVG(CAST(StartMins AS INT))AS VARCHAR(2))) = 1 THEN '0' + CAST(AVG(CAST(StartMins AS INT))AS VARCHAR(2))
	ELSE CAST(AVG(CAST(StartMins AS INT))AS VARCHAR(2)) END,
Avg(Duration)
FROM #tmpAvgTimes
GROUP BY ProcessName, ProcessGroup


UPDATE tblDailyProcessing
SET AvgStartTime = B.AvgStartHr + ':' + B.AvgStartMins,
AvgDuration = B.AvgDuration
FROM tblDailyProcessing A JOIN #tmpAvgTimesSummary B
ON A.ProcessName = B.ProcessName AND A.ProcessGroup = B.ProcessGroup


DECLARE @UpdateDate DATETIME, @UpdateDate2 DATETIME
SET @UpdateDate2 = GETDATE()
SET @UpdateDate  = CONVERT(DATETIME,CAST(YEAR(@UpdateDate2) AS VARCHAR(4)) + '-' + CAST(MONTH(@UpdateDate2) AS VARCHAR(2))  + '-' +  CAST(DAY(@UpdateDate2) AS VARCHAR(2)))

UPDATE tblDailyProcessing
SET TodayStartTime = Convert(varchar(10), B.ProcessStart, 108),
TodayEndTime = Convert(varchar(10), B.ProcessEnd, 108),
TodayDuration = B.ProcessLength
FROM tblDailyProcessing A JOIN MIReporting.dbo.tblProcessLog B
ON A.ProcessName = B.ProcessName AND A.ProcessGroup = B.ProcessGroup
WHERE B.ProcessDate = @UpdateDate
