CREATE PROCEDURE spinSpireLBMOutput AS


DECLARE @ProcDate AS VARCHAR(100)
DECLARE @BCP1 AS VARCHAR(200)
DECLARE @BCP2 AS VARCHAR(200)
DECLARE @BCP3 AS VARCHAR(200)
DECLARE @BCP4 AS VARCHAR(200)
DECLARE @BCP5 AS VARCHAR(200)
DECLARE @BCP6 AS VARCHAR(200)


DECLARE @DataDate DATETIME
SET @DataDate = DATEADD(Day,-1,GETDATE())
SET @ProcDate  = 
--The year part
CAST(Datepart(yyyy,@DataDate) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,@DataDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,@DataDate) AS varchar(2))
	ELSE CAST(Datepart(m,@DataDate) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,@DataDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,@DataDate) AS varchar(2))
	ELSE CAST(Datepart(d,@DataDate) AS varchar(2)) END


SET @BCP1 = 'bcp vwInSpireSalesDataCurrentLBM  out \\banftp01\FTP_Reports\CRM_Delivery\CRM_Files\MI_toLBM\Voda_LoadFile_TblInSpireSalesDataCurrent' + @ProcDate + '.txt -S SPSVRSQL01 -T -n'
SET @BCP2 = 'bcp vwInSpireSalesDataSummaryCurrentLBM  out \\banftp01\FTP_Reports\CRM_Delivery\CRM_Files\MI_toLBM\Voda_LoadFile_TblInSpireSalesDataSummaryCurrent' + @ProcDate + '.txt -S SPSVRSQL01 -T -n'
SET @BCP3 = 'bcp vwtblInspireMarginDataSummaryCurrentLBM  out \\banftp01\FTP_Reports\CRM_Delivery\CRM_Files\MI_toLBM\Voda_LoadFile_tblInspireMarginDataSummaryCurrent' + @ProcDate + '.txt -S SPSVRSQL01 -T -n'

EXECUTE MASTER.dbo.xp_cmdshell @BCP1
EXECUTE MASTER.dbo.xp_cmdshell @BCP2
EXECUTE MASTER.dbo.xp_cmdshell @BCP3


CREATE VIEW vwtblInspireMarginDataSummaryCurrentLBM AS
SELECT * FROM tblInspireMarginDataSummary_Daily WHERE Site LIKE '%LBM%'



ALTER PROCEDURE spInSpireLBMImport AS

DECLARE @ProcDate AS VARCHAR(100)
DECLARE @SQL as VARCHAR(200)
DECLARE @DataDate DATETIME
DECLARE @BCPImp1 AS VARCHAR(200)
DECLARE @BCPImp2 AS VARCHAR(200)
DECLARE @BCPImp3 AS VARCHAR(200)
DECLARE @BCPImp4 AS VARCHAR(200)
DECLARE @BCPImp5 AS VARCHAR(200)
DECLARE @BCPImp6 AS VARCHAR(200)


SET @DataDate = DATEADD(Day,-1,GETDATE())
SET @ProcDate  = 
--The year part
CAST(Datepart(yyyy,@DataDate) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,@DataDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,@DataDate) AS varchar(2))
	ELSE CAST(Datepart(m,@DataDate) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,@DataDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,@DataDate) AS varchar(2))
	ELSE CAST(Datepart(d,@DataDate) AS varchar(2)) END



SET @BCPImp1 = '\\banftp01\FTP_Reports\CRM_Delivery\CRM_Files\MI_toLBM\Voda_LoadFile_TblInSpireSalesDataCurrent' + @ProcDate + '.txt'

SET  @SQL = 'BULK INSERT dbo.tblInSpireSalesDataCurrent FROM ''' + @BCPImp1 + ''' '
       + '     WITH (DATAFILETYPE = ''native'') '
EXEC (@SQL)









BULK INSERT dbo.tblInSpireSalesDataCurrentDev from @BCPImp1


PRINT CHAR(39)

