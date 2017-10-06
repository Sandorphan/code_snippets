UPDATE tbl_Transaction_History
SET Txn_ProductDescription = B.Handset_Description
FROM tbl_Transaction_History A JOIN MIReporting.dbo.New_Handset_Table B
ON A.txn_ProductCode = B.Oracle_Code
WHERE A.Txn_ProductType = 'Handset'
AND A.Txn_ProductDescription IS NULL

CREATE TABLE #PrimaryHandsets (
CTN VARCHAR(100),
Order_Date DATETIME,
Handset_Description VARCHAR(100))

INSERT INTO #PrimaryHandsets
SELECT CTN, Order_Date, Txn_ProductDescription
FROM tbl_Transaction_History
WHERE Order_Date > '10-31-2008'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_Summary
SET Primary_Handset = B.Handset_Description
FROM tbl_Transaction_Summary A JOIN #PrimaryHandsets B
ON A.CTN = B.CTN AND A.Order_Date = B.Order_Date
WHERE A.Primary_Handset = 'No Handset'
AND A.Order_Date > ' 10-31-2008'