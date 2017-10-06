CREATE TABLE tblMasterProcessLog (
MasterProcessName VARCHAR(200),
ProcessDate DATETIME,
ProcessStart DATETIME,
ProcessEnd DATETIME,
ProcessLength INT,
CurrentState VARCHAR(100) )

CREATE TABLE tblMasterProcessReliances (
MasterProcessName VARCHAR(200) )


CREATE PROCEDURE spMasterProcessInit AS

DECLARE @ProcessDate AS DATETIME
SET @ProcessDate = 
CAST(Datepart(yyyy,Getdate()) AS char(4)) + '-' +
	CASE
	WHEN LEN(CAST(Datepart(m,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(m,Getdate()) AS varchar(2)) END + '-' +
CASE
	WHEN LEN(CAST(Datepart(d,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(d,Getdate()) AS varchar(2)) END + ' 00:00:00.000'

INSERT INTO tblMasterProcessLog
SELECT MasterProcessName, @ProcessDate, NULL, NULL, NULL, 'Not Started'
FROM tblMasterProcessReliances

TRUNCATE TABLE tblMasterProcessLog
SELECT * FROM tblMasterProcessReliances



CREATE   PROCEDURE spMasterProcessStart @ProcessName VARCHAR(200) AS

DECLARE @ProcessDate AS DATETIME
SET @ProcessDate = 
CAST(Datepart(yyyy,Getdate()) AS char(4)) + '-' +
	CASE
	WHEN LEN(CAST(Datepart(m,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(m,Getdate()) AS varchar(2)) END + '-' +
CASE
	WHEN LEN(CAST(Datepart(d,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(d,Getdate()) AS varchar(2)) END + ' 00:00:00.000'


UPDATE tblMasterProcessLog 
SET ProcessStart = Getdate(),
CurrentState = 'Running'
WHERE MasterProcessName = @ProcessName
AND ProcessDate = @ProcessDate

EXEC MIReporting.dbo.spMasterProcessStart 'PostImportProcessing'
EXEC MIReporting.dbo.spMasterProcessEnd 'PostImportProcessing'



CREATE PROCEDURE spMasterProcessEnd @ProcessName VARCHAR(200)AS 

DECLARE @ProcessDate AS DATETIME
SET @ProcessDate = 
CAST(Datepart(yyyy,Getdate()) AS char(4)) + '-' +
	CASE
	WHEN LEN(CAST(Datepart(m,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(m,Getdate()) AS varchar(2)) END + '-' +
CASE
	WHEN LEN(CAST(Datepart(d,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(d,Getdate()) AS varchar(2)) END + ' 00:00:00.000'

UPDATE tblMasterProcessLog
SET ProcessEnd = Getdate()
WHERE ProcessEnd IS NULL
AND MasterProcessName = @ProcessName
AND ProcessDate = @ProcessDate

UPDATE tblMasterProcessLog
SET ProcessLength = Datediff(ss,ProcessStart, ProcessEnd),
CurrentState = 'Completed'
WHERE ProcessLength IS NULL
AND MasterProcessName = @ProcessName
AND ProcessDate = @ProcessDate
