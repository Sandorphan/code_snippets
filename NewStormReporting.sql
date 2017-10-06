DROP TABLE #BBReport

CREATE TABLE #BBReport (
Order_Date DATETIME,
Order_Week VARCHAR(100),
Order_Month VARCHAR(100),
AccountType VARCHAR(100),
Business_Unit VARCHAR(100),
Channel VARCHAR(100),
Department VARCHAR(100),
Order_Type VARCHAR(100),
BB_Storm_PricePlans INT NULL,
BB_Storm INT)


INSERT INTO #BBReport (Order_Date, Order_Week, Order_Month,AccountType,
Business_Unit, Channel, Department, Order_Type,  BB_Storm_PricePlans,  BB_Storm)
SELECT Order_Date, Order_Week, Order_Month, 
CASE
	WHEN Customer_Segment = 'Consumer' THEN 'Consumer'
	WHEN Customer_Segment IS NULL THEN 'Unsegmented'
	ELSE 'Business' END,
CASE WHEN
	Business_UNIT NOT IN ('CBU','EBU') THEN 'Other'
	WHEN Business_Unit IS NULL THEN 'Other'
	ELSE Business_Unit END, 

CASE
	WHEN Channel = 'Call Centre - Sales' AND Business_Unit = 'CBU' THEN 'TSAR'
	WHEN Channel = 'Online'  AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Department = 'QuickStop Vod' AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Channel = 'Retail' AND Business_Unit = 'CBU' THEN 'Retail'
	WHEN Channel = 'Indirect' AND Department LIKE  '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - P4U'
	WHEN Channel = 'Indirect' AND Department NOT LIKE '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - Other'
	WHEN Business_Unit = 'EBU' THEN 'Call Centre - EBU'
	ELSE 'Call Centre - Other' END,
Department,
 Order_Type,
SUM (CASE
	WHEN Primary_SOC IN (SELECT SOC FROM SPSVRMI01.MIOutputs.dbo.tbl_Storm_SOCs) THEN 1 ELSE 0 END),
SUM (CASE 
	WHEN Primary_Handset LIKE '%Storm%' THEN Handset_Volume ELSE 0 END)

FROM tbl_Transaction_Summary
WHERE ORder_Date >= '11-01-2008'
GROUP BY 
Order_Date, Order_Week, Order_Month, 
CASE
	WHEN Customer_Segment = 'Consumer' THEN 'Consumer'
	WHEN Customer_Segment IS NULL THEN 'Unsegmented'
	ELSE 'Business' END,
CASE WHEN
	Business_UNIT NOT IN ('CBU','EBU') THEN 'Other'
	WHEN Business_Unit IS NULL THEN 'Other'
	ELSE Business_Unit END,  

CASE
	WHEN Channel = 'Call Centre - Sales' AND Business_Unit = 'CBU' THEN 'TSAR'
	WHEN Channel = 'Online'  AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Department = 'QuickStop Vod' AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Channel = 'Retail' AND Business_Unit = 'CBU' THEN 'Retail'
	WHEN Channel = 'Indirect' AND Department LIKE  '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - P4U'
	WHEN Channel = 'Indirect' AND Department NOT LIKE '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - Other'
	WHEN Business_Unit = 'EBU' THEN 'Call Centre - EBU'
	ELSE 'Call Centre - Other' END,  
Department, Order_Type


--UPDATE THE BB PRICE PLANS VOLUME AND RELATED STORM/Oth BB Orders


SELECT * FROM #BBReport
