DROP TABLE #Handset_Returns


*/-----------------------------------------------------------------------
----AMEND DELETE OUT STATEMENT - DO NOT DELETE COM ORDERS
------------------------------------------------------------------------*/


--REFRESH PAST 45 DAYS HISTORY TO INCLUDE MULTI IMEI ORDERS FROM DESPATCH TABLE
CREATE TABLE #Handset_Returns (
	[Worksheet] [varchar] (15) COLLATE Latin1_General_CI_AS NULL ,
	[Order_Status] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[CTN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[BAN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[IMEI] [varchar] (20) COLLATE Latin1_General_CI_AS NULL ,
	[Booked_Date] [datetime] NULL ,
	[Despatch_Date] [datetime] NULL ,
	[Cancelled_Date] [datetime] NULL ,
	[Return_Date] [datetime] NULL ,
	[Handset_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Handset_Description] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Handset_Cost] [money] NULL ,
	[Handset_Contribution] [money] NULL ,
	[Hermes_User] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Hermes_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Agent] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Team] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[CCM] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Site] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Department] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Rpt_Function] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Channel] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Business_Unit] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Return_Period] [int] NULL ,
	[Return_Reason] [varchar] (5) COLLATE Latin1_General_CI_AS NULL ,
	[Hermes_Type] [char] (10) COLLATE Latin1_General_CI_AS NULL ,
	[Return_Summary] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[Reason_Detail] [varchar] (150) COLLATE Latin1_General_CI_AS NULL ,
	[Exchange_Flag] [varchar] (10) COLLATE Latin1_General_CI_AS NULL )

INSERT INTO #Handset_Returns (Worksheet,CTN,BAN,IMEI,Booked_Date,Despatch_Date,
Cancelled_Date,Handset_Code,Handset_Cost, Handset_Contribution, Hermes_User, Hermes_ID,
Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit, Exchange_Flag)
SELECT A.Worksheet, A.Mobile_Number, A.BAN, B.IMEI, A.Booked_Date, B.Despatch_Date,
B.Cancelled_Date, A.Stock_Code, A.Current_Price, CAST(A.Cost AS Money), A.Hermes_User, A.Hermes_ID,
A.Agent, A.Team, A.CCM, A.Site, A.Department, A.Rpt_Function, A.Channel, A.Business_Unit, A.Exchange_Flag
FROM Hermes_Sales_Report_History A 
LEFT OUTER JOIN Hermes_Despatch_Report_History B
ON A.Worksheet = B.Worksheet AND A.Stock_Code = B.HermesCode
JOIN New_Handset_Table C
ON A.Stock_Code = C.HermesCode
WHERE C.Product_Type = 'Handset'
AND A.Booked_Date > Getdate()-45

INSERT INTO #Handset_Returns (Worksheet,CTN,BAN,IMEI,Booked_Date,Despatch_Date,
Cancelled_Date,Handset_Code,Handset_Cost, Handset_Contribution, Hermes_User, Hermes_ID, 
Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit, Exchange_Flag)
SELECT 'COM_' + OrderNumber, CTN, BAN, NULL, OrderDate, NULL, NULL, ProductID, ProductCost, ProductOverridePrice, 
OrderUser, DealerCode, 'COM Testing','COM Testing','COM Testing','COM Testing','COM Testing','COM Testing','COM Testing','COM Testing', 'N'
FROM MIStandardMetrics.dbo.tblSCMHandsetsCurrent
WHERE OrderDate = '10-16-2008'


UPDATE #Handset_Returns
SET IMEI = B.IMEINumber,
Despatch_Date = '10-16-2008'
FROM #Handset_Returns A JOIN MIStandardMetrics.dbo.tblSCMHandsetsCurrent B
ON SUBSTRING(A.Worksheet,5,20) = B.OrderNumber
WHERE IMEI IS NULL
AND Worksheet LIKE 'COM_%'

--Add Update to sort out the IME and despatch date

--UPDATE PRODUCT DESCRIPTION
UPDATE #Handset_Returns
SET Handset_Description = B.Handset_Description
FROM #Handset_Returns A JOIN New_Handset_Table B
ON A.Handset_Code = B.HermesCode
WHERE Booked_Date > GetDate()-45
AND Worksheet NOT LIKE 'COM%'


--UPDATE PRODUCT DESCRIPTION
UPDATE #Handset_Returns
SET Handset_Description = B.Handset_Description
FROM #Handset_Returns A JOIN New_Handset_Table B
ON A.Handset_Code = B.Oracle_Code
WHERE Booked_Date > GetDate()-45
AND Worksheet LIKE 'COM%'

--UPDATES FOR RETURNS

UPDATE #Handset_Returns
SET Return_Date = B.Return_Date
FROM #Handset_Returns A JOIN dbo.Hermes_Returns_Report_History B
ON A.IMEI = B.IMEI
AND A.Handset_Code = B.StockCode
WHERE Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Return_Date = B.Ret_Received
FROM #Handset_Returns A JOIN dbo.Hermes_Returns_DetRet_History B
ON A.IMEI = B.IMEI
AND A.Handset_Code = B.Stock
WHERE Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Return_Reason = RetCat + RetSubCat
FROM #Handset_Returns A JOIN dbo.Hermes_Returns_DetRet_History B
ON A.IMEI = B.IMEI
WHERE Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Return_Reason = '9999'
WHERE Return_Date IS NOT NULL
AND Return_Reason IS NULL
AND Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Hermes_Type = 'Handset'
WHERE Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Return_Summary = B.Reason_Summary,
Reason_Detail = B.Reason_Detail
FROM #Handset_Returns A JOIN Return_Reason_Codes B
ON A.Return_Reason = B.Code
--WHERE Booked_Date > GetDate()-45
WHERE Return_Date >= ValidFrom AND Return_Date <= ValidTo
AND Booked_Date > GetDate()-45



--UPDATE THE STATUS OF THE ORDER

UPDATE #Handset_Returns
SET Order_Status = 'Booked'
WHERE Despatch_Date IS NULL AND Cancelled_Date IS NULL
AND Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Order_Status = 'Despatched'
WHERE Despatch_Date IS NOT NULL
AND Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Order_Status = 'Cancelled'
WHERE Cancelled_Date IS NOT NULL
AND Booked_Date > GetDate()-45

UPDATE #Handset_Returns
SET Order_Status = 'Returned'
WHERE Return_Date IS NOT NULL
AND Booked_Date > GetDate()-45

EXEC spTACReference
