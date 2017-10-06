USE [MISHRINKAGE]
GO
/****** Object:  Table [dbo].[tblIEXOpenTime_ALL]    Script Date: 01/17/2011 12:18:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

DROP TABLE tblIEXMandaySummary

CREATE TABLE [dbo].[tblIEXMandaySummary](
	[OT_date] [datetime] NULL,
	[IEX_ID] [varchar](155) COLLATE Latin1_General_CI_AS NULL,
	[Agent_name] [varchar](155) COLLATE Latin1_General_CI_AS NULL,
	[Department] [varchar](155) COLLATE Latin1_General_CI_AS NULL,
	[Site] [varchar](155) COLLATE Latin1_General_CI_AS NULL,
	[CCM] [varchar](155) COLLATE Latin1_General_CI_AS NULL,
	[TM] [varchar](155) COLLATE Latin1_General_CI_AS NULL,
	[SwitchID] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Davox_user] [varchar](155) COLLATE Latin1_General_CI_AS NULL,
	[Mandays] DECIMAL(18,2) NULL DEFAULT (0),
	[ProRataMandays] DECIMAL(18,2) NULL DEFAULT (0),
	[OtherMandays] DECIMAL(18,2) NULL DEFAULT (0),
	[EfficiencyMandays] DECIMAL(18,2) NULL DEFAULT (0),
	[PAyroll] [varchar](155) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

TRUNCATE TABLE tblIEXMandaySummary
INSERT INTO tblIEXMandaySummary (
		OT_date,
		IEX_ID,
		Mandays,
		ProRataMandays,
		OtherMandays,
		EfficiencyMandays)
SELECT 	A.sched_date,	A.Agent_ID,	
Sum(CASE WHEN D.MandayInclude = 'Include' THEN A.exec_duration
		ELSE 0		END),
Sum(CASE WHEN D.MandayInclude = 'Pro Rata' THEN A.exec_duration
		ELSE 0		END),
Sum(CASE WHEN D.MandayInclude = 'Exclude'   THEN	A.exec_duration
		ELSE 0	END),
Sum(CASE WHEN D.EfficiencyType = 'Sign On' THEN	A.exec_duration
		ELSE 0	END)
FROM dbo.Local_Reporting_Detail A
			JOIN
				tblMandayreferenceData D
ON A.exec_code = D.Execcode
WHERE 
A.Sched_date >= '01-01-2011'
GROUP BY 	A.sched_date
	,	A.Agent_ID

UPDATE tblIEXMandaySummary
SET SwitchID = B.ACD_ID,
Payroll = B.Payroll_Number
FROM tblIEXMandaySummary A
JOIN dbo.IEX_TeamList B
ON A.IEX_ID = B.Agent_ID

UPDATE tblIEXMandaySummary
SET Agent_Name = B.Name,
Department = B.Department,
Site = B.Site,
CCM = B.CCM,
TM = B.TM
FROM tblIEXMandaySummary A JOIN 
MIReferenceTables.dbo.tbl_Agents B
ON A.SwitchID = B.Switch_ID

UPDATE tblIEXMandaySummary
SET Mandays = Mandays / 1440,
ProRataMandays = ProRatamandays / 1440,
OtherMandays = OtherMandays / 1440,
EfficiencyMandays = EfficiencyMandays / 1440


SELECT * FROM tblIEXMandaySummary WHERE Department = 'Customer Retention'
