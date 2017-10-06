USE [MIReporting]
GO
/****** Object:  StoredProcedure [dbo].[spHandsetReporting_COM]    Script Date: 04/23/2012 09:27:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER                     PROCEDURE [dbo].[spHandsetReporting_COM] @OrderDate DATETIME AS 

/*---------------------HANDSET REPORTING----------------------
Routine to create and update handset sales information from Hermes

Data structure and code implementation by Simon Robinson June 2007
UPDATED PROCEDURE TO REPLACE Handset_Returns_Process procedure

REVISION HISTORY:
============
* COM ORDERS ADDED 20/10/08
* CODE TO POPULATE COM DESPATCHES ADDED (DH) 18/12/08

RELEASE NOTES:
==========
*                                                            
*
*
* 20090729 af - made changes to the indexing of Handset_Returns 

------------------------------------------------------------------------------------------*/


/******  REINSERT THIS STUFF AT END



-- 20090729 af moved the drop exsisting index to start of sp before delets and insert into
IF EXISTS (SELECT name FROM sysindexes WHERE  name = 'IX_CL_HandsetReturns' )
	DROP INDEX  [dbo].[Handset_Returns].IX_CL_HandsetReturns

--REFRESH PAST 45 DAYS HISTORY TO INCLUDE MULTI IMEI ORDERS FROM DESPATCH TABLE

DELETE FROM Handset_Returns
WHERE Booked_Date > @OrderDate-45

-- Create temporary table for last 45 days



*/

DROP TABLE #Handset_Returns

DECLARE @OrderDate DATETIME
SET @OrderDate = '04-22-2012'

CREATE TABLE #Handset_Returns(
	[Worksheet] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Order_Status] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[CTN] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[BAN] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[IMEI] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Booked_Date] [datetime] NULL,
	[Despatch_Date] [datetime] NULL,
	[Cancelled_Date] [datetime] NULL,
	[Return_Date] [datetime] NULL,
	[Handset_Code] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Handset_Description] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Handset_Cost] [money] NULL,
	[Handset_Contribution] [money] NULL,
	[Hermes_User] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Hermes_ID] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Agent] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Team] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[CCM] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Site] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Department] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Rpt_Function] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Channel] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Business_Unit] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Return_Period] [int] NULL,
	[Return_Reason] [varchar](5) COLLATE Latin1_General_CI_AS NULL,
	[Hermes_Type] [char](10) COLLATE Latin1_General_CI_AS NULL,
	[Return_Summary] [varchar](250) COLLATE Latin1_General_CI_AS NULL,
	[Reason_Detail] [varchar](150) COLLATE Latin1_General_CI_AS NULL,
	[Exchange_Flag] [varchar](10) COLLATE Latin1_General_CI_AS NULL
)

-- Insert last 45 days booked sales from Hermes

--INSERT INTO #Handset_Returns (Worksheet,CTN,BAN,IMEI,Booked_Date,Despatch_Date,
--Cancelled_Date,Handset_Code,Handset_Cost, Handset_Contribution, Hermes_User, Hermes_ID,
--Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit, Exchange_Flag)
--SELECT A.Worksheet, A.Mobile_Number, A.BAN, B.IMEI, A.Booked_Date, B.Despatch_Date,
--B.Cancelled_Date, A.Stock_Code, A.Current_Price, CAST(A.Cost AS Money), A.Hermes_User, A.Hermes_ID,
--A.Agent, A.Team, A.CCM, A.Site, A.Department, A.Rpt_Function, A.Channel, A.Business_Unit, A.Exchange_Flag
--FROM Hermes_Sales_Report_History A 
--LEFT OUTER JOIN Hermes_Despatch_Report_History B
--ON A.Worksheet = B.Worksheet AND A.Stock_Code = B.HermesCode
--JOIN New_Handset_Table C
--ON A.Stock_Code = C.HermesCode
--WHERE C.Product_Type = 'Handset'
--AND A.Booked_Date > @OrderDate-45

--INSERT last 45 days COM Sales

INSERT INTO #Handset_Returns (Worksheet,CTN,BAN,IMEI,Booked_Date,Despatch_Date,
Cancelled_Date, Return_Date, Handset_Code,Handset_Cost, Handset_Contribution, Hermes_User, Hermes_ID,
Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit, Exchange_Flag, Return_Reason)
SELECT 'COM_' + OrigOrderNumber, CTN, BAN, ProductIDNumber, BookedDate, DespatchDate, CancelledDate,
ReturnDate, ProductID, ProductCost, ProductPrice, OrderUser, DealerCode, NULL, NULL,
NULL, NULL, NULL, NULL, NULL, NULL, 
CASE WHEN ExchangeFlag = 'Exchange' THEN 'E' ELSE 'N' END, 
CASE WHEN ProductStatus = 'Returned' THEN WarehouseStatus ELSE NULL END
FROM MIStandardMetrics.dbo.tblSCMHardwareFeedHistory A
WHERE BookedDate > @OrderDate-45 
AND ItemType = 'HandsetItem'

INSERT INTO #Handset_Returns (Worksheet,CTN,BAN,IMEI,Booked_Date,Despatch_Date,
Cancelled_Date, Return_Date, Handset_Code,Handset_Cost, Handset_Contribution, Hermes_User, Hermes_ID,
Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit, Exchange_Flag, Return_Reason)
SELECT 'Frontier_' + OrigOrderNumber, CTN, BAN, ProductIDNumber, BookedDate, DespatchDate, CancelledDate,
ReturnDate, ProductID, ProductCost, ProductPrice, OrderUser, DealerCode, NULL, NULL,
NULL, NULL, NULL, NULL, NULL, NULL, 
CASE WHEN ExchangeFlag = 'Exchange' THEN 'E' ELSE 'N' END, 
CASE WHEN ProductStatus = 'Returned' THEN WarehouseStatus ELSE NULL END
FROM MIStandardMetrics.dbo.tblSCMFrontierHardwareFeedHistory A
WHERE BookedDate > @OrderDate-45 
AND ItemType = 'HandsetItem'
AND OrderNumber NOT LIKE 'O%'

INSERT INTO #Handset_Returns (Worksheet,CTN,BAN,IMEI,Booked_Date,Despatch_Date,
Cancelled_Date, Return_Date, Handset_Code,Handset_Cost, Handset_Contribution, Hermes_User, Hermes_ID,
Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit, Exchange_Flag, Return_Reason)
SELECT 'Online_' + OrigOrderNumber, CTN, BAN, ProductIDNumber, BookedDate, DespatchDate, CancelledDate,
ReturnDate, ProductID, ProductCost, ProductPrice, OrderUser, DealerCode, NULL, NULL,
NULL, NULL, NULL, NULL, NULL, NULL, 
CASE WHEN ExchangeFlag = 'Exchange' THEN 'E' ELSE 'N' END, 
CASE WHEN ProductStatus = 'Returned' THEN WarehouseStatus ELSE NULL END
FROM MIStandardMetrics.dbo.tblSCMFrontierHardwareFeedHistory A
WHERE BookedDate > @OrderDate-45 
AND ItemType = 'HandsetItem'
AND OrderNumber LIKE 'O%'





-- Updates Crystal agent details

UPDATE #Handset_Returns
SET Agent = ta.Name
  , Team = ta.TM
  , CCM = ta.CCM
  , Site = ta.Site
  , Department = ta.Department
  , Rpt_Function = ta.Reporting_Function
  , Channel = ta.Channel
  , Business_Unit = ta.Business_Unit
FROM #Handset_Returns hrd JOIN MIReferenceTables.dbo.tbl_agents ta
ON hrd.Hermes_User = ta.Crystal_Login
WHERE Worksheet LIKE 'COM%'
AND Agent is NULL



UPDATE #Handset_Returns
SET Agent = ta.name
  , Team = ta.tm
  , CCM = ta.CCM
  , Site = ta.Site
  , Department = ta.Department
  , Rpt_Function = ta.Reporting_Function
  , Channel = ta.Channel
  , Business_Unit = ta.Business_Unit
FROM #Handset_Returns hrd JOIN MIReferenceTables.dbo.tbl_agents ta
ON right(hrd.Hermes_id,5) = ta.Hermes_ID
WHERE Agent is NULL
AND Worksheet LIKE 'Frontier%'


UPDATE #Handset_Returns
SET Agent = ta.Dealer_Name
  , Team = ta.Dealer_Name
  , CCM = ta.Dealer_Group
  , Site = 'Online'
  , Department = 'Online'
  , Rpt_Function = 'Online'
  , Channel = 'Online'
  , Business_Unit = 'Online'
FROM #Handset_Returns hrd JOIN MIReferenceTables.dbo.vw_gemini_dealercode ta
ON hrd.Hermes_id = ta.Dealer_Code
WHERE Agent is NULL
AND Worksheet LIKE 'Online%'




--UPDATE PRODUCT DESCRIPTION
UPDATE #Handset_Returns
SET Handset_Description = B.Handset_Description,
Handset_Cost = B.Current_Price
FROM #Handset_Returns A JOIN New_Handset_Table B
ON A.Handset_Code = B.Oracle_Code
WHERE Booked_Date > @OrderDate-45




--UPDATES FOR RETURNS

--UPDATE #Handset_Returns
--SET Return_Date = B.Return_Date
--FROM #Handset_Returns A JOIN dbo.Hermes_Returns_Report_History B
--ON A.IMEI = B.IMEI
--AND A.Handset_Code = B.StockCode
--WHERE Booked_Date > @OrderDate-45

--UPDATE #Handset_Returns
--SET Return_Date = B.Ret_Received
--FROM #Handset_Returns A JOIN dbo.Hermes_Returns_DetRet_History B
--ON A.IMEI = B.IMEI
--AND A.Handset_Code = B.Stock
--WHERE Booked_Date > @OrderDate-45
--
--UPDATE #Handset_Returns
--SET Return_Reason = RetCat + RetSubCat
--FROM #Handset_Returns A JOIN dbo.Hermes_Returns_DetRet_History B
--ON A.IMEI = B.IMEI
--WHERE Booked_Date > @OrderDate-45

UPDATE #Handset_Returns
SET Return_Reason = '9999'
WHERE Return_Date IS NOT NULL
AND Return_Reason IS NULL
AND Booked_Date > @OrderDate-45

UPDATE #Handset_Returns
SET Hermes_Type = 'Handset'
WHERE Booked_Date > @OrderDate-45

UPDATE #Handset_Returns
SET Return_Summary = B.Reason_Summary,
Reason_Detail = B.Reason_Detail
FROM #Handset_Returns A JOIN Return_Reason_Codes B
ON A.Return_Reason = B.Code
--WHERE Booked_Date > @OrderDate-45
WHERE Return_Date >= ValidFrom AND Return_Date <= ValidTo
AND Booked_Date > @OrderDate-45

UPDATE #Handset_Returns
SET Return_Summary = StatusDescription
FROM MIReferenceTables.dbo.tblSCMStatusChangeCodes sscc
WHERE #Handset_Returns.Return_Reason = sscc.StatusChangeCode
AND Booked_Date > @OrderDate-45
AND Worksheet LIKE 'COM_%'


--UPDATE THE STATUS OF THE ORDER

UPDATE #Handset_Returns
SET Order_Status = 'Booked'
WHERE Despatch_Date IS NULL AND Cancelled_Date IS NULL
AND Booked_Date > @OrderDate-45

UPDATE #Handset_Returns
SET Order_Status = 'Despatched'
WHERE Despatch_Date IS NOT NULL
AND Booked_Date > @OrderDate-45

UPDATE #Handset_Returns
SET Order_Status = 'Cancelled'
WHERE Cancelled_Date IS NOT NULL
AND Booked_Date > @OrderDate-45

UPDATE #Handset_Returns
SET Order_Status = 'Returned'
WHERE Return_Date IS NOT NULL
AND Booked_Date > @OrderDate-45


SELECT * FROM #Handset_Returns



/*    REINSERT THIS STUFF AT THE END!!  




-- Insert into main table

INSERT INTO Handset_Returns
SELECT * FROM #Handset_Returns

-- Add Index

CREATE CLUSTERED
  INDEX [IX_CL_HandsetReturns] ON [dbo].[Handset_Returns] ([Worksheet], [Order_Status], [CTN], [BAN], [IMEI], [Booked_Date], [Despatch_Date], [Cancelled_Date], [Return_Date], [Handset_Code], [Handset_Description], [Hermes_User], [Agent], [Team], [Department], [Channel])


--EXEC spTACReference

-- Copies yesterdays returns to Outputs for Returns Team report - DH 09/01/2009

EXEC MIOutputs.dbo.spReturnedHandsetsCTNs @OrderDate

INSERT INTO MIOutputs.dbo.Tbl_ReturnedHandsetsCTNs
SELECT   
  CTN 
, BAN 
, Booked_Date 

, Return_Date
, CASE WHEN ret.Return_Reason IS NULL THEN hr.Return_Reason ELSE ret.Return_Reason END
, CASE WHEN ret.Return_Summary IS NULL THEN hr.Return_Summary ELSE ret.Return_Summary END
, Reason_Detail 
, Exchange_Flag 
FROM Handset_Returns hr
LEFT OUTER JOIN	(SELECT 
		  'COM_'+LEFT(Fld2,9) AS Worksheet
		, Fld14 as IMEI
		, Fld15 as Return_Reason
		, CASE WHEN Fld16 IS NULL THEN sscc.StatusDescription ELSE Fld16 END as Return_Summary
		FROM MIStandardMetrics.dbo.tblSCMTempImport sti
		JOIN MIReferenceTables.dbo.tblSCMStatusChangeCodes sscc
		ON sti.Fld15 = sscc.StatusChangeCode
		WHERE Fld1 = 'HandsetItem'
		AND sscc.StatusType = 'Returned'
		) ret
ON hr.Worksheet = ret.Worksheet
AND hr.IMEI = ret.IMEI
WHERE Return_Date = @OrderDate




*/

