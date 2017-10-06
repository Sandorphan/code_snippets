
DELETE FROM tblReportLoggerData
WHERE SystemType = 'Excel'
AND ActionDate IN (SELECT ActionDate FROM  tblReportLoggerCurrent)

INSERT INTO tblReportLoggerData
SELECT 'Excel', Action, ActionDate, ActionTime, 
DATENAME(MM, ActionDate) + ' ' + CAST(YEAR(ActionDate) AS VARCHAR(4)), 
Login, ReportID, ReportPath,
CASE WHEN Left(ReportID,4) = 'CBU-' THEN SUBSTRING(ReportID,18,50)
ELSE ReportID END
FROM tblReportLoggerCurrent

INSERT INTO tblReportLoggerData
SELECT 'SSRS_' + InstanceName , 'Open_Report', 
CONVERT(VARCHAR(10), TimeStart, 120),
CONVERT(VARCHAR(12), TimeStart, 114),
DATENAME(MM, TimeStart) + ' ' + CAST(YEAR(TimeStart) AS VARCHAR(4)),
UserName, Name, Path, Name
FROM AUKPIPAW.ReportServer.dbo.ExecutionLog A 
JOIN AUKPIPAW.ReportServer.dbo.Catalog B 
ON A.ReportID = B.ItemID

INSERT INTO tblReportLoggerData
SELECT 'SSRS_' + InstanceName , 'Open_Report', 
CONVERT(VARCHAR(10), TimeStart, 120),
CONVERT(VARCHAR(12), TimeStart, 114),
DATENAME(MM, TimeStart) + ' ' + CAST(YEAR(TimeStart) AS VARCHAR(4)),
UserName, Name, Path, Name
FROM AUKPIPBW.ReportServer.dbo.ExecutionLog A 
JOIN AUKPIPBW.ReportServer.dbo.Catalog B 
ON A.ReportID = B.ItemID

INSERT INTO tblReportLoggerData
SELECT 'SSRS_' + InstanceName , 'Open_Report', 
CONVERT(VARCHAR(10), TimeStart, 120),
CONVERT(VARCHAR(12), TimeStart, 114),
DATENAME(MM, TimeStart) + ' ' + CAST(YEAR(TimeStart) AS VARCHAR(4)),
UserName, Name, Path, Name
FROM AUKPIDAW.ReportServer.dbo.ExecutionLog A 
JOIN AUKPIDAW.ReportServer.dbo.Catalog B 
ON A.ReportID = B.ItemID
