
--Test EMAIL using new mappings and script
--See http://msdn.microsoft.com/en-us/library/ms187891.aspx for details

EXEC msdb.dbo.sp_send_dbmail 
	@recipients = 'simon.robinson@vodafone.co.uk;dave.hambleton@vodafone.co.uk',
	@subject = 'Test',
	@body =
'Table sizes example
',
	@query = 'SELECT Count(*) FROM MIReporting.dbo.rep_000823_Current'


--Test SMS using new mappings and script
--Will be changed automatically in our ADMIN ALERTS sp's for overnight alerts


EXEC msdb.dbo.sp_send_dbmail 
	@recipients = 'singlepointsol@sms.dialogue.net',
	@subject = 'thread',
	@body = 
'07780690690
07780690690

This is a test 4'
