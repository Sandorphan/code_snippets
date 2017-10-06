Use MIStandardMetrics

Declare @spName nvarchar (255)
Declare @ArchiveProcess VARCHAR(255)

Declare MyCursor Cursor For 

Select TblName From tblArchiveTables

Open MyCursor

Fetch Next From MyCursor Into @TableName 

While @@Fetch_Status = 0

BEGIN

Set @ArchiveProcess = 'EXECUTE spArchiveProcess ' + @TableName 
Print @ArchiveProcess


Fetch Next From MyCursor Into @TableName

End 

Close MyCursor

Deallocate MyCursor
