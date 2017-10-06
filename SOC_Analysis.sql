CREATE TABLE #SOC_Analysis (
Period VARCHAR(50) NULL,
SOC_Code VARCHAR(50) NULL,
SOC_Description VARCHAR(100) NULL,
SOC_Group VARCHAR(50) NULL,
SOC_SubGroup VARCHAR(50) NULL,
SOC_LR MONEY NULL,
Opening_Base INT NULL,
Sales_Acquisition INT NULL,
Sales_Retention INT NULL,
Sales_Migration INT NULL,
Cancellations INT NULL,
Closing_Base INT NULL)


CREATE TABLE #OpeningBase (
SOC_Code VARCHAR(50) NULL,
Opening_Base VARCHAR(50) NULL)

INSERT INTO #OpeningBase
SELECT SOC_Code, Count(SOC_Code)
FROM rep_000839_Previous
GROUP BY SOC_Code

CREATE TABLE #ClosingBase (
SOC_Code VARCHAR(50) NULL,
Closing_Base VARCHAR(50) NULL)

INSERT INTO #ClosingBase
SELECT SOC_Code, Count(SOC_Code)
FROM rep_000839_Current
GROUP BY SOC_Code

TRUNCATE TABLE #SOC_Analysis

INSERT INTO #SOC_Analysis (Period, SOC_Code, Opening_Base, Closing_Base)
SELECT '200710 - October', A.SOC_Code, Opening_Base, IsNull(Closing_Base,0)  
FROM #OpeningBase A LEFT OUTER JOIN #ClosingBase B
ON A.SOC_Code = B.SOC_Code

INSERT INTO #SOC_Analysis (Period, SOC_Code, Opening_Base, Closing_Base)
SELECT '200710 - October',SOC_Code, 0,Closing_Base
FROM #ClosingBase
WHERE SOC_Code NOT IN (SELECT SOC_Code FROM #SOC_Analysis)

SELECT * FROM #SOC_Analysis


UPDATE #SOC_Analysis
SET SOC_Description = ISNULL(B.SOC_Description,'Unknown'),
SOC_Group = ISNULL(B.SOC_Type,'Other'),
SOC_SubGroup = ISNULL(B.SOC_SubType,'Other'),
SOC_LR = ISNULL(B.Rate,0)
FROM #SOC_Analysis A LEFT OUTER JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.SOC_Code = B.SOC_Code

