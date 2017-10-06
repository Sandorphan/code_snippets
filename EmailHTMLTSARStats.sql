
DECLARE @xml NVARCHAR(MAX)DECLARE @body NVARCHAR(MAX)
SET @xml =
CAST(( SELECT CAST(CAST(DATEPART(d,OrderDate) AS VARCHAR(2)) + '/' 
+ CAST(DATEPART(m,OrderDate) AS VARCHAR(2)) + '/' 
+ CAST(DATEPART(yyyy,OrderDate) AS VARCHAR(4)) AS VARCHAR(10)) AS 'td','',
Department AS 'td', '', Site AS 'td', '', SUM(RetentionContracts) AS 'td', '', SUM(Acquisition_Contracts) AS 'td','',
SUM(Inbound_Calls) + SUM(Outbound_Calls) AS 'td', '', SUM(Mandays) AS 'td'
FROM  dbo.tblInspireMarginDataSummaryAccord_History WHERE Channel = 'Call Centre - Sales' AND BusinessUnit = 'CBU' 
AND Department IN ('Customer Retention','Direct Sales inbound','Outbound Retention','High Value Retention','Outbound Telesales')
AND OrderDate > GetDate()-5
GROUP BY OrderDate, Department, Site ORDER BY Department, Site, OrderDate FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))


--This part here defines the heading above your results
--H1 is a large header, down to H6 which is small text
--BG Colour is the background colour of your email - white is usually best!
SET @body ='<html><font face=verdana size=1 color=blue><H4>inSpire Sales Volumes</H4><body bgcolor=white text=black font size=1><table border = 1 bgcolor=white><tr><th>Date</th><th>Agent</th><th>Team</th><th>RetContracts</th><th>AcqContracts</th><th>Calls</th><th>Mandays</th></tr>' 
SET @body = @body + @xml +'</table></body></html>'
EXEC msdb.dbo.sp_send_dbmail
@recipients =N'simon.robinson@vodafone.co.uk',
@body = @body,
@body_format ='HTML',
@subject ='inSpire Summary'