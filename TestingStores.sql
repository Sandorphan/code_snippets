CREATE TABLE #MissingStoresDates
(Order_Date DATETIME)

INSERT INTO #MissingStoresDates
SELECT NewDate FROM MIReferenceTables.dbo.dbo.tbl_Ref_Dates
WHERE NewDate Between Getdate()-45 AND GetDate()-1

DELETE FROM #MissingStoresDates WHERE Order_Date IN (
SELECT DISTINCT Order_Date FROM tbl_Transaction_History
WHERE DataSource LIKE '%Stores%')  