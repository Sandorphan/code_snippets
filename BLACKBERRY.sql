CREATE PROCEDURE spBlackberryReporting @OrderDate DATETIME AS

INSERT INTO tblBBReporting (Order_Ref,
CTN,BAN,Order_Date,Order_Week,Order_Month,Department,Site,
Channel_SubUnit, Channel, BusinessUnit,Subscriber_Segment,Activity_Type,
Device_Group, Device_Volume, Device_Cost,Device_Revenue)

SELECT Order_Ref, CTN, BAN, Order_Date, B.WeekText, B.MonthText, Dl_Department, Dl_Site, 
Dl_Function, Dl_Channel,  Dl_BusinessUnit, Dl_AccountType,
Dl_ActivityType, 
CASE
	WHEN Txn_ProductDescription LIKE 'Blackberry 8110%' THEN 'Blackberry Pearl'
	WHEN Txn_ProductDescription LIKE 'Blackberry 8310%' THEN 'Blackberry Curve'
	WHEN Txn_ProductDescription LIKE 'Blackberry 9000%' THEN 'Blackberry Bold'
	WHEN Txn_ProductDescription LIKE '%Storm%' THEN 'Blackberry Storm'
	ELSE 'Blackberry Other' END,
Txn_Quantity, Txn_Oneoff_Cost, Txn_OneOff_Revenue
FROM tbl_Transaction_Current JOIN MIReferenceTables.dbo.tbl_ref_dates B ON Order_Date = B.NewDate
WHERE txn_ProductDescription LIKE '%Blackberry%'
AND Txn_ProductType = 'Handset'
AND Txn_Flag_E NOT LIKE 'Exchange'
AND ORder_Date = @OrderDate



UPDATE tblBBReporting
SET 
PricePlan_SOC = B.Txn_ProductCode,
PricePlan = B.txn_ProductDescription,
PricePlan_LR = B.txn_recurring_Revenue
FROM tblBBReporting A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Price Plan'
AND B.ORder_Date = @OrderDate

UPDATE tblBBReporting
SET 
Blackberry_SOC = B.Txn_ProductCode,
Blackberry_Services = B.txn_ProductDescription,
Blackberry_Services_LR = B.txn_recurring_Revenue
FROM tblBBReporting A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Extras'
AND B.Txn_ProductDescription LIKE '%Blackberry%'
AND B.ORder_Date = @OrderDate

UPDATE tblBBReporting
SET 
VMI_SOC = B.Txn_ProductCode,
VMI_Services = B.txn_ProductDescription,
VMI_Services_LR = B.txn_recurring_Revenue
FROM tblBBReporting A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Extras'
AND B.ORder_Date = @OrderDate
AND (B.Txn_ProductCode LIKE '%MOBINT%' OR B.Txn_ProductDescription LIKE '%MobInt%')

UPDATE tblBBReporting
SET 
Other_SOC = B.Txn_ProductCode,
Other_Data_Services = B.txn_ProductDescription,
Other_Data_Services_LR = B.txn_recurring_Revenue
FROM tblBBReporting A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Extras'
AND B.Txn_ProductCode LIKE '%data%'
AND (LEN(VMI_SOC + Blackberry_SOC) > 0)
AND B.ORder_Date = @OrderDate

UPDATE tblBBReporting
SET
PricePlan = 'Wholesale'
WHERE Department = 'Handset Distributor'

UPDATE tblBBReporting
SET PricePlan = 'Insurance'
WHERE Department = 'Marsh'

-- SELECT Order_Date, Order_Week, Order_Month, Department, Site, Channel_SubUnit, Channel, BusinessUnit, Subscriber_Segment,
-- Activity_Type, Device_Group, PricePlan_SOC, PricePlan, PricePlan_LR,
-- CASE
-- 	WHEN PricePlan_LR < 20 THEN '£0-£19.99'
-- 	WHEN PricePlan_LR < 30 THEN '£20-£29.99'
-- 	WHEN PricePlan_LR < 40 THEN '£30-£39.99'
-- 	WHEN PricePlan_LR < 50 THEN '£40-£49.99'
-- 	WHEN PricePlan_LR < 75 THEN '£50-£74.99'
-- 	WHEN PricePlan_LR < 100 THEN '£75-£99.99'
-- 	ELSE '>£100' END AS LineRentalBand,
-- ISNULL(Blackberry_SOC,'No BB SOC'), ISNULL(VMI_SOC,'No VMI SOC'), 
-- SUM(Device_Volume), SUM(Device_Cost), SUM(Device_Revenue)  FROM tblBBReporting
-- GROUP BY Order_Date, Order_Week, Order_Month, Department, Site, Channel_SubUnit, Channel, BusinessUnit, Subscriber_Segment,
-- Activity_Type, Device_Group, PricePlan_SOC, ISNULL(PricePlan,'No Price Plan Selected'), PricePlan_LR,
-- CASE
-- 	WHEN PricePlan_LR < 20 THEN '£0-£19.99'
-- 	WHEN PricePlan_LR < 30 THEN '£20-£29.99'
-- 	WHEN PricePlan_LR < 40 THEN '£30-£39.99'
-- 	WHEN PricePlan_LR < 50 THEN '£40-£49.99'
-- 	WHEN PricePlan_LR < 75 THEN '£50-£74.99'
-- 	WHEN PricePlan_LR < 100 THEN '£75-£99.99'
-- 	ELSE '>£100' END,
-- ISNULL(Blackberry_SOC,'No BB SOC'), ISNULL(VMI_SOC,'No VMI SOC')