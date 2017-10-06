Declare @MyResultX nvarchar (255)
Declare @MyResultY nvarchar (255)
Declare @MyMessage nvarchar (255)

Set @MyMessage = 'TableSizes - '
Set @MyResultY = ''

Declare MyCursor Cursor For 

Select 
CASE 
	WHEN Substring(Table_Name,1,3) = 'rep' THEN '[' + Substring(Table_Name,8,3) + ']-' + CAST(Cast(CountOfRecords AS Int) AS varchar(10)) + ' '
	ELSE  '[' + Substring(Table_Name,1,6) + ']-' + CAST(Cast(CountOfRecords AS Int) AS varchar(10)) + ' ' END
From ImportValidation order by Table_Name
Open MyCursor

Fetch Next From MyCursor Into @MyResultX

While @@Fetch_Status = 0

BEGIN
Set @MyResultY = @MyResultY +  @MyResultX

Fetch Next From MyCursor Into @MyResultX

End 
SET @MyMessage = 
'07780690690
07917132740

' + @MyResultY
EXEC master.dbo.xp_startmail


EXEC master.dbo.xp_sendmail 
	@recipients = 'singlepointsol@mobile-alert.com',
	@subject = 'thread',
	@message = @MyMessage
	--@query = 'SELECT Table_Name, CAST(CountOfRecords AS Int) AS Records FROM ImportValidation ORDER BY Table_Name',
	--@no_header = 'True'

print @MyMessage

Close MyCursor

Deallocate MyCursor
