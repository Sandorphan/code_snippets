USE Workflow
DECLARE @UName VARCHAR(100)
DECLARE @MailAddress VARCHAR(100)
DECLARE @NTUName VARCHAR(100)

DECLARE MailCursor CURSOR FOR
SELECT NTUserName FROM tblEmailUsers WHERE ReceiveEmail = 'Yes'
OPEN MailCursor

FETCH NEXT FROM MailCursor INTO @NTUName

WHILE @@Fetch_Status = 0

BEGIN



SET @MailAddress = (SELECT EmailAddress FROM tblEmailUsers WHERE NTUserName = @NTUName)
SET @UName = (SELECT FullName FROM tblEmailUsers WHERE NTUserName = @NTUName)

--PRINT @UName +  ' ' + @NTUname + ' ' + @MailAddress
--FETCH NEXT FROM MailCursor INTO @NTUName
--END


DECLARE @xml NVARCHAR(MAX)DECLARE @body NVARCHAR(MAX)
SET @xml =
CAST((SELECT WF_Ref AS 'td', '',
Request_Title AS 'td', '', 
CAST(CAST(DATEPART(d,Date_Requested) AS VARCHAR(2)) + '/' 
+ CAST(DATEPART(m,Date_Requested) AS VARCHAR(2)) + '/' 
+ CAST(DATEPART(yyyy,Date_Requested) AS VARCHAR(4)) AS VARCHAR(10)) AS 'td', '', 
Area_Affected AS 'td','',
BC1Name AS 'td', '', 
BC2Name AS 'td', '', 
Request_Type AS 'td', '', 
Process_Queue AS 'td', '', 
Request_Size AS 'td', '', 
Status AS 'td'
from dbo.Tbl_Requests A
WHERE A.Assigned = @NTUName
AND Status NOT IN ('Released','Cancelled') ORDER BY Date_Requested FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))


SET @body = '<html><font face=arial narrow>Current workflow requests in progress<BR><BR>Access the BI Workflow Tool <a href="http://regapp057/rm/miportal.aspx">HERE</a> to update <BR><BR><BR><body><table border = "1" style="font-size:10px;"><tr><th>WF Ref</th><th>Title</th><th>Date Req</th><th>Bus Area</th><th>Requestor1</th><th>Requestor2</th><th>RequestType</th><th>Queue</th><th>Size</th><th>STATUS</th></tr>'
SET @body = @body + @xml +'</table></body></html>'
EXEC msdb.dbo.sp_send_dbmail
@recipients = @MailAddress,
@body = @body,
@body_format ='HTML',
@subject ='WorkFlow Request Summary'



FETCH NEXT FROM MailCursor INTO @NTUName

END

CLOSE MailCursor

DEALLOCATE MailCursor



