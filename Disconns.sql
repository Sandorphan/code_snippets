
CREATE TABLE [dbo].[tblDisconnectionLeakageSummary_History](
	[CustomerSegment] [varchar](100) NULL,
	[BusinessUnit] [varchar](100) NULL,
	[Channel] [varchar](100) NULL,
	[RptFunction] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[Site] [varchar](100) NULL,
	[CCM] [varchar](100) NULL,
	[Team] [varchar](100) NULL,
	[Agent] [varchar](100) NULL,
	[AgentID] [varchar](100) NULL,
	[RequestDate] [datetime] NULL,
	RequestWeek VARCHAR(100),
	RequestMonth VARCHAR(100),
	[DisconnectionType] [varchar](100) NULL,
	[SameDay] [int] NULL,
	[OneDay] [int] NULL,
	[ShortFuse] [int] NULL,
	[Notice] [int] NULL
) 

INSERT INTO tblDisconnectionLeakageSummary_History
SELECT CustomerSegment ,	BusinessUnit ,	Channel ,	RptFunction ,	Department ,	Site ,	CCM ,
	Team ,	Agent ,	AgentID ,	DisconnectionDate ,	DisconnectionWeek ,	DisconnectionMOnth ,	DisconnectionType ,	
	SUM(SameDay), SUM(OneDay),	SUM(ShortFuse),	SUM(Notice)
FROM dbo.tblDisconnectionLeakageDetail_History 
GROUP BY CustomerSegment ,	BusinessUnit ,	Channel ,	RptFunction ,	Department ,	Site ,	CCM ,
	Team ,	Agent ,	AgentID ,	DisconnectionDate ,	DisconnectionWeek ,	DisconnectionMOnth  ,	DisconnectionType