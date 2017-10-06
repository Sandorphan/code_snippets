
CREATE TABLE #Commercial_Costs_PP (
Order_Reference VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
ProductType VARCHAR(50),
Recurring_Cost MONEY NULL,
Fixed_Cost MONEY NULL)

INSERT INTO #Commercial_Costs_PP
SELECT A.Order_Ref, A.CTN, A.txn_ProductType, B.Recurring, B.Fixed
FROM tbl_Transaction_History A LEFT OUTER JOIN mireferencetables.dbo.tbl_SOC_Commercial_Costs B
ON A.txn_ProductCode = B.SOC
WHERE A.txn_ProductType IN ('Price Plan')
AND A.Dl_Flag_B NOT LIKE '%STCT%'
AND A.Txn_ProductCode NOT LIKE A.Dl_Flag_A
AND Order_Date > '11-30-2008'
--DH7
AND A.Order_Date Between b.Eff_Date and Exp_Date


CREATE TABLE #CommercialCostFinalPP (
Order_Ref VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
Txn_Product_Type VARCHAR(50) NULL,
Txn_Fixed_Cost MONEY NULL,
Txn_Recurring_Cost MONEY NULL)

INSERT INTO #CommercialCostFinalPP
SELECT Order_Reference, CTN, ProductType, 
SUM(Fixed_Cost),SUM(Recurring_Cost)
FROM #Commercial_Costs_PP
GROUP BY Order_Reference, CTN, ProductType


UPDATE tbl_Transaction_Summary
SET Price_Plan_Commercial_ST_Cost = B.Txn_Fixed_Cost,
Price_Plan_Commercial_LT_Cost = B.Txn_Recurring_Cost
FROM tbl_Transaction_Summary A JOIN #CommercialCostFinalPP B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_Product_Type = 'Price Plan'


CREATE TABLE #Commercial_Costs_EX (
Order_Reference VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
ProductType VARCHAR(50),
Recurring_Cost MONEY NULL,
Fixed_Cost MONEY NULL)

INSERT INTO #Commercial_Costs_EX
SELECT A.Order_Ref, A.CTN, A.txn_ProductType, B.Recurring, B.Fixed
FROM tbl_Transaction_History A LEFT OUTER JOIN mireferencetables.dbo.tbl_SOC_Commercial_Costs B
ON A.txn_ProductCode = B.SOC
WHERE A.txn_ProductType IN ('Extras')
AND A.Order_Date > '11-30-2008'
--DH7
AND A.Order_Date Between b.Eff_Date and Exp_Date



CREATE TABLE #CommercialCostFinalEX (
Order_Ref VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
Txn_Product_Type VARCHAR(50) NULL,
Txn_Fixed_Cost MONEY NULL,
Txn_Recurring_Cost MONEY NULL)

INSERT INTO #CommercialCostFinalEX
SELECT Order_Reference, CTN, ProductType, 
SUM(Fixed_Cost),SUM(Recurring_Cost)
FROM #Commercial_Costs_EX
GROUP BY Order_Reference, CTN, ProductType


UPDATE tbl_Transaction_Summary
SET Extras_Commercial_ST_Cost = B.Txn_Fixed_Cost,
Extras_Commercial_LT_Cost = B.Txn_Recurring_Cost
FROM tbl_Transaction_Summary A JOIN #CommercialCostFinalEX B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_Product_Type = 'Extras'




