USE [MIStandardMetrics]
GO
/****** Object:  StoredProcedure [dbo].[sp_Txn_Table_COM]    Script Date: 04/23/2012 09:10:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC sp_Txn_Table_COM '04-27-2009'


/******************************************************

-----POST UPDATE TASKS
--Rename dev table back to tbl_transactio_current
--Reinsert History Script

******************************************************** */





ALTER                     PROCEDURE [dbo].[sp_Txn_Table_COM_Dev] @OrderDate DATETIME AS

EXEC MIReporting.dbo.spMasterProcessStart 'TransactionCurrent'

TRUNCATE TABLE tbl_Transaction_backfix

--PART A - INSERT CONTRACTS
-------------------------------------------------------------------------------------------------------------------------------------	
INSERT INTO tbl_Transaction_backfix
--declare @orderDate DATETIME
--select @orderDate = '2010-02-17 00:00:00.000'

SELECT   
--The year part
CAST(Datepart(yyyy,Order_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Order_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Order_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Order_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Order_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Order_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Order_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
CTN,
BAN,
Order_Date,
NULL,
Agent_ID,
NULL, 
NULL,
Dealer_Code,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
Contract_Type,
'Contract',
NULL,
Contract_Type + ' Contract',
1,
NULL,
NULL,
NULL,
NULL,
NULL,
CASE
	WHEN New_Contract_Start_Date < dateadd(day,-7,Order_Date) THEN Order_Date
	ELSE New_Contract_Start_Date END,
CASE	WHEN New_Contract_End_Date < Order_Date THEN Order_Date
	ELSE New_Contract_End_Date END,
NULL,
NULL,
NULL,
Gross_Contract_Length,
Net_Contract_Length,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Contract_Table',
NEWID()
FROM tbl_Contract_Upgrades
WHERE Order_Date = @orderDate
AND Net_Contract_Length > 0
--AND Net_Contract_Length = 6
GROUP BY CTN, BAN, Order_Date, Agent_ID, Dealer_Code, 

CASE

	WHEN New_Contract_Start_Date < dateadd(day,-7,Order_Date) THEN Order_Date
	ELSE New_Contract_Start_Date END,

CASE	WHEN New_Contract_End_Date < Order_Date THEN Order_Date
	ELSE New_Contract_End_Date END,
Gross_Contract_Length, Net_Contract_Length, Contract_Type
	
--PART B - INSERT CONTRACT EXCEPTIONS
--------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix

SELECT   
--The year part
CAST(Datepart(yyyy,Order_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Order_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Order_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Order_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Order_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Order_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Order_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
CTN,
BAN,
Order_Date,
NULL,
Agent_ID,
NULL, 
NULL,
Dealer_Code,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
Contract_Type,
'Contract Reset',
NULL,
Contract_Type + ' Contract',
1,
NULL,
NULL,
NULL,
NULL,
NULL,
CASE
	WHEN New_Contract_Start_Date < dateadd(day,-7,Order_Date) THEN Order_Date
	ELSE New_Contract_Start_Date END,
CASE	WHEN New_Contract_End_Date < Order_Date THEN Order_Date
	ELSE New_Contract_End_Date END,
NULL,
NULL,
NULL,
Gross_Contract_Length,
Net_Contract_Length,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Contract_Table',
NEWID()
FROM tbl_Contract_Upgrades
WHERE Order_Date = @OrderDate
AND Net_Contract_Length = 0
GROUP BY CTN, BAN, Order_Date, Agent_ID, Dealer_Code, 
CASE
	WHEN New_Contract_Start_Date < dateadd(day,-7,Order_Date) THEN Order_Date
	ELSE New_Contract_Start_Date END,
CASE	WHEN New_Contract_End_Date < Order_Date THEN Order_Date
	ELSE New_Contract_End_Date END,
Gross_Contract_Length, Net_Contract_Length, Contract_Type


--PART C - INSERT PRICE PLANS
----------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix
SELECT   

--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +

--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END + '_' +
--The CTN
Memo_BAN,
Memo_CTN,
Memo_BAN,
Memo_Date,
NULL,
Memo_Agent_ID,
NULL, 
NULL,
Dealer_Code,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
CASE
	WHEN Order_Type = 'Acquisition' THEN 'Acquisition'
	ELSE 'Retention' END,
ISNULL(B.SOC_Group,'Price Plan'),
New_SOC_Code,
B.SOC_Description,
1,
NULL,
NULL,
NULL,
NULL,
NULL,
New_Start_Date,
New_End_Date,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
CASE
	WHEN Order_Type = 'Acquisition' THEN 'New'
	WHEN Order_Type = 'PP_Change' THEN 'Migration'
	WHEN Order_Type = 'SaveToCurrentTariff' THEN 'Save To Current Tariff'
	ELSE 'Unknown' END,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Price_Plan_Table',
NEWID()
FROM tbl_PricePlan_Changes
LEFT OUTER JOIN MIReferenceTables.dbo.tbl_soc_reference B
on  New_SOC_Code = B.SOC_Code
where memo_date = @OrderDate
AND  New_SOC_Code NOT IN ('18MONTH','24MONTH')
GROUP BY Memo_CTN, Memo_BAN, Memo_Date, Memo_Agent_ID, Dealer_Code, 
ISNULL(B.SOC_Group,'Price Plan'), New_SOC_Code, SOC_Description,
New_Start_Date, New_End_Date, New_Rate, ISNULL(CTR,'No'), Order_Type



--PART D - INSERT ADDITIONAL SERVICES (Memos 1012)
-------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
CTN,
BAN,
Memo_Date,
NULL,
Memo_Agent_ID,
NULL, 
NULL,
Dealer_Code,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
Activity_Type,
ISNULL(B.SOC_Group,'Extras'),
a.SOC_Code,
ISNULL(B.SOC_Description,'Unknown'),
1,
NULL,
NULL,
NULL,
NULL,
NULL,
Effective_From,
Effective_To,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
b.SOC_LR,
NULL,
NULL,
NULL,
NULL,
null,
NULL,
CASE
	WHEN Activity_Type = 'Acquisition' THEN 'New'
	ELSE 'Migration' END,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Additional_Services',
NEWID()
FROM tbl_Additional_Services A
LEFT OUTER JOIN MIReferenceTables.dbo.tbl_SOC_Reference B
ON a.SOC_Code = B.SOC_Code 
where Memo_Date = @OrderDate
AND a.SOC_Code IS NOT NULL
AND effective_from >= a.memo_date
and  (a.effective_to <> a.memo_date OR A.Effective_to IS NULL)
GROUP BY CTN, BAN, memo_Date, Memo_Agent_ID,Dealer_Code,ISNULL(B.SOC_Group,'Extras'),
a.SOC_Code, ISNULL(B.SOC_Description,'Unknown'),
Effective_From, Effective_To,SOC_LR, Activity_Type,ISNULL(b.CTR,'No')

--INSERT ADDITIONAL SERVICE CANCELLATIONS
INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
CTN,
BAN,
Memo_Date,
NULL,
Memo_Agent_ID,
NULL, 
NULL,
Dealer_Code,
NULL,
NULL,
NULL,
NULL,

NULL,

NULL,
NULL,
NULL,
NULL,
NULL,
Activity_Type,
'Extras Cancellation',
a.SOC_Code,
ISNULL(B.SOC_Description,'Unknown'),
1,
NULL,
NULL,
NULL,
NULL,
NULL,
Effective_From,
Effective_To,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
b.SOC_LR,
NULL,
NULL,
NULL,
NULL,
null,
NULL,
CASE
	WHEN Activity_Type = 'Acquisition' THEN 'New'
	ELSE 'Migration' END,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Additional_Services',
NEWID()
FROM tbl_Additional_Services A
LEFT OUTER JOIN MIReferenceTables.dbo.tbl_SOC_Reference B
ON a.SOC_Code = B.SOC_Code 
where Memo_Date = @OrderDate
AND a.SOC_Code IS NOT NULL
AND effective_to = a.memo_date
GROUP BY CTN, BAN, memo_Date, Memo_Agent_ID,Dealer_Code,ISNULL(B.SOC_Group,'Extras_Cancellation'),
a.SOC_Code, ISNULL(B.SOC_Description,'Unknown'),
Effective_From, Effective_To,SOC_LR, Activity_Type,ISNULL(b.CTR,'No')

--PART E - INSERT HANDSET DESPATCHES (Hermes)
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,Booked_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Booked_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Booked_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
CTN,
BAN,
Booked_Date,
NULL,

NULL,
Hermes_User, 

Hermes_ID,
Hermes_ID,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,

NULL,
NULL,
NULL,
NULL,
'Handset',
Handset_Code,
Handset_Description,
1,
Worksheet,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
Despatch_Date,
Cancelled_Date,
Return_Date,
NULL,
NULL,
NULL,
Handset_Cost,

NULL,
Handset_Contribution,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,

NULL,
NULL,
NULL,
NULL,
NULL,
'Handset_Returns',
NEWID()
FROM mireporting.dbo.Handset_Returns
WHERE Booked_Date = @OrderDate
GROUP BY CTN, BAN, Booked_Date, Hermes_User,Hermes_ID, 
Handset_Code, Handset_Description, Worksheet, Despatch_Date, Cancelled_Date, Return_Date,

Handset_Cost, Handset_Contribution

UPDATE tbl_Transaction_backfix
SET Txn_Quantity = B.Quantity
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.Hermes_Sales_Report_History B
ON A.Txn_Flag_A = B.Worksheet
AND A.Txn_ProductCode = B.Stock_Code

WHERE A.Txn_ProductType = 'Handset'
AND Order_Date = @OrderDate



--E1 STORES HANDSETS

INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,SalesDate) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,SalesDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,SalesDate) AS varchar(2))
	ELSE CAST(Datepart(m,SalesDate) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,SalesDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,SalesDate) AS varchar(2))
	ELSE CAST(Datepart(d,SalesDate) AS varchar(2)) END + '_' +
--The CTN
IsNull(BAN,'999999999'),
IsNull(CTN,'00000000000'),
IsNull(BAN,'999999999'),
SalesDate,
NULL,
AgentID,
NULL, 
NULL,
StoreCode,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Handset',
SKU_Code,
Handset_Desc,
1,
Transaction_ID,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
[COS],
NULL,
CASE
	WHEN Sales > 1000 THEN [cos]
	ELSE Sales END,
--ok one off revenue
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Handset_Stores',
NEWID()
FROM mireporting.dbo.Stores_SalesActivity_History
WHERE SalesDate = @OrderDate
GROUP BY CTN, BAN, SalesDate, AgentID,StoreCode,SKU_Code, Handset_Desc, 
Transaction_ID, [COS],Sales 

-- E2 Online Handsets

-- Added by DH - 19/12/2007 
-- Imports Online handsets into transaction table

INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,Booked_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Booked_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Booked_Date) AS varchar(2)) END + '_' +
--The CTN
IsNull(BAN,'999999999'),
CTN,
IsNull(BAN,'999999999'),
Booked_Date,
NULL,
'666900340',
NULL, 
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Handset',
Hermes_Code,
DS_Product,
1,
CAST(OrderID as VARCHAR(30)),
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
nht.Current_Price,
NULL,
CAST(tubc.Delivery_Price AS Money),
--ok one off revenue
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Handset_Online',
newid()
FROM mireporting.dbo.tblOnline_upgrades_Booked_Current tubc
LEFT OUTER JOIN MIReporting.dbo.New_Handset_Table nht
ON (tubc.Hermes_Code = nht.HermesCode
OR
tubc.hermes_code = nht.oracle_code)
WHERE tubc.Booked_Date = @OrderDate
--AND nht.Product_Type = 'Handset'
AND tubc.Product_type = 'Pay Monthly Handset'





--PART F - INSERT ACCESSORY DESPATCHES (Hermes)
--------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,Booked_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Booked_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Booked_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
CTN,
BAN,
Booked_Date,
NULL,
NULL,
Hermes_User, 
Hermes_ID,
Hermes_ID,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Accessory/Other Hardware',
Handset_Code,
Handset_Description,
Handset_Qty,

Worksheet,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
Despatch_Date,
Cancelled_Date,
Return_Date,
NULL,
NULL,
NULL,
Handset_Cost,
NULL,
Handset_Contribution,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,

NULL,
NULL,
NULL,
'Accessory_Returns',
NEWID()
FROM mireporting.dbo.Accessory_Returns
WHERE Booked_Date = @OrderDate
GROUP BY CTN, BAN, Booked_Date, Hermes_User,Hermes_ID, 
Handset_Code, Handset_Description, Worksheet, Despatch_Date, Cancelled_Date, Return_Date,
Handset_Cost, Handset_Contribution, handset_Qty



--PART F1 - INSERT OTHER ACCESSORY ELEMENTS (DELIVERY)
--------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,Booked_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Booked_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Booked_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Booked_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Booked_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
Mobile_Number,
BAN,
Booked_Date,
NULL,
NULL,
Hermes_User, 
Hermes_ID,
Hermes_ID,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Delivery Charges',
Stock_Code,
Handset_Description,
1,
Worksheet,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
B.Current_Price,
NULL,
CAST(Cost AS MONEY),
NULL,

NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Accessory_Other',
NEWID()
FROM mireporting.dbo.Hermes_Sales_Report_Current A LEFT OUTER JOIN  mireporting.dbo.NEW_Handset_Table B
ON A.Stock_Code = B.HermesCode
WHERE Booked_Date = @OrderDate
AND A.Stock_Code NOT IN (SELECT Handset_Code FROM mireporting.dbo.Accessory_Returns)
AND B.Product_Type NOT LIKE 'Handset'
GROUP BY Mobile_Number, BAN, Booked_Date, Hermes_User,Hermes_ID, 
Stock_Code, Handset_Description, Worksheet, B.Current_Price, Cost

UPDATE tbl_Transaction_backfix
SET Txn_OneOff_Cost = (Txn_OneOff_Cost * Txn_Quantity)
WHERE Txn_ProductType IN ('Handset','Accessory/Other Hardware')
AND Order_Date = @OrderDate


--====================================================
--F2 - COM Delivery Info

INSERT INTO tbl_Transaction_backfix
SELECT   
--The year part
CAST(Datepart(yyyy,BookedDate) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,BookedDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,BookedDate) AS varchar(2))
	ELSE CAST(Datepart(m,BookedDate) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,BookedDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,BookedDate) AS varchar(2))
	ELSE CAST(Datepart(d,BookedDate) AS varchar(2)) END + '_' +
--The CTN
BAN,
CTN,
BAN,
BookedDate,
NULL,
NULL,
OrderUser, 
OrderUser,
DealerCode,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Delivery Charges',
ProductID,
ProductDescription,
1,
'COM_' + OrderNumber,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
B.Current_Price,
NULL,
CAST(ProductPrice AS MONEY),
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Accessory_Other',
NEWID()
FROM MIStandardMetrics.dbo.tblSCMHardwareFeedHistory A LEFT OUTER JOIN  mireporting.dbo.NEW_Handset_Table B
ON A.ProductID = B.Oracle_Code
WHERE BookedDate = @OrderDate
AND A.ItemType = 'DeliveryItem'
GROUP BY CTN, BAN, BookedDate, OrderUser,DealerCode, 
ProductID, ProductDescription, OrderNumber, B.Current_Price, ProductPrice





--PART G - INSERT DISCOUNT INFO (Discount Daily Tracker)
----------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix

SELECT   
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END + '_' +
--The CTN
Memo_BAN,
CTN,
Memo_BAN,
Memo_Date,
NULL,
Memo_Agent_ID,
NULL, 
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
CASE
	WHEN Revenue_Code = 'R' THEN 'Recurring Discount'
	WHEN Revenue_Code = 'O' THEN 'Recurring Discount'
	ELSE 'Useage Discount' END,
SOC_Code,
SOC_Description,
1,
Discount_Level,
NULL,
NULL,
NULL,
NULL,
Start_Date,
End_Date,
NULL,
NULL,
NULL,
ISNULL(Datediff(m,Start_Date,End_Date),24),
NULL,
Max_Monthly_Discount_Value,
NULL,
NULL,
NULL,
IsNull(Discount_Percent,NULL),
IsNull(Discount_Amount,NULL),
NULL,
NULL,
NULL,
NULL,

NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Discounts_Daily_Tracker',
NEWID()
FROM mireporting.dbo.Discounts_Daily_Tracker
where Memo_Date = @OrderDate
GROUP BY Memo_BAN,CTN,  memo_Date, Memo_Agent_ID,CASE
	WHEN Revenue_Code = 'R' THEN 'Recurring Discount'
	WHEN Revenue_Code = 'O' THEN 'Recurring Discount'
	ELSE 'Useage Discount' END,
SOC_Code, SOC_Description,Start_Date, End_Date,Max_Monthly_Discount_Value,Discount_Level,
IsNull(Discount_Percent,NULL),IsNull(Discount_Amount,NULL)


--PART H - INSERT CREDIT INFO (All Credits)
---------------------------------------------------------------------------------------------------------------------------
INSERT INTO tbl_Transaction_backfix

SELECT   
--The year part
CAST(Datepart(yyyy,Activity_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Activity_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Activity_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Activity_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Activity_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Activity_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Activity_Date) AS varchar(2)) END + '_' +
--The CTN
BAN,
NULL,
BAN,
Activity_Date,
NULL,
Operator_ID,
NULL, 
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Credit Note',
Reason_Code,
Reason_Description,
1,
Reason_Group,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
Amount,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'tblCreditNotes_Current',
NEWID()
FROM MIStandardMetrics.dbo.tblCreditNotes_Current
--where Memo_Date = @OrderDate
GROUP BY BAN, Activity_Date, Operator_ID,
Reason_Code,Reason_Description,Amount,
Reason_Group




--M IMMEDIATE DISCONNECTION TRANSACTIONS
INSERT INTO tbl_Transaction_backfix
SELECT 
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END + '_' +
--The CTN
memo_BAN,
Memo_CTN,
Memo_BAN,
Memo_Date,
Memo_Agent_ID, 
Memo_Agent_ID, 
NULL,
NULL,
B.Hermes_ID,
B.Name, 
B.TM, 
B.CCM, 
B.Department, 
B.Site, 
NULL,
B.Reporting_Function, 
B.Channel, 
NULL,
B.Business_Unit, 
'Retention',
'Immediate Disconnection',
Memo_Type,
Reason_Group, 
1,
NULL,
NULL,
NULL,
NULL,
NULL,
C.Commitment_Start_Date,
C.Commitment_End_Date,
NULL,
NULL,
NULL,
NULL,
DateDiff(month,Commitment_End_Date,Memo_Date),
0,
35,
0,
0,
0,
0,
0,
0,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
'Immediate Disconnections',
NEWID()
FROM  mireporting.dbo.rep_000794_current A JOIN mireferencetables.dbo.tbl_agents B
ON A.Memo_Agent_ID = B.Gemini_ID
join mireporting.dbo.rep_000805_current C 
ON A.Memo_CTN = C.Subscriber_CTN
WHERE Memo_Date = @OrderDate
AND Notice_Type = 'Immediate'
GROUP BY Memo_Date, Memo_CTN, Memo_BAN, Memo_Agent_ID,  Name, Hermes_ID,
TM, CCM, Site, Department, Reporting_Function, Channel, Business_Unit, 
Reason_Group, Memo_Type, Commitment_Start_Date, Commitment_End_Date


-- --N REBILL REQUESTS
-- INSERT INTO tbl_Transaction_backfix
-- SELECT 
-- --The year part
-- CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
-- --The month part
-- 	CASE
-- 	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
-- 	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
-- --The day part	
-- CASE
-- 	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
-- 	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END + '_' +
-- --The CTN

-- A.BAN,
-- A.CTN,
-- A.BAN,
-- Memo_Date,
-- Memo_Agent_ID, 
-- Memo_Agent_ID, 
-- NULL,
-- NULL,
-- B.Hermes_ID,
-- B.Name, 
-- B.TM, 
-- B.CCM, 
-- B.Department, 
-- B.Site, 


-- NULL,
-- B.Reporting_Function, 
-- B.Channel, 
-- NULL,
-- B.Business_Unit, 
-- 'Retention',
-- 'Other Transactions',
-- Memo_Type,
-- 'Rebill Request', 
-- 1,
-- NULL,
-- NULL,
-- NULL,
-- NULL,

-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- 0,
-- 2.55,
-- 0,
-- 0,
-- 0,
-- 0,
-- 0,
-- 0,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- 
-- NULL,
-- 'Rebill Requests',
--NEWID()
-- FROM  mireporting.dbo.rep_000802_current A LEFT OUTER JOIN mireferencetables.dbo.tbl_agents B
-- ON A.Memo_Agent_ID = B.Gemini_ID
-- WHERE  memo_Date = @OrderDate
-- AND Memo_Type = '2090'
-- GROUP BY Memo_Date, CTN, BAN, Memo_Agent_ID,  Name, Hermes_ID,
-- TM, CCM, Site, Department, Reporting_Function, Channel, Business_Unit, 
-- Memo_Type
-- 
-- --O CHANGE OF PAYMENT METHOD TO NON DD
-- INSERT INTO tbl_Transaction_backfix
-- SELECT 
-- --The year part
-- CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
-- --The month part
-- 	CASE
-- 	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
-- 	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
-- --The day part	
-- CASE
-- 	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
-- 	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END + '_' +
-- --The CTN
-- A.BAN,
-- NULL,
-- A.BAN,
-- Memo_Date,
-- Memo_Agent_ID, 
-- Memo_Agent_ID, 
-- NULL,
-- NULL,
-- B.Hermes_ID,
-- B.Name, 
-- B.TM, 
-- B.CCM, 
-- B.Department, 
-- B.Site, 
-- NULL,
-- B.Reporting_Function, 
-- B.Channel, 
-- NULL,
-- B.Business_Unit, 
-- 'Retention',
-- 'Other Transactions',
-- Memo_Type,
-- Payment_To, 
-- BEN,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- 0,
-- 2.55,
-- 0,
-- 0,
-- 0,
-- 0,
-- 0,
-- 0,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- NULL,
-- 'Change Payment Method',
-- NEWID()
-- FROM mireporting.dbo.Topical_0523_Pym_Meth_Updated A JOIN mireferencetables.dbo.tbl_agents B
-- ON A.Memo_Agent_ID = B.Gemini_ID
-- WHERE Memo_Date = @OrderDate
-- AND Payment_To NOT LIKE '%Direct%'
-- GROUP BY Memo_Date,  BAN, Memo_Agent_ID,  Name, Hermes_ID,
-- TM, CCM, Site, Department, Reporting_Function, Channel, Business_Unit, 
-- Payment_To, Memo_Type, BEN

--K UPDATE AGENT INFO




--Added process to patch up vBusiness and contract length in Acq
EXEC spFixVBusiness


--STAGE 1 - LOGICAL PROCESS TO DETERMINE ORDER OWNER
-------------------------------------------------------------------------------------------

--Fix no CTN where other elements available

UPDATE tbl_Transaction_backfix
SET CTN = B.MaxCTN
FROM tbl_Transaction_backfix A JOIN (SELECT Order_Ref, MAX(CTN) AS MaxCTN FROM tbl_Transaction_backfix WHERE (CTN IS NOT NULL OR CTN NOT LIKE '00000000000') GROUP BY Order_Ref) B
ON A.Order_Ref = B.Order_Ref
WHERE A.CTN IS NULL

CREATE TABLE #DealOwner (
Order_Ref VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
CTN VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
BAN VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
Txn_Agent_ID VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
Txn_Hermes_User VARCHAR(50) NULL)


--Insert all the order numbers
INSERT INTO #DealOwner (Order_Ref, CTN, BAN)
SELECT Order_Ref, CTN, BAN
FROM tbl_Transaction_backfix
WHERE CTN IS NOT NULL
GROUP BY Order_Ref, CTN, BAN

--Firstly insert the contracts (1st in the hierarchy)
--Exclude entries where the Gemini ID has defaulted to 5
UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Contract'
AND B.Txn_Agent_ID NOT LIKE '5'


--Secondly insert handsets (2nd on the hierarchy)
--Populate the Gemini ID where we ca find a match in the agent table
UPDATE #DealOwner
SET Txn_Agent_ID = C.Gemini_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
JOIN MIReferenceTables.dbo.tbl_Agents C
ON B.Txn_Hermes_User = C.Hermes_User
WHERE B.Txn_ProductType = 'Handset'
AND B.Txn_Hermes_User IS NOT NULL
AND A.Txn_Agent_ID IS NULL
AND C.Gemini_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Hermes_User = B.Txn_Hermes_User
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Handset'
AND B.Txn_Hermes_User IS NOT NULL
AND A.Txn_Agent_ID IS NULL
AND B.Txn_Hermes_User NOT LIKE '5'
AND A.Txn_Agent_ID IS NULL


UPDATE #DealOwner
SET Txn_Agent_ID = C.Gemini_ID
FROM #DealOwner A JOIN MIReferenceTables.dbo.tbl_Agents C
ON A.Txn_Hermes_User = C.Hermes_User
WHERE  A.Txn_Hermes_User IS NOT NULL
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User NOT LIKE '5'
AND C.Gemini_ID NOT LIKE '5'


UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Price Plan'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Extras'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType LIKE 'Accessory%'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.BAN = B.BAN
WHERE B.Txn_ProductType LIKE 'Accessory%'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'



UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.BAN = B.BAN
WHERE B.Txn_ProductType LIKE '%Discount%'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.BAN = B.BAN
WHERE B.Txn_ProductType LIKE '%Credit%'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType LIKE 'Immediate%'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType LIKE '%Rebill%'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE #DealOwner
SET Txn_Agent_ID = B.Txn_Agent_ID
FROM #DealOwner A JOIN tbl_Transaction_backfix B
ON A.Order_Ref = B.Order_Ref AND A.BAN = B.BAN
WHERE B.Txn_ProductType LIKE '%Other Transactions%'
AND A.Txn_Agent_ID IS NULL
AND A.Txn_Hermes_User IS NULL
AND B.Txn_Agent_ID NOT LIKE '5'

UPDATE tbl_Transaction_backfix
SET Dl_Agent_ID = B.Txn_Agent_ID
FROM tbl_Transaction_backfix A JOIN #DealOwner B
ON A.Order_Ref = B.Order_Ref 
AND A.CTN = B.CTN
-----AND A.Txn_Agent_ID NOT LIKE '5'

UPDATE tbl_Transaction_backfix
SET Dl_Agent_ID = B.Txn_Hermes_User
FROM tbl_Transaction_backfix A JOIN #DealOwner B
ON A.Order_Ref = B.Order_Ref 
AND A.CTN = B.CTN
WHERE B.Txn_Agent_ID IS NULL
AND B.Txn_Hermes_User IS NOT NULL
AND Dl_Agent_ID IS NULL

UPDATE tbl_Transaction_backfix
SET Dl_Agent_ID = B.Txn_Agent_ID
FROM tbl_Transaction_backfix A JOIN #DealOwner B
ON A.Order_Ref = B.Order_Ref 
AND A.BAN = B.BAN
WHERE A.ctn IS NULL
AND A.Txn_Agent_ID NOT LIKE '5'
AND Dl_Agent_ID IS NULL


UPDATE tbl_Transaction_backfix
SET Dl_Agent_ID = B.Txn_Hermes_User
FROM tbl_Transaction_backfix A JOIN #DealOwner B
ON A.Order_Ref = B.Order_Ref 
AND A.BAN = B.BAN
WHERE B.Txn_Agent_ID IS NULL
AND B.Txn_Hermes_User IS NOT NULL
AND Dl_Agent_ID IS NULL

-- ********************************************************************
-- Altered 11/03/2008 CH / DH
-- Error with including '5' as a gemini ID
-- ********************************************************************

UPDATE tbl_Transaction_backfix
SET Dl_Agent_ID = Txn_Agent_ID
WHERE 
Dl_Agent_ID IS NULL
AND
Txn_Agent_ID not like '5'

-- ********************************************************************
-- Altered 28/04/2009 CH
-- Missing Delivery charges as no Dl_agent on same day
-- ********************************************************************

UPDATE tbl_Transaction_backfix
SET Dl_Agent_ID = Txn_hermes_user
WHERE 
Dl_Agent_ID IS NULL
AND
Txn_hermes_user not like '5'



--UPDATE DEAL TYPE
CREATE TABLE #Deal_Types  (
Order_Ref VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
CTN VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
Deal_Type VARCHAR(50) COLLATE Latin1_General_CI_AS NULL)

INSERT INTO #Deal_Types
SELECT Order_Ref, CTN, Dl_ActivityType
FROM tbl_Transaction_backfix
WHERE Dl_ActivityType IN ('Retention','Acquisition')
AND Txn_ProductType LIKE '%Contract%'
GROUP BY  Order_Ref, CTN, Dl_ActivityType

INSERT INTO #Deal_Types
SELECT Order_Ref, CTN, Dl_ActivityType
FROM tbl_Transaction_backfix
WHERE Dl_ActivityType IN ('Retention','Acquisition')
AND Txn_ProductType LIKE '%Price Plan%'
AND CTN NOT IN (SELECT CTN FROM #Deal_Types)
GROUP BY  Order_Ref, CTN, Dl_ActivityType

INSERT INTO #Deal_Types
SELECT Order_Ref, CTN, Dl_ActivityType
FROM tbl_Transaction_backfix
WHERE Dl_ActivityType IN ('Retention','Acquisition')
AND Txn_ProductType LIKE '%Extras%'
AND CTN NOT IN (SELECT CTN FROM #Deal_Types)
GROUP BY  Order_Ref, CTN, Dl_ActivityType

UPDATE tbl_Transaction_backfix
SET Dl_ActivityType = B.Deal_Type
FROM tbl_Transaction_backfix A JOIN #Deal_Types B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN

UPDATE tbl_Transaction_backfix
SET Dl_ActivityType = 'Retention'
WHERE Dl_ActivityType IS NULL

--TARIFF COSTS


UPDATE tbl_Transaction_backfix
SET Txn_Recurring_Cost = b.LTCost,
Txn_OneOff_Cost = b.TotalShortPromoCosts,
Txn_Recurring_Revenue = b.SOC_LR,
Txn_Flag_A = 'NON CTR',
Txn_Flag_B = 'NON STC',
Txn_Flag_C = 'NON Passport',
Txn_Flag_D = 'NON FLR',
Txn_Flag_E = 'NON Double Minutes'
FROM tbl_Transaction_backfix A JOIN mireferencetables.dbo.vwBenchmark_Costs B
ON A.Txn_ProductCode = B.SOC_Code
WHERE Txn_ProductType IN ('Price plan')

UPDATE tbl_Transaction_backfix
SET  Txn_Recurring_Cost = b.LTCost,
Txn_OneOff_Cost = b.TotalShortPromoCosts,
Txn_Recurring_Revenue = b.SOC_LR,
Txn_Flag_A = 'NON CTR'
FROM tbl_Transaction_backfix A JOIN mireferencetables.dbo.vwBenchmark_Costs B
ON A.Txn_ProductCode = B.SOC_Code
WHERE Txn_ProductType IN ('Extras')

UPDATE tbl_Transaction_backfix
SET Txn_Flag_A = 'CTR'
FROM tbl_Transaction_backfix A JOIN MIReferenceTables.dbo.tbl_SOC_Reference B
ON A.Txn_ProductCode = B.SOC_Code
WHERE Txn_ProductType IN ('Price plan','Extras')
AND B.CTR = 'Yes'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = 'STC'
WHERE (Txn_ProductDescription LIKE '%STC%' OR Txn_ProductDescription LIKE '%Stop The Clock%' )
AND Txn_ProductType = 'Price Plan'


UPDATE tbl_Transaction_backfix
SET Txn_Flag_C = 'VP'
WHERE ( Txn_ProductDescription LIKE '%+ VP %' OR Txn_ProductDescription LIKE '%Passport%'  OR Txn_ProductDescription LIKE '%VP%' )
AND Txn_ProductType = 'Price Plan'

/* Removed as no longer required  DH - 20/01/2010
UPDATE tbl_Transaction_backfix
SET Txn_Flag_D = 'FLR'
FROM tbl_Transaction_backfix A JOIN mireporting.dbo.soc_lookup B
ON A.Txn_ProductCode = B.SOC_Code
WHERE FLRMonths > 0
AND Txn_ProductType = 'Price Plan'
*/

UPDATE tbl_Transaction_backfix
SET Txn_Flag_E = 'Double Minutes'
FROM tbl_Transaction_backfix A 
WHERE Txn_ProductDescription LIKE '%50[%]EM%'
AND Txn_ProductType = 'Price Plan'



UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = B.SOC_SubGroup
FROM  tbl_Transaction_backfix A JOIN MIReferenceTables.dbo.tbl_soc_reference B
ON A.Txn_ProductCode = B.SOC_Code
WHERE Txn_ProductType = 'Extras'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = 'Unknown'
WHERE Txn_Flag_B IS NULL
AND Txn_ProductType = 'Extras'

--UPDATE HANDSET FLAGS




UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = 'Other'
WHERE Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = 'Simply'
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.HermesCode
WHERE Simply = 'True'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = 'Vodafone_Live'
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.HermesCode
WHERE Voda_Live = 'True'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = '3G'
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.HermesCode
WHERE ThreeG_Live = 'True'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_C = B.Handset_Tier
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.HermesCode
AND Txn_ProductType = 'Handset'


UPDATE tbl_Transaction_backfix
SET Txn_Flag_D = B.Stock_Type
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.HermesCode
WHERE Txn_ProductType = 'Handset'
--
UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = 'Simply'
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.Oracle_Code
WHERE Simply = 'True'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = 'Vodafone_Live'
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.Oracle_Code
WHERE Voda_Live = 'True'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_B = '3G'
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.Oracle_Code
WHERE ThreeG_Live = 'True'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_C = B.Handset_Tier
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.Oracle_Code
AND Txn_ProductType = 'Handset'


UPDATE tbl_Transaction_backfix
SET Txn_Flag_D = B.Stock_Type
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.NEW_Handset_Table B
ON A.Txn_ProductCode = B.Oracle_Code
WHERE Txn_ProductType = 'Handset'


CREATE TABLE #Worksheet_Exchanges
(Worksheet VARCHAR(50) NULL,
ExchFlag VARCHAR(50) NULL)

INSERT INTO #Worksheet_Exchanges
SELECT Worksheet, Exchange_Flag
FROM MIReporting.dbo.Handset_Returns
WHERE Booked_Date = @OrderDate

UPDATE  tbl_Transaction_backfix
SET Txn_Flag_E = B.ExchFlag
FROM tbl_Transaction_backfix A JOIN #Worksheet_Exchanges B
ON A.Txn_Flag_A = B.Worksheet
WHERE Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_E = 'Exchange'
WHERE Txn_Flag_E = 'E'
AND Txn_ProductType = 'Handset'

UPDATE tbl_Transaction_backfix
SET Txn_Flag_E = 'New Sale'
WHERE Txn_Flag_E = 'N' OR Txn_Flag_E IS NULL
AND Txn_ProductType = 'Handset'

--UPDATE COST SUMMARY
Update tbl_Transaction_backfix
SET Txn_TotalCost = ISNULL((ISNULL(Txn_Recurring_Cost,0) * Txn_Gross_Period),0) + ISNULL(Txn_OneOff_Cost,0)
WHERE Order_Date = @OrderDate

Update tbl_Transaction_backfix
SET Txn_TotalRevenue = ISNULL((ISNULL(Txn_Recurring_Revenue,0) * Txn_Gross_Period),0) + ISNULL(Txn_OneOff_Revenue,0)
WHERE Order_Date = @OrderDate

--FIX FOR DISCOUNTS
Update tbl_Transaction_backfix
SET Txn_TotalCost = ISNULL((ISNULL(Txn_Recurring_Cost,0) * (Txn_Gross_Period * Txn_PercValue)),0) + ISNULL(Txn_OneOff_Cost,0)
WHERE Txn_PercValue IS NOT NULL
AND Txn_ProductType = 'Recurring Discount'




--OTHER FLAGS

--Base Flags

UPDATE tbl_Transaction_backfix
SET Dl_AccountType = C.Grouping,
Dl_HVCSymbol = B.HVC_Symbol,
Dl_Subscription_Status = Subscriber_status
FROM tbl_Transaction_backfix A LEFT OUTER JOIN mireporting.dbo.rep_000805_current B
ON A.BAN = B.BAN LEFT OUTER JOIN MIReferencetables.dbo.tbl_Gemini_AccountTypes C
ON B.Account_Type = C.Account_Type

UPDATE tbl_Transaction_backfix
SET Dl_ActivityType = 'Acquisition'
FROM tbl_Transaction_backfix A JOIN mireporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN
WHERE ((A.Order_Date >= B.Connection_Date) AND (A.Order_Date < B.Connection_Date + 15))
AND A.Dl_ActivityType IS NULL

UPDATE tbl_Transaction_backfix
SET Dl_ActivityType = 'Retention'
WHERE Dl_ActivityType IS NULL

--DELETE NON CONTRACT TXNs

DELETE FROM tbl_Transaction_backfix
WHERE Txn_Gross_Period < 6
AND Txn_ProductType = 'Contract'



DECLARE @UpdateDate DATETIME, @UpdateDate2 DATETIME, @UpdateDate3 DATETIME, @RoutineFlag VARCHAR(100)
SET @UpdateDate2 = DATEADD(Day,-1,GETDATE())
SET @UpdateDate  = CONVERT(DATETIME,CAST(YEAR(@UpdateDate2) AS VARCHAR(4)) + '-' + CAST(MONTH(@UpdateDate2) AS VARCHAR(2))  + '-' +  CAST(DAY(@UpdateDate2) AS VARCHAR(2)))
SET @UpdateDate3 = CONVERT(DATETIME,CAST(YEAR(@UpdateDate2) AS VARCHAR(4)) + '-' + CAST(MONTH(@UpdateDate2) AS VARCHAR(2))  + '-01')


IF @OrderDate = @UpdateDate 
BEGIN
SET @RoutineFlag = 'Current'
END

IF @OrderDate >= @UpdateDate3 AND @OrderDate < @UpdateDate 
BEGIN
SET @RoutineFlag = 'ThisMonth'
END

IF @OrderDate < @UpdateDate3
BEGIN
SET @RoutineFlag = 'LastMonth'
END

 
IF @RoutineFlag = 'Current'
BEGIN
--UPDATE OF OTHER ACTIVITY DATA
UPDATE tbl_Transaction_backfix
SET Dl_Flag_A = B.SOC_Code
FROM tbl_Transaction_backfix A JOIN
mireporting.dbo.rep_000839_PricePlans B ON A.CTN = B.Subscriber_CTN 
WHERE A.txn_ProductType = 'Price Plan'
END

IF @RoutineFlag = 'ThisMonth'
BEGIN
--UPDATE OF OTHER ACTIVITY DATA
UPDATE tbl_Transaction_backfix
SET Dl_Flag_A = B.SOC_Code
FROM tbl_Transaction_backfix A JOIN
mireporting.dbo.rep_000839_Current B ON A.CTN = B.Subscriber_CTN 
WHERE A.txn_ProductType = 'Price Plan'
AND B.SOC_Service_Type = 'P'
END

IF @RoutineFlag = 'LastMonth'
BEGIN
--UPDATE OF OTHER ACTIVITY DATA
UPDATE tbl_Transaction_backfix
SET Dl_Flag_A = B.SOC_Code
FROM tbl_Transaction_backfix A JOIN
mireporting.dbo.rep_000839_Previous B ON A.CTN = B.Subscriber_CTN 
WHERE A.txn_ProductType = 'Price Plan'
AND B.SOC_Service_Type = 'P'
END


UPDATE tbl_Transaction_backfix
SET Txn_OneOff_Revenue = 2.55
FROM tbl_Transaction_backfix A JOIN
tbl_additional_services_history B 
ON A.BAN = B.BAN
where B.soc_code= 'chq_adfee'
AND B.Effective_To IS NULL
AND A.Txn_ProductType = 'Other Transactions'

--FIX ORDER TYPE AND STATUS


UPDATE tbl_Transaction_backfix
SET Dl_AccountType = C.Grouping,
Dl_HVCSymbol = B.HVC_Symbol,
Dl_Subscription_Status = Subscriber_status,
Dl_Network = B.Network
FROM tbl_Transaction_backfix A LEFT OUTER JOIN mireporting.dbo.rep_000805_current B
ON A.BAN = B.BAN LEFT OUTER JOIN mireferencetables.dbo.tbl_Gemini_AccountTypes C
ON B.Account_Type = C.Account_Type


UPDATE tbl_Transaction_backfix
SET Dl_ActivityType = 'Retention'
FROM  tbl_Transaction_backfix A JOIN mireporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN
WHERE B.Connection_Date < (A.Order_Date - 14)

UPDATE tbl_Transaction_backfix
SET Dl_ActivityType = 'Acquisition'
FROM  tbl_Transaction_backfix 
WHERE CTN NOT IN (SELECT Subscriber_CTN FROM  mireporting.dbo.rep_000805_Current)


-- (SR) Update applied to identify price plan migration type
UPDATE tbl_Transaction_backfix
SET Dl_Flag_B = '(New) - '
FROM tbl_Transaction_backfix A JOIN tbl_PricePlan_Changes B
ON A.CTN = B.memo_CTN AND A.Order_Date = B.Memo_Date AND A.Txn_ProductCode = B.New_SOC_Code 
WHERE B.Order_Type = 'Acquisition'
AND A.Txn_ProductType = 'Price Plan'

UPDATE tbl_Transaction_backfix
SET Dl_Flag_B = '(Mig) - '
FROM tbl_Transaction_backfix A JOIN tbl_PricePlan_Changes B
ON A.CTN = B.memo_CTN AND A.Order_Date = B.Memo_Date AND A.Txn_ProductCode = B.New_SOC_Code 
WHERE B.Order_Type = 'PP_Change'
AND A.Txn_ProductType = 'Price Plan'

UPDATE tbl_Transaction_backfix
SET Dl_Flag_B = '(STCT) - '
FROM tbl_Transaction_backfix A JOIN tbl_PricePlan_Changes B
ON A.CTN = B.memo_CTN AND A.Order_Date = B.Memo_Date AND A.Txn_ProductCode = B.New_SOC_Code 
WHERE B.Order_Type = 'SaveToCurrentTariff'
AND A.Txn_ProductType = 'Price Plan'

UPDATE tbl_Transaction_backfix
SET Dl_Flag_B = Dl_Flag_B + B.Prev_Type + ' to ' + B.New_Type
FROM tbl_Transaction_backfix A JOIN tbl_PricePlan_Changes B
ON A.CTN = B.memo_CTN AND A.Order_Date = B.Memo_Date AND A.Txn_ProductCode = B.New_SOC_Code
WHERE A.Txn_ProductType = 'Price Plan'

--Populate Agent Hierarchy
EXEC MIReporting.dbo.spProcessStart 'spTxnAgentAllocation - Agent Allocation','spPostImportProcessing'
EXEC spTxnAgentAllocation
EXEC MIReporting.dbo.spProcessEnd 'spTxnAgentAllocation - Agent Allocation','spPostImportProcessing'



--Assign RIV Values - requires agent hierarchy to work first

--UPDATE PERIODS
UPDATE tbl_Transaction_backfix
SET Txn_Gross_Period = NULL,
Txn_Net_Period = NULL
WHERE Txn_ProductType  = 'Price Plan'
-- UPDATE tbl_Transaction_backfix
-- SET Dl_AccountType = C.Grouping,
-- Dl_HVCSymbol = B.HVC_Symbol,
-- Dl_Subscription_Status = Subscriber_status
-- FROM tbl_Transaction_backfix A JOIN mireporting.dbo.rep_000805_current B
-- ON A.BAN = B.BAN JOIN mireporting.dbo.Gemini_AccountTypes C
-- ON B.Account_Type = C.Account_Type
-- WHERE Order_Date = @OrderDate 

/* Removed as no longer used - DH - 15/07/2009 

--Update to populate SUI RIV Values
UPDATE tbl_Transaction_backfix
SET Txn_Flag_A = 'SUI/RSC',
Txn_Flag_B = B.Customer_Band,

-- Altered RIV value to be new Enhanced RIV value 

Txn_Flag_C = B.QSUIFinalRIV,
Txn_Flag_D = B.QSUIRIVRemaining
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.TPC_QuoteSummary_History B
ON A.CTN = B.CTN AND A.Order_Date = B.Quote_Date AND A.Dl_Agent_ID = B.Gemini_ID
WHERE A.Txn_ProductType = 'Contract'
and B.Status = 'A'

*/

--Update to populate online RIV Values
UPDATE tbl_Transaction_backfix
SET Txn_Flag_A = 'SUI/RSC',
Txn_Flag_B = B.Upgrade_band,
Txn_Flag_C = CAST(B.PresentedRIV AS Varchar(50)),
Txn_Flag_D = CAST(B.RemainingRIV AS Varchar(50))
FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.tblOnline_upgrades_RIV_Current B
ON A.CTN = B.CTN 
AND A.Order_Date = B.Order_Date
WHERE A.Txn_ProductType = 'Contract' 
AND A.Dl_agent = 'Online'
AND A.Dl_ActivityType = 'retention'


-- -- --Update to populate COM RIV Values
-- -- UPDATE tbl_Transaction_backfix
-- -- SET Txn_Flag_A = 'SUI/RSC',
-- -- Txn_Flag_B = B.Upgrade_band,
-- -- Txn_Flag_C = CAST(B.PresentedRIV AS Varchar(50)),
-- -- Txn_Flag_D = CAST(B.RemainingRIV AS Varchar(50))
-- -- FROM tbl_Transaction_backfix A JOIN MIReporting.dbo.tblOnline_upgrades_RIV_Current B
-- -- ON A.CTN = B.CTN 
-- -- AND A.Order_Date = B.Order_Date
-- -- WHERE A.Txn_ProductType = 'Contract' 
-- -- AND A.Dl_agent_ID = '666900340'
-- -- AND A.Dl_ActivityType = 'retention'
-- -- AND B.Order_Status = 'C'

--Update Transaction Current with details for Successful Quotes in the Frontier Rsc Extract
UPDATE tbl_Transaction_backfix
SET Txn_Flag_A = 'SUI/RSC',
Txn_Flag_B = B.RIV_Band,
Txn_Flag_C = CAST(B.RIV_Total AS VARCHAR(10)),
Txn_Flag_D = CAST(B.RIV_Remaining AS VARCHAR(10))
FROM tbl_Transaction_backfix A 
JOIN MIReporting.dbo.tblRetailRSC_Current B
ON A.CTN = B.CTN AND A.Order_Date = B.Order_Date 
WHERE A.Txn_ProductDescription = 'Retention Contract'
and (b.state = 'Recommitted' or b.state = 'Recommitted with warning')



--Update of COM RIV Values
UPDATE tbl_Transaction_backfix
SET Txn_Flag_A = 'SUI/RSC',
Txn_Flag_B = B.RIVRuleset,
Txn_Flag_C = cast(B.RIVAvailable as varchar(10)),
Txn_Flag_D = 'COM'
FROM tbl_Transaction_backfix A JOIN vwSCMRIVValues B
ON A.CTN = B.CTN AND A.Order_Date = B.OrderCreatedDate AND A.Dl_Agent_ID = B.OrderCreator
WHERE A.Txn_ProductType = 'Contract'
AND cast(B.RIVAvailable as decimal(18,2)) < 9999

--Update of Accord Notional Profit
UPDATE tbl_Transaction_backfix
SET Txn_Flag_A = 'Accord',
Txn_Flag_B = CAST(B.AccordMaxBudget AS VARCHAR(10)),
Txn_Flag_C = CAST(B.AccordTargetBudget AS VARCHAR(10)),
Txn_Flag_D = CAST(B.AccordCost AS VARCHAR(10)),
Txn_Flag_E = CAST(B.AccordNotionalProfit AS VARCHAR(10))
FROM tbl_Transaction_backfix A JOIN tblscmorderheaderallcurrent B
ON A.CTN = B.CTN
WHERE A.Txn_ProductType = 'Contract'
AND B.AccordFlag = 'Accord'


------------------------------------------------------------------------------------------------------------------------
--INSERT INTO HISTORY TABLE

--DELETE FROM tbl_Transaction_History
--WHERE Order_Date = @OrderDate

--INSERT INTO tbl_Transaction_History
--SELECT * FROM tbl_Transaction_backfix
------------------------------------------------------------------------------------------------------------------------


--Send conf SMS

EXEC MIReferenceTables.dbo.spAdminMessages 'Admin','Transaction Current Dev Run Complete'


-- added to test overnights run - ch -29082009

INSERT Mireporting.dbo.tblTEMPOvernightsTest
VALUES (8, getdate())


EXEC MIReporting.dbo.spMasterProcessEnd 'TransactionCurrent'

