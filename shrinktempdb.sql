


--backup the database log file and empty it
backup log MICampaignSupport with no_log
--Shrink the database data file
dbcc shrinkfile (MICampaignSupport_Data, 10000)
--Shrink the database log file
dbcc shrinkfile (MICampaignSupport_log, 1500)
--Send out a message
EXEC MIReferenceTables.dbo.spAdminMessages 'Admin','Database Shrunk'
go
--Check the space
sp_spaceused

