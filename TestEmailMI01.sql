

EXEC spsvrsql01.master.dbo.xp_startmail
EXEC spsvrsql01.master.dbo.xp_sendmail 
	@recipients = 'simon.robinson@vodafone.co.uk;dave.hambleton@vodafone.co.uk;chris.hughes@vodafone.co.uk',

--DL - TSAR Outbound Retention Team Managers; DL - TSAR Customer Saves Team Manager; DL - TSAR Inbound Retention Team Manager (Stoke); DL-TSAR High Value Massive Management Team; DL - TSAR Inbound Telesales Team Manager; DL - Outbound Telesales Management Team; daniel.ward@vodafone.co.uk;paul.jones@vodafone.co.uk;nick.mccoy@vodafone.co.uk;kristian.hunt@vodafone.com;Daniel.Woolley@vodafone.co.uk',
	@subject = 'Testing Server Email Message',
	@message = 'Testing the SQL Mail facility from a stored procedure SPSVRMI01'
	