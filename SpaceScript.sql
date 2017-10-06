EXEC MICampaignSupport.dbo.spDBTableSizes 'MICampaignSupport'
EXEC MICompliance.dbo.spDBTableSizes 'MICompliance'
EXEC MICreditOperations.dbo.spDBTableSizes 'MICreditOperations'
EXEC MIDealerCommissions.dbo.spDBTableSizes 'MIDealerCommissions'
EXEC MIReferenceTables.dbo.spDBTableSizes 'MIreferenceTables'
EXEC MIReporting.dbo.spDBTableSizes 'MIReporting'
EXEC MIShrinkage.dbo.spDBTableSizes 'MIShrinkage'
EXEC MIStandardMetrics.dbo.spDBTableSizes 'MIStandardMetrics'

UPDATE MIReferenceTables.dbo.tblDatabaseTableSizesADMIN
SET Table_Size = REPLACE(Table_Size,' KB',''),
Data_Space_USed = REPLACE(Data_Space_USed,' KB',''),
Index_Space_USed = REPLACE(Index_Space_USed,' KB',''),
Unused_Space = REPLACE(Unused_Space,' KB','')


INSERT INTO MIReferenceTables.dbo.tblDatabaseTableSizes
SELECT RunDate, Server_Name, Database_Name, Table_Name,
CAST(Row_Count AS INT),
CAST(Table_Size AS INT),
CAST(Data_Space_Used AS INT),
CAST(Index_Space_Used AS INT),
CAST(Unused_Space AS INT)
FROM MIReferenceTables.dbo.tblDatabaseTableSizesADMIN

SELECT * FROM MIReferenceTables.dbo.tblDatabaseTableSizes ORDER BY RunDate, DataBase_Name