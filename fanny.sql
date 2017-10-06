SELECT *, CAST(convert(varchar(10), ProcessStart, 108) AS DATETIME) AS ProcessStart, CAST(convert(varchar(10), ProcessEnd, 108) AS DATETIME) AS ProcessEnd, '01-01-1900 08:00:00' AS Target,
(CAST(Datepart(hh,ProcessStart)*60 AS DECIMAL(18,2)) + 
CAST(DatePart(n,ProcessStart) AS DECIMAL(18,2))) /1440 AS ProcStart, 
(CAST(Datepart(hh,ProcessEnd)*60 AS DECIMAL(18,2)) + 
CAST(DatePart(n,ProcessEnd) AS DECIMAL(18,2))) /1440 AS ProcEnd,
0.3333333333333 AS ProcTgt
 FROM tblProcessLog WHERE ProcessName IN 
('Post Transaction Quarantine')
AND ProcessDate > GetDate()-90

,
'spPostImportProcessing - Primary Overnight Routine',
'spInSpireDailyRun - Inspire Daily Run'
--MISSING POST TRANSACTION PROCESSING
--MISSING MASTER DIALLER
--MISSING MAIN DIALLER
--MISSING DIALLER DEPENDENCIES
--MISSING OVERNIGHT IMPORTS
--MISSING EXTERNAL CORE
--MISSING COLLECTIONS
--MISSING RUN DAILY DIALLER FILES
--MISSING POST AFTERNOON JOBS
--MISSING INSPIRE CALLS
--MISSING EVENING ADMINISTRATION
--MISSING WEEKLY RESTORE

--
)