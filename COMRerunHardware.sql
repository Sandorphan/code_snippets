EXEC spSCMHardwareFeed '10-06-2008'
EXEC spSCMHardwareFeed '01-02-2009'
EXEC spSCMHardwareFeed '01-03-2009'
EXEC spSCMHardwareFeed '01-04-2009'
EXEC spSCMHardwareFeed '01-05-2009'
EXEC spSCMHardwareFeed '01-06-2009'
EXEC spSCMHardwareFeed '01-07-2009'
EXEC spSCMHardwareFeed '01-08-2009'
EXEC spSCMHardwareFeed '01-09-2009'
EXEC spSCMHardwareFeed '01-10-2009'
EXEC spSCMHardwareFeed '01-11-2009'




TRUNCATE TABLE tblSCMHardwareFeedHistory

SELECT * from tblSCMTempImport_History WHERE fld1 LIKE 'WarehouseDataReportOrder%'
AND fld4 IS NOT NULL
ORDER BY fld4



--Remove Duplicate Handset Orders from Return and Exchange activity
CREATE TABLE #TmpDupIMEI (
OrigOrderNo VARCHAR(100),
OrderDate DATETIME,
IMEI VARCHAR(100))

INSERT INTO #TmpDupIMEI
SELECT OrigOrderNumber, OrigOrderDate, ProductIDNumber
FROM  dbo.tblSCMHardwareFeedHistory
WHERE ItemType = 'HandsetItem'
AND ProductIDNumber IS NOT NULL

SELECT * FROM #TmpDupIMEI
ORDER BY OrigOrderNo
