

DECLARE @orderDate DATETIME, @UpdateDate2 DATETIME
SET @UpdateDate2 = DATEADD(Day,-1,GETDATE())
SET @orderdate  = CONVERT(DATETIME,CAST(YEAR(@UpdateDate2) AS VARCHAR(4)) + '-' + CAST(MONTH(@UpdateDate2) AS VARCHAR(2))  + '-' +  CAST(DAY(@UpdateDate2) AS VARCHAR(2)))


DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME

SET @StartDate = CAST(@OrderDate + ' 00:00:00' AS DATETIME)
SET @EndDate =  CAST(@OrderDate + ' 23:59:59' AS DATETIME)


INSERT INTO tblACDDataSummaryDaily
SELECT CAST(CONVERT(varchar,Date_Interval,101) AS DATETIME),
AgentLogin, AgentName,
SUM(CallsAnswered),
SUM(ACDTime), SUM(ACWTime), SUM(AvailTime), SUM(OtherTime), SUM(AuxTime), SUM(StaffedTime), SUM(HoldTime), 
SUM(AuxTime_0), SUM(AuxTime_1),SUM(AuxTime_2),SUM(AuxTime_3),SUM(AuxTime_4),
SUM(AuxTime_5),SUM(AuxTime_6),SUM(AuxTime_7),SUM(AuxTime_8),SUM(AuxTime_9),
SUM(ExtOutCalls), SUM(ExtOutTime), SUM(TransOut), SUM(ACDOtherTime), SUM(ACWOutTime), 
SUM(AuxOutTime)
 FROM AUKPIDAW.CTEL.dbo.CTEL_dAGENT WITH (NOLOCK)
WHERE Date_Interval BETWEEN @StartDate AND @EndDate
GROUP BY CAST(CONVERT(varchar,Date_Interval,101) AS DATETIME), AgentLogin, AgentName

DELETE FROM tblACDDataSummaryHistory
WHERE CallDate IN (SELECT CallDate FROM tblACDDataSummaryDaily)

INSERT INTO tblACDDataSummaryHistory
SELECT * FROM tblACDDataSummaryDaily

