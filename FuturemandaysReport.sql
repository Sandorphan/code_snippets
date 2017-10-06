DECLARE @WorkDay AS DATETIME
DECLARE @StartDay AS DATETIME
DECLARE @EndDay AS DATETIME

SET @WorkDay = '07-05-2010'
SET @StartDay = (SELECT FirstDayOfMonth FROM MIReferenceTables.dbo.Tbl_Ref_Dates WHERE NewDate = @WorkDay)
SET @EndDay = (SELECT LastDayOfMonth FROM MIReferenceTables.dbo.Tbl_Ref_Dates WHERE NewDate = @WorkDay)


TRUNCATE TABLE tblInSpireDataForecast
--Set the variable to declare how many hours consitute a working day
DECLARE @WorkingDay AS DECIMAL(18,2)
SET @WorkingDay = 7.5
--Mandays captured as minutes, hence /60 to get manhours
DECLARE @FDay AS DATETIME

SET @FDay = (SELECT FDOM FROM MIReferenceTables.dbo.tbl_datecontrol WHERE YTDay = @Workday)


INSERT INTO tblInSpireDataForecast
SELECT OT_Date, NULL, NULL, Payroll, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
		(Opentime+Opentime_hols+Opentime_train)/60.0/@WorkingDay,
		Opentime/60.0/@WorkingDay,
		opentime_hols/60.0/@WorkingDay,
		Opentime_train/60.0/@WorkingDay,
		Opentime/60.0/@WorkingDay,
NULL, NULL,NULL, NULL, NULL
FROM MIshrinkage.dbo.tblIEXOpentime_ALL
	WHERE TM <> Agent_name
	AND NOT (Agent_Name = 'Vicky Rushton' AND TM = 'Victoria Rushton')
AND OT_Date BETWEEN @StartDay AND @EndDay



UPDATE tblInSpireDataForecast
SET Agent = B.Name,
TM = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireDataForecast A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Employee_ID

UPDATE tblInSpireDataForecast
SET WorkWeek = B.WeekText,
WorkMonth = B.MonthText
FROM tblInSpireDataForecast A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.WorkDate = B.NewDate


UPDATE tblInSpireDataForecast
SET RetentionContractVolume = B.RetentionContracts,
RetentionSIMO = B.Retention_SIMOnly,
AcquisitionContractVolume = B.Acquisition_Contracts,
AcquisitionSIMO = B.Acquisition_SIMOnly
FROM tblInSpireDataForecast A JOIN dbo.tblInspireMarginDataSummaryACCORD_History B
ON A.WorkDate = B.OrderDate AND A.Agent = B.Agent AND A.TM = B.TM
WHERE A.Agent IS NOT NULL

UPDATE tblInSpireDataForecast
SET DateType = CASE WHEN WorkDate < GetDate() THEN 'Current' ELSE 'Future' END





SELECT WorkMonth, Agent, TM, CCM, Site, Department, RFunction, Channel, BusinessUnit,
SUM(CASE WHEN DateType = 'Current' THEN NetManday ELSE 0 END) AS 'MandaysCompleted',
SUM(CASE WHEN DateType = 'Future' THEN NetManday ELSE 0 END) AS 'MandaysForecast',
SUM(ISNULL(RetentionContractVolume,0)) AS RetentionContracts,
SUM(ISNULL(RetentionSIMO,0)) AS RetentionSIMOnly,
SUM(ISNULL(AcquisitionContractVolume,0)) AS AcquisitionContracts,
SUM(ISNULL(AcquisitionSIMO,0)) AS AcquisitionSIMOnly
FROM tblInSpireDataForecast
WHERE BusinessUnit = 'CBU' AND Channel = 'Call Centre - Sales'
GROUP BY WorkMonth, Agent, TM, CCM, Site, Department, RFunction, Channel, BusinessUnit

