--DROP TABLE #BBReport
CREATE PROCEDURE spExecStormData AS

TRUNCATE TABLE tblBBExecReport

CREATE TABLE #BBReport (
Order_Date DATETIME,
Order_Week VARCHAR(100),
Order_Month VARCHAR(100),
Subscriber_Status VARCHAR(100),
AccountType VARCHAR(100),
Business_Unit VARCHAR(100),
Channel VARCHAR(100),
Reporting_Channel VARCHAR(100),
Order_Type VARCHAR(100),
Contract_Orders INT,
BB_Storm_PricePlans INT NULL,
BB_PricePlans_All INT,
BB_Storm INT,
BB_Other INT,
BB_Migrations INT,
BB_Storm_Maintenence INT )


INSERT INTO #BBReport (Order_Date, Order_Week, Order_Month, Subscriber_Status, AccountType,
Business_Unit, Channel, Order_Type, Contract_Orders, BB_Storm_PricePlans, BB_PricePlans_All, BB_Storm, BB_Other,
BB_Migrations, BB_Storm_Maintenence)
SELECT Order_Date, Order_Week, Order_Month, 
CASE
	WHEN Subscriber_Status = 'Active' THEN 'Connected'
	WHEN Subscriber_Status = 'Suspended' THEN 'Connected'
	ELSE 'Reserved/Cancelled' END,
CASE
	WHEN Customer_Segment = 'Consumer' THEN 'Consumer'
	ELSE 'Business' END,
CASE WHEN
	Business_UNIT NOT IN ('CBU','EBU') THEN 'Other'
	ELSE Business_Unit END, 

CASE
	WHEN Channel = 'Call Centre - Sales' AND Business_Unit = 'CBU' THEN 'TSAR'
	WHEN Channel = 'Online'  AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Department = 'QuickStop Vod' AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Channel = 'Retail' AND Business_Unit = 'CBU' THEN 'Retail'
	WHEN Channel = 'Indirect' AND Department LIKE  '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - P4U'
	WHEN Channel = 'Indirect' AND Department NOT LIKE '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - Other'
	WHEN Business_Unit NOT LIKE 'CBU' THEN 'Call Centre - EBU'
	ELSE 'Call Centre - Other' END,
 ISNULL(Order_Type,'Retention'),
SUM (CASE
	WHEN Contract_GROSS_Volume > 0 THEN 1 ELSE 0 END),
SUM (CASE
	WHEN Primary_SOC IN ('VMI05EB25','VMI05PB25','VMI20EB30','VMI20PB30','VMI55EB40','VMI55PB40','VMI56EB40',
'VMI56PB40','VMI65EB45','VMI65PB45','VMI66EB45','VMI66PB45','VMI75EB55','VMI75PB55',
'VMI76EB55','VMI76PB55','VMI85EB80','VMI85PB80','VMI86EB80','VMI86PB80','VMI01EB25',
'VMI01PC25','VMI10EC30','VMI10PB30','VMI15EB35','VMI15PB35','VMI67ED45','VMI67PD45',
'VMI77EB55','VMI77PB55','VMI87EB80','VMI87PB80','VMI20EB25','VMI20PB25','VMI35EB30',
'VMI35PB30','VMI55EB35','VMI55PB35','VMI56EA35','VMI56PA35','VMI65EA40','VMI65PA40',
'VMI66EA40','VMI66PA40','VMI75EA50','VMI75PB50','VMI76EA50','VMI76PA50','VMI85EA75',
'VMI85PA75','VMI86EA75','VMI86PA75','VMI15EB30','VMI15PB30','VMI45EC35','VMI45PC35',
'VMI67EA40','VMI67PA40','VMI77EA50','VMI77PA50','VMI87EA75','VMI87PA75') THEN 1 ELSE 0 END),
SUM (CASE
	WHEN Primary_Price_Plan LIKE '%AT BB%' AND Contract_GROSS_Volume > 0 THEN 1
	WHEN Primary_Price_Plan LIKE '%CTR3 BB%' AND Contract_GROSS_Volume > 0 THEN 1
	WHEN Primary_Price_Plan LIKE '%Blackberry%' AND Contract_GROSS_Volume > 0 THEN 1
	ELSE 0 END),
SUM (CASE 
	WHEN Primary_Handset LIKE '%Storm%' AND Contract_GROSS_Volume > 0 THEN Handset_Volume ELSE 0 END),
SUM (CASE 
	WHEN Contract_GROSS_Volume > 0 AND (Primary_Handset LIKE '%Bold%' OR Primary_Handset LIKE '%Curve%' OR Primary_Handset LIKE '%Pearl%') THEN Handset_Volume ELSE 0 END),
SUM (CASE
	WHEN Primary_Price_Plan LIKE '%AT BB%' AND Contract_GROSS_Volume = 0 THEN 1
	WHEN Primary_Price_Plan LIKE '%CTR3 BB%' AND Contract_GROSS_Volume = 0 THEN 1
	WHEN Primary_Price_Plan LIKE '%Blackberry%' AND Contract_GROSS_Volume = 0 THEN 1
	ELSE 0 END),
SUM (CASE 
	WHEN Primary_Handset LIKE '%Storm%' AND Contract_GROSS_Volume = 0 THEN Handset_Volume ELSE 0 END)
FROM tbl_Transaction_Summary
WHERE ORder_Date >= '11-01-2008'
GROUP BY 
Order_Date, Order_Week, Order_Month, 
CASE
	WHEN Subscriber_Status = 'Active' THEN 'Connected'
	WHEN Subscriber_Status = 'Suspended' THEN 'Connected'
	ELSE 'Reserved/Cancelled' END,
CASE
	WHEN Customer_Segment = 'Consumer' THEN 'Consumer'
	ELSE 'Business' END,
Business_Unit, 
CASE
	WHEN Channel = 'Call Centre - Sales' AND Business_Unit = 'CBU' THEN 'TSAR'
	WHEN Channel = 'Online'  AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Department = 'QuickStop Vod' AND Business_Unit = 'CBU' THEN 'Online'
	WHEN Channel = 'Retail' AND Business_Unit = 'CBU' THEN 'Retail'
	WHEN Channel = 'Indirect' AND Department LIKE  '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - P4U'
	WHEN Channel = 'Indirect' AND Department NOT LIKE '%Phones 4u%' AND Business_Unit = 'CBU' THEN 'Indirect - Other'
	WHEN Business_Unit NOT LIKE 'CBU' THEN 'Call Centre - EBU'
	ELSE 'Call Centre - Other' END,  Order_Type


--UPDATE THE BB PRICE PLANS VOLUME AND RELATED STORM/Oth BB Orders

UPDATE #BBReport
SET Business_Unit = 'Other',
Channel = 'Call Centre - Other'
WHERE Business_Unit IS NULL

UPDATE #BBReport
SET Channel = 'Call Centre - Other'
WHERE Business_Unit = 'Other'

INSERT INTO tblBBExecReport
SELECT * FROM #BBReport
