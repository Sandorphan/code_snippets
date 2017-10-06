DROP TABLE #TempCTR
DROP TABLE #TempMobInt

CREATE TABLE #TempCTR (
CTN VARCHAR(50) NULL,
Order_Date DATETIME NULL,
Department VARCHAR(50) NULL,
SOC_Code VARCHAR(50) NULL,
SOC_Description VARCHAR(100) NULL,
STCT_Flag INT NULL,
VMI_Meal_Flag INT NULL,
VMI_SOC_Flag INT NULL)

INSERT INTO #TempCTR (CTN, Order_Date, Department, SOC_Code, SOC_Description, STCT_Flag)
SELECT CTN, Order_Date, Dl_Department, Txn_ProductCode, Txn_ProductDescription, 
CASE
	WHEN Dl_Flag_B LIKE '(STCT)%' THEN 1 ELSE 0 END
FROM tbl_Transaction_History 
WHERE Order_Date > '04-30-2008'
AND Txn_ProductType = 'Price Plan'  
AND Dl_Department IN ('Direct Sales Inbound','Inbound Retention','Outbound Retention','Customer Saves','High Value Retention')

UPDATE #TempCTR
SET VMI_Meal_Flag = 1
WHERE SOC_Code LIKE 'VMI%'

CREATE TABLE #TempMobInt (
CTN VARCHAR(50) NULL,
Order_Date VARCHAR(50) NULL,
SOC_Code VARCHAR(50) NULL,
SOC_Description VARCHAR(100) NULL)

INSERT INTO #TempMobInt
SELECT CTN, Order_Date, Txn_ProductCode, Txn_ProductDescription
FROM tbl_transaction_History
WHERE Order_Date > '04-30-2008'
AND (Txn_ProductCode LIKE 'MOBINT001%' OR Txn_ProductCode LIKE 'ATVMI%')
AND Txn_End_Date > Order_Date


UPDATE #TempCTR
SET VMI_SOC_Flag = 1
FROM #TempCTR A JOIN #TempMobInt B
ON A.CTN = B.CTN and A.Order_Date = B.Order_Date

UPDATE #TempCTR
SET VMI_Meal_Flag = 0
WHERE VMI_Meal_Flag IS NULL

UPDATE #TempCTR
SET VMI_SOC_Flag = 0
WHERE VMI_SOC_Flag IS NULL

SELECT * FROM #TempCTR