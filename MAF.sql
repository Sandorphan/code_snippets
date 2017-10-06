DROP TABLE #MAF

CREATE TABLE #MAF (
CTN VARCHAR(100),
OrderDate DATETIME,
Agent VARCHAR(100),
Team VARCHAR(100),
ControlFlag VARCHAR(100),
ContractFlag VARCHAR(100),
NewTariff VARCHAR(100),
NewLineRental MONEY,
OldTariff VARCHAR(100),
OldLineRental MONEY )

TRUNCATE TABLE #MAF

INSERT INTO #MAF
SELECT CTN, Order_Date, Dl_Agent, Dl_Team,
NULL,
CASE WHEN Txn_Gross_Period > 11 THEN 'Contract' ELSE 'Non Contract' END,
NULL, NULL, NULL, NULL
FROM tbl_Transaction_History 
WHERE Dl_Department = 'Customer Retention' AND Dl_Site = 'Stoke' AND Order_Date > '09-30-2011'
AND Txn_ProductType = 'Contract'



UPDATE #MAF
SET ControlFlag = 'Non Control' WHERE Team IN ('Nina Farr','Karen Machin')

UPDATE #MAF
SET ControlFlag = 'Control' WHERE ControlFlag IS NULL

UPDATE #MAF
SET NewTariff = B.Txn_ProductCode,
NewLineRental = B.Txn_Recurring_Revenue,
OldTariff = B.Dl_Flag_A
FROM #MAF A JOIN Tbl_Transaction_History B
ON A.CTN = B.CTN AND A.OrderDate = B.Order_Date
AND B.Txn_ProductType = 'Price Plan'

UPDATE #MAF 
SET OldLineRental = B.Rate
FROM #MAF A JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.OldTariff = B.SOC_Code

SELECT * FROm #MAF