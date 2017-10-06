--This part here defines the heading above your results
--H1 is a large header, down to H6 which is small text
--BG Colour is the background colour of your email - white is usually best!
DECLARE @QryX as VARCHAR(500)
Set @QryX = 'SELECT
WF_Ref,
Request_Title,
Date_Requested,
Area_Affected
BC1Name,
BC1Email,
BC1Phone,
BC2Name,
BC2Email,
BC2Phone,
Request_Type,
Process_Queue,
Request_Size,
Status,
Assigned
from dbo.Tbl_Requests A
JOIN dbo.Tbl_MainUser B
ON A.Assigned = B.NTlogin
WHERE Assigned = ' + char(39) + 'robinsons13' + char(39) + '
AND Status NOT IN (' + char(39) + 'Released' + char(39) + ',' + char(39) + 'Cancelled' + char(39) + ') ORDER BY Date_Requested'


PRINT @QryX



EXEC msdb.dbo.sp_send_dbmail
@recipients =N'simon.robinson@vodafone.co.uk',
@body = 'Current Workflow Requests' ,
@body_format ='HTML',
@subject ='Workflow Requests - Current List',
@execute_query_database = 'Workflow',
@query = @QryX


