CREATE TABLE #SUIMigrationSTCT(
Orig_Order_Date DATETIME NULL,
CTN VARCHAR(50) NULL,
BAN VARCHAR(50) NULL,
Agent VARCHAR(100) NULL,
Team VARCHAR(100) NULL,
CCM VARCHAR(100) NULL,
Department VARCHAR(100) NULL,
Site VARCHAR(100) NULL,
Contract_Length INT NULL,
Tariff_Code VARCHAR(50) NULL,
Tariff_Description VARCHAR(100) NULL,
Line_Rental MONEY NULL,
STCT_Flag VARCHAR(10) NULL,
SUI_RIV MONEY NULL,
Commercial_Cost_Fixed MONEY NULL,
Commercial_Cost_Recurring MONEY NULL,
Current_Tariff_Code VARCHAR(50) NULL,
Current_Tariff_Description VARCHAR(100),
Current_Line_Rental MONEY NULL,
Actual_Commercial_Cost_Fixed MONEY NULL,
Actual_Commercial_Cost_Recurring MONEY NULL)

INSERT INTO #SUIMigrationSTCT (Orig_Order_Date, CTN, BAN, Agent, Team, CCM, Department, Site, Contract_Length, SUI_RIV)
SELECT Order_Date, CTN, BAN, Dl_Agent, Dl_Team, Dl_CCM, Dl_Department, Dl_Site, Txn_Gross_Period, CAST(ISNULL(Txn_Flag_C,0) AS MONEY)
FROM tbl_Transaction_History
WHERE Dl_Department IN ('Inbound Retention','Customer Saves','Outbound Retention','High Value Retention')
AND Txn_Flag_C IS NOT NULL
AND Txn_ProductType = 'Contract'
AND Dl_ActivityType = 'Retention'
AND (Order_Date BETWEEN '01-01-2008' AND '01-21-2008')

UPDATE #SUIMigrationSTCT
SET Tariff_Code = Txn_ProductCode,
Tariff_Description = Txn_ProductDescription,
Line_Rental = Txn_Recurring_Revenue
FROM #SUIMigrationSTCT A JOIN tbl_Transaction_History B
ON A.CTN = B.CTN 
AND A.Orig_Order_Date = B.Order_Date
WHERE Txn_ProductType = 'Price Plan'

UPDATE #SUIMigrationSTCT
SET Commercial_Cost_Fixed = ISNULL(B.Fixed,0),
Commercial_Cost_Recurring = ISNULL(B.Recurring,0)
FROM #SUIMigrationSTCT A LEFT OUTER JOIN MIReferenceTables.dbo.tbl_SOC_Commercial_Costs B
ON A.Tariff_Code = B.SOC


UPDATE #SUIMigrationSTCT
SET Current_Tariff_Code = B.SOC_Code
FROM #SUIMigrationSTCT A JOIN MIReporting.dbo.rep_000839_Current B
ON A.CTN = B.Subscriber_CTN
WHERE SOC_Service_Type = 'P'

UPDATE #SUIMigrationSTCT
SET Current_Tariff_Description = B.SOC_Description,
Current_Line_Rental = B.Rate
FROM #SUIMigrationSTCT A JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.Current_Tariff_Code = B.SOC_COde

UPDATE #SUIMigrationSTCT
SET Actual_Commercial_Cost_Fixed = ISNULL(B.Fixed,0),
Actual_Commercial_Cost_Recurring = ISNULL(B.Recurring,0)
FROM #SUIMigrationSTCT A LEFT OUTER JOIN MIReferenceTables.dbo.tbl_SOC_Commercial_Costs B
ON A.Current_Tariff_Code = B.SOC

SELECT * FROM #SUIMigrationSTCT
Order By Agent