USE MIStandardMetrics
EXEC sp_MSforeachtable @command1="print '?' DBCC DBREINDEX ('?', ' ', 80)"

EXEC MIreferenceTables.dbo.spAdminMessages 'Admin','Std Met ReIndexed'

USE MIReporting
EXEC sp_MSforeachtable @command1="print '?' DBCC DBREINDEX ('?', ' ', 80)"

EXEC MIreferenceTables.dbo.spAdminMessages 'Admin','MI Rep ReIndexed'