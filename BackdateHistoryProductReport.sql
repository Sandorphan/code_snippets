TRUNCATE TABLE tblProductReporting


CREATE TABLE #TempProductReporting (
Order_Date DATETIME NULL,
Order_Month VARCHAR(100) NULL,
Order_Ref VARCHAR(100) NULL,
CTN VARCHAR(100) NULL,
Business_Unit VARCHAR(100) NULL,
Channel VARCHAR(100) NULL,
Department VARCHAR(100) NULL,
Contract_Length INT NULL,
Contract_Type VARCHAR(100) NULL,
Product_Type VARCHAR(100) NULL,
Product_Code VARCHAR(100) NULL,
Product_Description VARCHAR(100) NULL,
Product_Info_1 VARCHAR(100) NULL,
Product_Info_2 VARCHAR(100) NULL,
Product_Info_3 VARCHAR(100) NULL,
Product_Info_4 VARCHAR(100) NULL,
Volume_Sales INT NULL,
Rec_Rev MONEY NULL,
Rec_Cost MONEY NULL,
Fixed_Rev MONEY NULL,
Fixed_Cost MONEY NULL,
Total_Cost MONEY NULL,
Total_Revenue MONEY NULL,
[SOC_Attr_1] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_2] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_3] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_4] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_5] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_6] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_7] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_8] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_9] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_10] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_11] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_12] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_13] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_14] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_15] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_16] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_17] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_18] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_19] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_20] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_21] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_22] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_23] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_24] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_25] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_26] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_27] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_28] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_29] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
[SOC_Attr_30] [varchar] (50) COLLATE Latin1_General_CI_AS NULL 
)
 
TRUNCATE TABLE #TempProductReporting

INSERT INTO #TempProductReporting (Order_Date, Order_Ref, CTN, Business_Unit, Channel, 
Department, Product_Type, Product_Code, Product_Description, Product_Info_1, Product_Info_2,Product_Info_3, Product_Info_4, Volume_Sales, Rec_Rev, Rec_Cost, Fixed_Rev, Fixed_Cost )
SELECT Order_Date, Order_Ref, CTN, Dl_BusinessUnit, Dl_Channel, Dl_Department, Txn_ProductType, Txn_ProductCode,
LTRIM(RTrim(Txn_ProductDescription)) + ' - LR = £' + Cast(ISNULL(Txn_Recurring_Revenue,0) AS VARCHAR(10)) , 
B.SOC_Category, 
CASE 
	WHEN Txn_Flag_A = 'CTR' THEN 'CTR' ELSE 'Non CTR' END,
CASE
	WHEN Txn_Flag_B = 'STC' THEN 'Stop The Clock' ELSE 'Non STC' END,
CASE 
	WHEN Txn_Flag_C = 'VP' THEN 'Passport' ELSE 'Non VP' END,
Txn_Quantity, 0, Txn_Recurring_Cost, Txn_OneOff_Revenue, Txn_OneOff_Cost 
FROM tbl_Transaction_History A JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.Txn_ProductCode = B.SOC_Code
WHERE Txn_PRoductType = 'Price Plan'
AND Order_Date > '04-30-2008'


INSERT INTO #TempProductReporting (Order_Date, Order_Ref, CTN, Business_Unit, Channel, 
Department, Product_Type, Product_Code, Product_Description, Product_Info_1, Product_Info_2,Product_Info_3, Product_Info_4, Volume_Sales, Rec_Rev, Rec_Cost, Fixed_Rev, Fixed_Cost )
SELECT Order_Date, Order_Ref, CTN, Dl_BusinessUnit, Dl_Channel, Dl_Department, Txn_ProductType, Txn_ProductCode,
LTRIM(RTrim(Txn_ProductDescription)) + ' - LR = £' + Cast(ISNULL(Txn_Recurring_Revenue,0) AS VARCHAR(10)) , Txn_Flag_B, 
'n/a', 'n/a','n/a',
Txn_Quantity, 0, Txn_Recurring_Cost, Txn_OneOff_Revenue, Txn_OneOff_Cost FROM tbl_Transaction_History
WHERE Txn_PRoductType = 'Extras'
AND Order_Date > '04-30-2008'


INSERT INTO #TempProductReporting (Order_Date, Order_Ref, CTN, Business_Unit, Channel, 
Department, Product_Type, Product_Code, Product_Description, Product_Info_1, Product_Info_2,Product_Info_3, Product_Info_4, Volume_Sales, Rec_Rev, Rec_Cost, Fixed_Rev, Fixed_Cost )
SELECT Order_Date, Order_Ref, CTN, Dl_BusinessUnit, Dl_Channel, Dl_Department, Txn_ProductType, Txn_ProductCode,
LTRIM(RTrim(B.Handset_Description)) + ' - Cost = £' + Cast(ISNULL(B.Current_Price,0) AS VARCHAR(10)) , 
B.Manufacturer, 
Txn_Flag_D,
Txn_Flag_C,
Txn_Flag_B,
Txn_Quantity, Txn_Recurring_Revenue, Txn_Recurring_Cost, Txn_OneOff_Revenue, Txn_OneOff_Cost 
FROM tbl_Transaction_History A JOIN MIReporting.dbo.New_Handset_Table B
ON A.Txn_ProductCode = B.HermesCode
WHERE Txn_PRoductType = 'Handset'
AND ORder_Date > '04-30-2008'



INSERT INTO #TempProductReporting (Order_Date, Order_Ref, CTN, Business_Unit, Channel, 
Department, Product_Type, Product_Code, Product_Description, Product_Info_1, Product_Info_2,Product_Info_3, Product_Info_4, Volume_Sales, Rec_Rev, Rec_Cost, Fixed_Rev, Fixed_Cost )
SELECT Order_Date, Order_Ref, CTN, Dl_BusinessUnit, Dl_Channel, Dl_Department, Txn_ProductType, Txn_ProductCode,
LTRIM(RTrim(B.Handset_Description)) + ' - Cost = £' + Cast(ISNULL(B.Current_Price,0) AS VARCHAR(10)) , 
B.Manufacturer, 
CASE
	WHEN Txn_ProductDescription LIKE '%SIM%' THEN 'SIM Card'
	WHEN Txn_ProductDescription LIKE '%BATTERY%' THEN 'Battery'
	WHEN Txn_ProductDescription LIKE '%Charger%' THEN 'Charger'
	WHEN Txn_ProductDescription LIKE '%Bluetooth%' THEN 'Handsfree'
	WHEN Txn_ProductDescription LIKE '%Datacard%' THEN 'Datacard'
	WHEN Txn_ProductDescription LIKE '%HSDPA%' THEN 'Datacard'
	ELSE 'Other Accessory' END,
'n/a',
'n/a',
Txn_Quantity, Txn_Recurring_Revenue, Txn_Recurring_Cost, Txn_OneOff_Revenue, Txn_OneOff_Cost 
FROM tbl_Transaction_History A JOIN MIReporting.dbo.New_Handset_Table B
ON A.Txn_ProductCode = B.HermesCode
WHERE Txn_PRoductType LIKE '%Access%'
AND ORder_Date > '04-30-2008'



CREATE TABLE #PRTempContracts (
Order_Ref VARCHAR(100) NULL,
CTN VARCHAR(100) NULL,
Contract_Length INT NULL,
Contract_Type VARCHAR(100) NULL)

INSERT INTO #PRTempContracts
SELECT Order_Ref, CTN, Txn_Net_Period,Dl_ActivityType
FROM tbl_Transaction_History
WHERE Txn_ProductType = 'Contract'
AND Order_Date > '04-30-2008'

UPDATE #TempProductReporting
SET Contract_Length = ISNULL(B.Contract_Length,0),
Contract_Type = ISNULL(B.Contract_Type,'Retention')
FROM #TempProductReporting A LEFT OUTER JOIN #PRTempContracts B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN

UPDATE #TempProductReporting
SET Order_Month = B.Monthtext
FROM #TempProductReporting A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.Order_Date = B.NewDate

UPDATE #TempProductReporting
SET Total_Revenue = ISNULL(Fixed_Rev,0) + (ISNULL(Rec_Rev,0) * ISNULL(Contract_Length,0)),
Total_Cost = ISNULL(Fixed_Cost,0) + (ISNULL(Rec_Cost,0) * ISNULL(Contract_Length,0))


INSERT INTO tblProductReporting (Order_Date, Order_Month, 
Business_Unit, Channel, Department, 
Order_Type,
Contract_Type, Product_Type,
Product_Code, Product_Description, Product_Info_1, Product_Info_2,
Product_Info_3, Product_Info_4, Volume_Sales, Total_Cost, Total_Revenue,
SOC_Attr_1,
SOC_Attr_2,
SOC_Attr_3,
SOC_Attr_4,
SOC_Attr_5,
SOC_Attr_6,
SOC_Attr_7,
SOC_Attr_8,
SOC_Attr_9,
SOC_Attr_10,
SOC_Attr_11,
SOC_Attr_12,
SOC_Attr_13,
SOC_Attr_14,
SOC_Attr_15,
SOC_Attr_16,
SOC_Attr_17,
SOC_Attr_18,
SOC_Attr_19,
SOC_Attr_20,
SOC_Attr_21,
SOC_Attr_22,
SOC_Attr_23,
SOC_Attr_24,
SOC_Attr_25,
SOC_Attr_26,
SOC_Attr_27,
SOC_Attr_28,
SOC_Attr_29,
SOC_Attr_30)
SELECT Order_Date, Order_Month, 
LTrim(RTrim(Business_Unit)), LTrim(RTrim(Channel)), LTrim(RTrim(Department)),
CASE
	WHEN Contract_Length > 11 THEN 'Contract' ELSE 'Non Contract' END,
LTrim(RTrim(Contract_Type)),
LTrim(RTrim(Product_Type)), LTrim(RTrim(Product_Code)), LTrim(RTrim(Product_Description)), 
Product_Info_1, LTrim(RTrim(Product_Info_2)),
LTrim(RTrim(Product_Info_3)), LTrim(RTrim(Product_Info_4)), SUM(Volume_Sales), SUM(Total_Cost),SUM(Total_Revenue),
ISNULL(B.SOC_Attr_1,'N'),
ISNULL(B.SOC_Attr_2,'N'),
ISNULL(B.SOC_Attr_3,'N'),
ISNULL(B.SOC_Attr_4,'N'),
ISNULL(B.SOC_Attr_5,'N'),
ISNULL(B.SOC_Attr_6,'N'),
ISNULL(B.SOC_Attr_7,'N'),
ISNULL(B.SOC_Attr_8,'N'),
ISNULL(B.SOC_Attr_9,'N'),
ISNULL(B.SOC_Attr_10,'N'),
ISNULL(B.SOC_Attr_11,'N'),
ISNULL(B.SOC_Attr_12,'N'),
ISNULL(B.SOC_Attr_13,'N'),
ISNULL(B.SOC_Attr_14,'N'),
ISNULL(B.SOC_Attr_15,'N'),
ISNULL(B.SOC_Attr_16,'N'),
ISNULL(B.SOC_Attr_17,'N'),
ISNULL(B.SOC_Attr_18,'N'),
ISNULL(B.SOC_Attr_19,'N'),
ISNULL(B.SOC_Attr_20,'N'),
ISNULL(B.SOC_Attr_21,'N'),
ISNULL(B.SOC_Attr_22,'N'),
ISNULL(B.SOC_Attr_23,'N'),
ISNULL(B.SOC_Attr_24,'N'),
ISNULL(B.SOC_Attr_25,'N'),
ISNULL(B.SOC_Attr_26,'N'),
ISNULL(B.SOC_Attr_27,'N'),
ISNULL(B.SOC_Attr_28,'N'),
ISNULL(B.SOC_Attr_29,'N'),
ISNULL(B.SOC_Attr_30, 'N')
FROM #TempProductReporting A
LEFT OUTER JOIN MIReferenceTables.dbo.tblSOC_Attributes B
ON A.Product_Code = B.SOC_Code
GROUP BY Order_Date, Order_Month, 
LTrim(RTrim(Business_Unit)), LTrim(RTrim(Channel)), LTrim(RTrim(Department)),
CASE
	WHEN Contract_Length > 11 THEN 'Contract' ELSE 'Non Contract' END,
LTrim(RTrim(Contract_Type)),
LTrim(RTrim(Product_Type)),LTrim(RTrim(Product_Code)), LTrim(RTrim(Product_Description)), 
Product_Info_1, LTrim(RTrim(Product_Info_2)),
LTrim(RTrim(Product_Info_3)), LTrim(RTrim(Product_Info_4)),
B.SOC_Attr_1,
B.SOC_Attr_2,
B.SOC_Attr_3,
B.SOC_Attr_4,
B.SOC_Attr_5,
B.SOC_Attr_6,
B.SOC_Attr_7,
B.SOC_Attr_8,
B.SOC_Attr_9,
B.SOC_Attr_10,
B.SOC_Attr_11,
B.SOC_Attr_12,
B.SOC_Attr_13,
B.SOC_Attr_14,
B.SOC_Attr_15,
B.SOC_Attr_16,
B.SOC_Attr_17,
B.SOC_Attr_18,
B.SOC_Attr_19,
B.SOC_Attr_20,
B.SOC_Attr_21,
B.SOC_Attr_22,
B.SOC_Attr_23,
B.SOC_Attr_24,
B.SOC_Attr_25,
B.SOC_Attr_26,
B.SOC_Attr_27,
B.SOC_Attr_28,
B.SOC_Attr_29,
B.SOC_Attr_30 



TRUNCATE TABLE tblProductReporting_Monthly

INSERT INTO tblProductReporting_Monthly
SELECT Order_Month, 
Business_Unit, Channel, Department, Order_Type, Contract_Type, Product_Type,
Product_Code, Product_Description, Product_Info_1, Product_Info_2,
Product_Info_3, Product_Info_4, SUM(Volume_Sales), SUM(Total_Cost), SUM(Total_Revenue),
SOC_Attr_1,
SOC_Attr_2,
SOC_Attr_3,
SOC_Attr_4,
SOC_Attr_5,
SOC_Attr_6,
SOC_Attr_7,
SOC_Attr_8,
SOC_Attr_9,
SOC_Attr_10,
SOC_Attr_11,
SOC_Attr_12,
SOC_Attr_13,
SOC_Attr_14,
SOC_Attr_15,
SOC_Attr_16,
SOC_Attr_17,
SOC_Attr_18,
SOC_Attr_19,
SOC_Attr_20,
SOC_Attr_21,
SOC_Attr_22,
SOC_Attr_23,
SOC_Attr_24,
SOC_Attr_25,
SOC_Attr_26,
SOC_Attr_27,
SOC_Attr_28,
SOC_Attr_29,
SOC_Attr_30

FROM tblProductReporting
GROUP BY Order_Month, 
Business_Unit, Channel, Department, Order_Type, Contract_Type, Product_Type,
Product_Code, Product_Description, Product_Info_1, Product_Info_2,
Product_Info_3, Product_Info_4, Total_Cost, Total_Revenue,
SOC_Attr_1,
SOC_Attr_2,
SOC_Attr_3,
SOC_Attr_4,
SOC_Attr_5,
SOC_Attr_6,
SOC_Attr_7,
SOC_Attr_8,
SOC_Attr_9,
SOC_Attr_10,
SOC_Attr_11,
SOC_Attr_12,
SOC_Attr_13,
SOC_Attr_14,
SOC_Attr_15,
SOC_Attr_16,
SOC_Attr_17,
SOC_Attr_18,
SOC_Attr_19,
SOC_Attr_20,
SOC_Attr_21,
SOC_Attr_22,
SOC_Attr_23,
SOC_Attr_24,
SOC_Attr_25,
SOC_Attr_26,
SOC_Attr_27,
SOC_Attr_28,
SOC_Attr_29,
SOC_Attr_30


DELETE FROM SPSVRMI01.MIOutputs.dbo.tblProductReporting_Monthly

INSERT INTO SPSVRMI01.MIOutputs.dbo.tblProductReporting_Monthly
SELECT * FROM tblProductReporting_Monthly