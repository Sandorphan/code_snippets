USE [MIStandardMetrics]
GO
/****** Object:  StoredProcedure [dbo].[spInspireData]    Script Date: 06/29/2012 08:58:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER                                                    PROCEDURE [dbo].[spInspireData] AS


/* Table requirements for new reporting suite
SALES VOLUMES AND COMMERCIAL KPIs
Data to capture: */
--GROUP INFORMATION
/*
Temporary routine to drop all temp tables during dev.
DROP TABLE tblinSpireSalesDataCurrent
DROP TABLE #HandsetSummary
DROP TABLE #AccessorySummary
DROP TABLE #DeliverySummary
DROP TABLE #CreditSummaryCTN
DROP TABLE #CreditSummaryBAN
DROP TABLE #CommCost
DROP TABLE #CommCostSummary
DROP TABLE #Discounts
DROP TABLE #DiscountsSummary
DROP TABLE #SIMOVas
DROP TABLE #Insurance
DROP TABLE #BBSales
*/

TRUNCATE TABLE tblinSpireSalesDataCurrent


INSERT INTO tblinSpireSalesDataCurrent (OrderNumber, OrderDate, CTN, BAN, AgentID, Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit, 
Network, Segment, OrderType, SubscriberStatus)
SELECT Order_Ref, Order_Date,  CTN, BAN, Dl_Agent_ID, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
Dl_Network, Dl_AccountType, Dl_ActivityType, Dl_Subscription_Status
FROM tbl_Transaction_Current

--REMOVE PRE GO LIVE - TEST DATA ONLY
--WHERE Dl_Department IN ('Customer Saves','Outbound Retention','Direct Sales Inbound','Customer Returns Management','Customer Retention','Inbound Retention','NES','High Value Retention','Ultra High Value')
GROUP BY Order_Ref, Order_Date,  CTN, BAN, Dl_Agent_ID, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
Dl_Network, Dl_AccountType, Dl_ActivityType, Dl_Subscription_Status


UPDATE tblinSpireSalesDataCurrent
SET OrderWeek = B.WeekText,
OrderMonth = B.MonthText
FROM tblinSpireSalesDataCurrent A JOIN MIReferencetables.dbo.tbl_ref_dates B
ON A.OrderDate = B.NewDate

UPDATE tblinSpireSalesDataCurrent
SET HandsetDescription = B.Txn_ProductDescription
FROM tblinSpireSalesDataCurrent A JOIN tbl_Transaction_Current B
ON A.OrderNumber = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Handset'

UPDATE tblinSpireSalesDataCurrent
SET PricePlanDescription = B.Txn_ProductDescription,
PricePlanSOC = B.Txn_ProductCode,
PricePlanLineRental = B.Txn_Recurring_Revenue,
--SIMOnlyVolume = CASE WHEN Txn_ProductDescription LIKE '%SIMO%' THEN 1 WHEN Txn_ProductDescription LIKE '%Mobile BB%' THEN 1 ELSE 0 END,
SIMOnlyVolume = CASE WHEN Txn_ProductCode IN (SELECT SOCCode FROM MIReferenceTables.dbo.tblSIMOList) THEN 1 ELSE 0 END,
PricePlanChanges = CASE WHEN Txn_ProductCode <> Dl_Flag_A OR Dl_Flag_A IS NULL THEN 1 ELSE 0 END,
PricePlanSTCT = CASE WHEN Txn_ProductCode = Dl_Flag_A THEN 1 ELSE 0 END
FROM tblinSpireSalesDataCurrent A JOIN tbl_Transaction_Current B
ON A.OrderNumber = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Price Plan'

--*********************************************************************************************************************
--                                                                                     Contracts
--*********************************************************************************************************************

UPDATE tblinSpireSalesDataCurrent
SET ContractGrossVolume = CASE WHEN Txn_Gross_Period > 11 THEN 1 ELSE 0 END,
ContractNetVolume = CASE WHEN Txn_Net_Period > 11 THEN 1 ELSE 0 END,
ShortTermExtensions = CASE WHEN Txn_Gross_Period > 0 AND Txn_Gross_Period < 12 THEN 1 ELSE 0 END,
ContractGrossPeriod = Txn_Gross_Period,
ContractNetPeriod = Txn_Net_Period,
ContractPeriodSummary = CASE WHEN Txn_Gross_Period < 6 THEN 0 WHEN Txn_Gross_Period < 12 THEN 6 WHEN Txn_Gross_Period < 18 THEN 12 WHEN Txn_Gross_Period < 24 THEN 18 ELSE 24 END
FROM tblinSpireSalesDataCurrent A JOIN tbl_Transaction_Current B
ON A.OrderNumber = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType LIKE '%Contract%'

UPDATE tblinSpireSalesDataCurrent
SET ContractSIMOnly = CASE WHEN SimOnlyVolume > 0 AND ContractGrossPeriod > 11 THEN 1 ELSE 0 END

UPDATE tblinSpireSalesDataCurrent
SET OrderType = 'Maintenance',
MaintenanceOrders = 1
WHERE SIMOnlyVolume = 0 AND ContractGrossVolume = 0

UPDATE tblinSpireSalesDataCurrent
SET ContractGrossVolume = ISNULL(ContractGrossVolume,0),
ContractNetVolume = ISNULL(ContractNetVolume,0),
ShortTermExtensions = ISNULL(ShortTermExtensions,0),
ContractGrossPeriod = ISNULL(ContractGrossPeriod,0),
ContractNetPeriod = ISNULL(ContractNetPeriod,0),
SIMOnlyVolume = ISNULL(SIMOnlyVolume,0),
MaintenanceOrders = ISNULL(MaintenanceOrders,0),
ContractPeriodSummary = ISNULL(ContractPeriodSummary,0),
PricePlanLineRental = ISNULL(PricePlanLineRental,0),
Network = ISNULL(Network,'VF'),
Segment = ISNULL(Segment,'Consumer'),
SubscriberStatus = ISNULL(SubscriberStatus,'C')



--*****************************************************************************************************************************
--                                                                                                          Handsets
--*****************************************************************************************************************************

CREATE TABLE #HandsetSummary (
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
OrderType VARCHAR(100),
ExchangeFlag VARCHAR(100),
Txn_ProductCode VARCHAR(100), 
HandsetQty INT,
HandsetCost MONEY,
HandsetSubsidy MONEY,
HandsetRev MONEY,
HandsetType VARCHAR(100))

INSERT INTO #HandsetSummary
SELECT
Order_Ref, CTN, Dl_ActivityType, Txn_Flag_E, Txn_ProductCode, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost), 0, SUM(Txn_OneOff_Revenue), 'Handset'
FROM tbl_Transaction_Current B
WHERE B.Txn_ProductType = 'Handset'
GROUP BY Order_Ref, CTN, Dl_ActivityType, Txn_Flag_E, Txn_ProductCode


--DECLARE @StormSubsidy MONEY
--DECLARE @N96Subsidy MONEY
--DECLARE @H1Subsidy MONEY
--DECLARE @M1Subsidy MONEY
--
--SET @StormSubsidy = (SELECT (MAX(Current_Price) - 295) AS StormSubsidy FROM MIReporting.dbo.New_Handset_Table WHERE Handset_Description LIKE '%Storm%' AND Product_Type = 'Handset')
--SET @N96Subsidy = (SELECT (MAX(Current_Price) - 275) AS N96Subsidy FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '063860' AND Product_Type = 'Handset')
---- Replaced to reflect new cost of H1/M1 DH - 01/06/2010
----SET @H1Subsidy = (SELECT (MAX(Current_Price) -  160) AS H1Subsidy FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '067540')
----SET @M1Subsidy = (SELECT (MAX(Current_Price) -  75) AS M1Subsidy FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '067541')
--SET @H1Subsidy = (SELECT (MAX(Current_Price) -  225) AS H1Subsidy FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '067540')
--SET @M1Subsidy = (SELECT (MAX(Current_Price) -  130) AS M1Subsidy FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '067541')
-- 
UPDATE #HandsetSummary
SET HandsetSubsidy = HandsetCost - B.TargetPrice
FROM #HandsetSummary A JOIN MIReferenceTables.dbo.tblHandsetSubsidy B
ON A.Txn_ProductCode = B.DeviceCode



UPDATE #HandsetSummary
SET ExchangeFlag = 'New Sale' WHERE ExchangeFlag IS NULL OR ExchangeFlag = ''

UPDATE #HandsetSummary
SET HandsetType = 'DataCard' 
WHERE Txn_ProductCode IN 
(SELECT Oracle_Code FROM MIReporting.dbo.New_Handset_Table
WHERE Handset_Description   LIKE '%Modem%'  OR Handset_Description  LIKE '%USB%' 
OR Handset_Description  LIKE '%Datacard%' AND Handset_Description  LIKE '%Mobile Connect%'
OR Handset_Description  LIKE '%Data Card%' AND Handset_Description  LIKE '%Option%')

UPDATE #HandsetSummary
SET HandsetType = 'DataCard' 
WHERE Txn_ProductCode IN 
(SELECT HermesCode FROM MIReporting.dbo.New_Handset_Table
WHERE Handset_Description   LIKE '%Modem%'  OR Handset_Description  LIKE '%USB%' 
OR Handset_Description  LIKE '%Datacard%' AND Handset_Description  LIKE '%Mobile Connect%'
OR Handset_Description  LIKE '%Data Card%' AND Handset_Description  LIKE '%Option%')


UPDATE #HandsetSummary
SET HandsetType = 'Netbook' 
WHERE Txn_ProductCode IN 
(SELECT Oracle_Code FROM MIReporting.dbo.New_Handset_Table
WHERE Handset_Description   LIKE '%Netbook%' )

UPDATE #HandsetSummary
SET HandsetType = 'Netbook' 
WHERE Txn_ProductCode IN 
(SELECT HermesCode FROM MIReporting.dbo.New_Handset_Table
WHERE Handset_Description   LIKE '%Netbook%' )




UPDATE tblinSpireSalesDataCurrent
SET HandsetVolume = ISNULL(B.HandsetQty,0),
HandsetCosts = ISNULL(B.HandsetCost,0),
HandsetSubsidy = ISNULL(B.HandsetSubsidy,0),
HandsetRevenue = ISNULL(B.HandsetRev,0)
FROM tblinSpireSalesDataCurrent A JOIN #HandsetSummary B
ON A.OrderNumber = B.OrderNumber AND A.CTN = B.CTN
WHERE B.HandsetType = 'Handset'
AND ExchangeFlag <> 'Exchange'

UPDATE tblinSpireSalesDataCurrent
SET DataCardVolume = ISNULL(B.HandsetQty,0),
DataCardCosts = ISNULL(B.HandsetCost,0),
DataCardSubsidy = ISNULL(B.HandsetSubsidy,0),
DataCardRevenue = ISNULL(B.HandsetRev,0)
FROM tblinSpireSalesDataCurrent A JOIN #HandsetSummary B
ON A.OrderNumber = B.OrderNumber AND A.CTN = B.CTN
WHERE B.HandsetType = 'DataCard'
AND ExchangeFlag <> 'Exchange'

UPDATE tblinSpireSalesDataCurrent
SET NetbookVolume = ISNULL(B.HandsetQty,0),
NetbookCosts = ISNULL(B.HandsetCost,0),
NetbookSubsidy = ISNULL(B.HandsetSubsidy,0),
NetbookRevenue = ISNULL(B.HandsetRev,0)
FROM tblinSpireSalesDataCurrent A JOIN #HandsetSummary B
ON A.OrderNumber = B.OrderNumber AND A.CTN = B.CTN
WHERE B.HandsetType = 'Netbook'
AND ExchangeFlag <> 'Exchange'

UPDATE tblinSpireSalesDataCurrent
SET HandsetExchanges = ISNULL(B.HandsetQty,0),
HandsetExchangeCost = ISNULL(B.HandsetCost,0) - ISNULL(B.HandsetRev,0)
FROM tblinSpireSalesDataCurrent A JOIN #HandsetSummary B
ON A.OrderNumber = B.OrderNumber AND A.CTN = B.CTN
WHERE ExchangeFlag = 'Exchange'


UPDATE tblinSpireSalesDataCurrent
SET HandsetVolume = ISNULL(HandsetVolume,0),
HandsetCosts = ISNULL(HandsetCosts,0),
HandsetSubsidy = ISNULL(HandsetSubsidy,0),
HandsetRevenue = ISNULL(HandsetRevenue,0),
DatacardVolume = ISNULL(DatacardVolume,0),
DataCardCosts = ISNULL(DatacardCosts,0),
DataCardSubsidy = ISNULL(DatacardSubsidy,0),
DataCardRevenue = ISNULL(DataCardRevenue,0),
NetbookVolume = ISNULL(NetbookVolume,0),
NetbookCosts = ISNULL(NetbookCosts,0),
NetbookSubsidy = ISNULL(NetbookSubsidy,0),
NetbookRevenue = ISNULL(NetbookRevenue,0),
HandsetExchanges = ISNULL(HandsetExchanges,0),
HandsetExchangeCost = ISNULL(HandsetExchangeCost,0)


--*****************************************************************************************************************************
--                                                                                                          Accessories
--*****************************************************************************************************************************


CREATE TABLE #AccessorySummary (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
AccVolume INT,
AccCosts MONEY,
AccRev MONEY)

INSERT INTO #AccessorySummary
SELECT Order_Ref, CTN, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost), SUM(Txn_OneOff_Revenue)
FROM tbl_Transaction_Current WHERE Txn_ProductType IN ('Accessory/Other Hardware')
GROUP BY Order_Ref, CTN

UPDATE tblinSpireSalesDataCurrent
SET AccessoryVolume = ISNULL(B.AccVolume,0),
AccessoryCost = ISNULL(B.AccCosts,0),
AccessoryRevenue = ISNULL(B.AccRev,0)
FROM tblinSpireSalesDataCurrent A JOIN #AccessorySummary B
ON A.OrderNumber = B.OrderNo AND A.CTN = B.CTN

UPDATE tblinSpireSalesDataCurrent
SET AccessoryVolume = ISNULL(AccessoryVolume,0),
AccessoryCost = ISNULL(AccessoryCost,0),
AccessoryRevenue = ISNULL(AccessoryRevenue,0)


--*****************************************************************************************************************************
--                                                                                                          Delivery
--*****************************************************************************************************************************


CREATE TABLE #DeliverySummary (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
DelVolume INT,
DelCosts MONEY,
DelRev MONEY)

INSERT INTO #DeliverySummary
SELECT Order_Ref, CTN, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost), SUM(Txn_OneOff_Revenue)
FROM tbl_Transaction_Current WHERE Txn_ProductType IN ('Delivery Charges')
GROUP BY Order_Ref, CTN

UPDATE tblinSpireSalesDataCurrent
SET DeliveryVolume = ISNULL(B.DelVolume,0),
DeliveryCost = ISNULL(B.DelCosts,0),
DeliveryRevenue = ISNULL(B.DelRev,0)
FROM tblinSpireSalesDataCurrent A JOIN #DeliverySummary B
ON A.OrderNumber = B.OrderNo AND A.CTN = B.CTN

UPDATE tblinSpireSalesDataCurrent
SET DeliveryVolume = ISNULL(DeliveryVolume,0),
DeliveryCost = ISNULL(DeliveryCost,0),
DeliveryRevenue = ISNULL(DeliveryRevenue,0)

--*****************************************************************************************************************************
--                                                                                                          Credits
--*****************************************************************************************************************************


CREATE TABLE #CreditSummaryCTN (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
CredVol INT,
CreditVal MONEY)

INSERT INTO #CreditSummaryCTN
SELECT Order_Ref, CTN, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost)
FROM tbl_Transaction_Current WHERE Txn_ProductType IN ('Credit Note')
AND CTN IS NOT NULL
GROUP BY Order_Ref, CTN

CREATE TABLE #CreditSummaryBAN (
OrderNo VARCHAR(100),
BAN VARCHAR(100),
CredVol INT,
CreditVal MONEY)

INSERT INTO #CreditSummaryBAN
SELECT Order_Ref, BAN, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost)
FROM tbl_Transaction_Current WHERE Txn_ProductType IN ('Credit Note')
AND CTN IS  NULL
GROUP BY Order_Ref, BAN


UPDATE tblinSpireSalesDataCurrent
SET CreditNoteVolume = ISNULL(B.CredVol,0),
CreditNoteCost = ISNULL(B.CreditVal,0)
FROM tblinSpireSalesDataCurrent A JOIN #CreditSummaryCTN B
ON A.OrderNumber = B.OrderNo AND A.CTN = B.CTN

UPDATE tblinSpireSalesDataCurrent
SET CreditNoteVolume = ISNULL(B.CredVol,0),
CreditNoteCost = ISNULL(B.CreditVal,0)
FROM tblinSpireSalesDataCurrent A JOIN #CreditSummaryBAN B
ON A.OrderNumber = B.OrderNo AND A.BAN = B.BAN

UPDATE tblinSpireSalesDataCurrent
SET CreditNoteVolume = ISNULL(CreditNoteVolume,0),
CreditNoteCost = ISNULL(CreditNoteCost,0)


--*****************************************************************************************************************************
--                                                                                                          Price Plans & Services
--*****************************************************************************************************************************

CREATE TABLE #CommCost (
OrderNo VARCHAR(100),
OrderDate DATETIME, 
CTN VARCHAR(100),
SOC VARCHAR(100),
SOCType VARCHAR(100),
OrderType VARCHAR(100),
RecCost MONEY,
FixCost MONEY )

INSERT INTO #CommCost
SELECT Order_Ref, Order_Date, CTN, Txn_ProductCode, Txn_ProductType, Dl_ActivityType, 0,0
FROM tbl_Transaction_Current
WHERE Txn_ProductType IN ('Price Plan','Extras')

UPDATE #CommCost
SET RecCost = CAST(B.Recurring AS MONEY),
FixCost = CAST(B.Fixed AS MONEY)
FROM #CommCost A JOIN MIReferenceTables.dbo.tbl_SOC_Commercial_Costs B
ON A.SOC = B.SOC
WHERE A.OrderType = 'Retention'
AND (A.OrderDate BETWEEN B.Eff_Date AND B.Exp_Date)


CREATE TABLE #CommCostSummary (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
PricePlans INT,
Extras INT,
PPRec MONEY,
PPFix MONEY,
EXRec MONEY,
EXFix MONEY )

INSERT INTO #CommCostSummary 
SELECT OrderNo, CTN, 
SUM(CASE WHEN SOCType = 'Price Plan' THEN 1 ELSE 0 END),
SUM(CASE WHEN SOCType = 'Extras' THEN 1 ELSE 0 END),
SUM(CASE WHEN SOCType = 'Price Plan' THEN ISNULL(RecCost,0) ELSE 0 END),
SUM(CASE WHEN SOCType = 'Price Plan' THEN ISNULL(FixCost,0) ELSE 0 END),
SUM(CASE WHEN SOCType = 'Extras' THEN ISNULL(RecCost,0) ELSE 0 END),
SUM(CASE WHEN SOCType = 'Extras' THEN ISNULL(FixCost,0) ELSE 0 END)
FROM #CommCost
GROUP BY OrderNo, CTN

UPDATE tblinSpireSalesDataCurrent
SET PricePlanRecCommCost = B.PPRec * A.ContractGrossPeriod,
PricePlanFixCommCost = b.PPFix,
Services = B.Extras,
ServicesRecCommCost = B.EXRec * A.ContractGrossPeriod,
ServicesFixCommCost = B.EXFix
FROM tblinSpireSalesDataCurrent A JOIN #CommCostSummary B
ON A.OrderNumber = B.OrderNo AND A.CTN = B.CTN

UPDATE tblinSpireSalesDataCurrent
SET PricePlanRecCommCost = 0,
PricePlanFixCommCost = 0
WHERE PricePlanSTCT > 0

UPDATE tblinSpireSalesDataCurrent
SET PricePlanChanges = ISNULL(PricePlanChanges,0),
PricePlanSTCT = ISNULL(PricePlanSTCT,0),
PricePlanRecCommCost = ISNULL(PricePlanRecCommCost,0),
PricePlanFixCommCost = ISNULL(PricePlanFixCommCost,0),
Services = ISNULL(Services,0),
ServicesRecCommCost = ISNULL(ServicesRecCommCost,0),
ServicesFixCommCost = ISNULL(ServicesFixCommCost,0)


--*****************************************************************************************************************************
--                                                                                                          Discounts
--*****************************************************************************************************************************

CREATE TABLE #Discounts (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
DiscVol INT,
DiscPeriod INT,
DiscCost MONEY,
DiscFullCost MONEY)

INSERT INTO #Discounts
SELECT Order_Ref, CTN, Txn_ProductCode, Txn_Quantity, Txn_Gross_Period, Txn_Recurring_Cost,0
FROM tbl_Transaction_Current
WHERE Txn_ProductType LIKE '%Discount%'


UPDATE #Discounts
SET DiscFullCost = DiscPeriod * DiscCost

CREATE TABLE #DiscountsSummary (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
DiscVol INT,
DiscPeriod INT,
DiscCost MONEY)

INSERT INTO #DiscountsSummary
SELECT OrderNo, CTN, SUM(DiscVol), SUM(DiscPeriod), SUM(DiscFullCost)
FROM #Discounts 
GROUP BY OrderNo, CTN

UPDATE tblinSpireSalesDataCurrent
SET Discounts = B.DiscVol,
DiscountPeriod = b.DiscPeriod,
DiscountCosts = B.DiscCost
FROM tblinSpireSalesDataCurrent A JOIN #DiscountsSummary B
ON A.OrderNumber = B.OrderNo AND A.CTN = B.CTN

UPDATE tblinSpireSalesDataCurrent
SET Discounts = ISNULL(Discounts,0),
DiscountPeriod = ISNULL(DiscountPeriod,0),
DiscountCosts = ISNULL(DiscountCosts,0)

--*****************************************************************************************************************************
--                                                                                                          Notional Profit
--*****************************************************************************************************************************

UPDATE tblinSpireSalesDataCurrent
SET GPNotionalProfit = PricePlanLineRental * ContractGrossperiod,
NPNotionalProfit = PricePlanLineRental * ContractNetPeriod

--Service 1 ---           SIM ONLY

CREATE TABLE #SIMOVas (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
OrderType VARCHAR(100),
LineRental MONEY,
SIMOBundled INT,
SIMO INT,
SIMOProfit MONEY)

INSERT INTO #SIMOVas
SELECT OrderNumber, CTN, OrderType, PricePlanLineRental, SUM(ContractSIMOnly), SUM(SIMOnlyVolume) - SUM(ContractSIMOnly),0
FROM tblinSpireSalesDataCurrent
GROUP BY OrderNumber, CTN, OrderType, PricePlanLineRental

UPDATE #SIMOVas
SET SIMOProfit = 
CASE WHEN OrderType = 'Acquisition' AND SIMO > 0 THEN 6 * LineRental ELSE 0 END

UPDATE tblinSpireSalesDataCurrent
SET Service1Volume = B.SIMO,
Service1BundledVolume = B.SIMOBundled,
Service1Profit = B.SIMOProfit
FROM tblinSpireSalesDataCurrent A JOIN #SIMOVas B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 2 ---           INSURANCE

CREATE TABLE #Insurance (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
INSBundled INT,
INS INT,
INSProfit MONEY)

INSERT INTO #Insurance
SELECT Order_Ref, CTN, Txn_ProductCode, 0, Txn_Quantity, 0
FROM tbl_Transaction_Current 
WHERE Txn_ProductCode IN ('INSBAND1','INSBAND2','INSBAND3','IPBAND4','TABINS')
AND Txn_ProductType = 'Extras'
GROUP BY Order_Ref, CTN, Txn_ProductCode, Txn_Quantity

UPDATE #Insurance
SET INSProfit = INS * 150 WHERE SOC IN ('INSBAND1','INSBAND2','INSBAND3','IPBAND4','TABINS')


UPDATE tblinSpireSalesDataCurrent
SET Service2Volume = B.INS,
Service2BundledVolume = B.INSBundled,
Service2Profit = B.INSProfit
FROM tblinSpireSalesDataCurrent A JOIN #Insurance B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 3 ---           INTERNATIONAL

CREATE TABLE #MobInt (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
MIntBundled INT,
Mint INT,
MintProfit MONEY)

INSERT INTO #MobInt
SELECT Order_Ref, CTN, Txn_ProductCode, 0, Txn_Quantity, 0
FROM tbl_Transaction_Current 
WHERE Txn_ProductCode IN ('INT10ONCE','INT10ROLL','INT15ONCE','INT15ROLL','INT20ONCE','INT20ROLL')
AND Txn_ProductType = 'Extras'
GROUP BY Order_Ref, CTN, Txn_ProductCode,Txn_Quantity

UPDATE #MobInt
SET MintProfit = Mint * 100 WHERE SOC IN ('INT10ONCE','INT10ROLL','INT15ONCE','INT15ROLL','INT20ONCE','INT20ROLL')



UPDATE tblinSpireSalesDataCurrent
SET Service3Volume = B.MInt,
Service3BundledVolume = B.MIntBundled,
Service3Profit = B.MIntProfit
FROM tblinSpireSalesDataCurrent A JOIN #MobInt B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 4 ---           ATVE

CREATE TABLE #Stuff (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
MIntBundled INT,
Mint INT,
MintProfit MONEY)

INSERT INTO #Stuff
SELECT Order_Ref, CTN, Txn_ProductCode, 0, Txn_Quantity, 0
FROM tbl_Transaction_Current 
WHERE Txn_ProductCode IN ('ATVMI_E')
AND Txn_ProductType = 'Extras'
GROUP BY Order_Ref, CTN, Txn_ProductCode,Txn_Quantity




UPDATE tblinSpireSalesDataCurrent
SET Service4Volume = B.MInt,
Service4BundledVolume = B.MIntBundled,
Service4Profit = 0
FROM tblinSpireSalesDataCurrent A JOIN #Stuff B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 5 ---        HOUSEHOLD VAS



--Service 6 ---        MusicStation


--Service 7 ---        Mob TV


--Service 8 ---        EBU SPECIFIC - OneNet
CREATE TABLE #OneNetSales (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
MMSBundled INT,
MMS INT,
MMSProfit MONEY)

INSERT INTO #OneNetSales
SELECT Order_Ref, CTN, Txn_ProductCode, 0, 1,0
FROM tbl_Transaction_Current 
WHERE Txn_ProductCode IN (SELECT SOCCode FROM MIReferenceTables.dbo.tblOneNetSOCList)


UPDATE tblinSpireSalesDataCurrent
SET Service8Volume = B.MMS,
Service8BundledVolume = B.MMSBund,
Service8Profit = B.MMSProf
FROM tblinSpireSalesDataCurrent A JOIN (SELECT OrderNo, CTN, SUM(MMSBundled) AS MMSBund, SUM(MMS) AS MMS, SUM(MMSProfit) AS MMSProfFROM #OneNetSales GROUP BY OrderNo, CTN) B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 9 ---        CTR 5 EXTRAS

CREATE TABLE #CTRSales (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
MMSBundled INT,
MMS INT,
MMSProfit MONEY)

INSERT INTO #CTRSales
SELECT Order_Ref, CTN, Txn_ProductCode, 0, 1,
CASE 
WHEN Txn_ProductCode IN ('YP43UON5','YP4MMS100','YP4MMSVMI','YP4NGEO5','YPL1KLL5','YPLISMS5A','YPLMMS5','YPLNGEO5','YPLUON5','YP41KLL5') THEN	60
WHEN Txn_ProductCode IN ('YPLNGEO25','YPL1KLNG5','YPLMMS25','DATARMCON','4TRACKPK','CBUMUSIC','MUS10T1MF','25TRACKPK','YP4MMS25 ','YP4NGEO25') THEN 0.00
ELSE 0 END
FROM tbl_Transaction_Current
WHERE Txn_ProductCode IN ('YP43UON5','YP4MMS100','YP4MMSVMI','YP4NGEO5','YPL1KLL5','YPLISMS5A','YPLMMS5','YPLNGEO5','YPLUON5','YP41KLL5','YPLNGEO25','YPL1KLNG5','YPLMMS25','DATARMCON','4TRACKPK','CBUMUSIC','MUS10T1MF','25TRACKPK','YP4MMS25 ','YP4NGEO25')
AND Txn_ProductType = 'Extras'
GROUP BY Order_Ref, CTN, Txn_ProductCode



UPDATE tblinSpireSalesDataCurrent
SET Service9Volume = B.S9SOC,
Service9BundledVolume = B.S9Bund,
Service9Profit = B.S9Prof
FROM tblinSpireSalesDataCurrent A JOIN (SELECT OrderNo, CTN, SUM(MMSBundled) AS S9Bund, SUM(MMS) AS S9SOC, SUM(MMSProfit) AS S9ProfFROM #CTRSales GROUP BY OrderNo, CTN) B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN


-- Service 10 --- Sure Signal


CREATE TABLE #VSSSales (
OrderDate DATETIME,
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
ProductCode VARCHAR(100),
ProductDescription VARCHAR(100),
ProductCost MONEY,
ProductRevenue MONEY,
Tariff VARCHAR(100),
LineRental MONEY,
AddSOC VARCHAR(100),
SubsidyType VARCHAR(100),
AdditionalContribution MONEY)

--get Vodafone Sure Signal sales from the COM hardware table
INSERT INTO #VSSSales (OrderDate, OrderNumber, CTN, ProductCode, ProductDescription, ProductCost, ProductRevenue)
SELECT BookedDate, OrderNumber, CTN, ProductID, ProductDescription, ProductCost, ProductPrice
FROM MIStandardMetrics.dbo.tblSCMHardwareFeedCurrent
WHERE ProductID = '066965'
AND BookedDate IS NOT NULL

INSERT INTO #VSSSales (OrderDate, OrderNumber, CTN, ProductCode, ProductDescription, ProductCost, ProductRevenue)
SELECT SalesDate, Transaction_ID, CTN, SKU_Code, Item_Type, 0, 0
FROM MIReporting.dbo.TblSureSignal_Current
WHERE SKU_Code = '066965'
AND SalesDate IS NOT NULL


--Get the tariff that was sold at point of sale
UPDATE #VSSSales
SET Tariff = B.New_SOC_Code,
LineRental = B.New_Rate
FROM #VSSSales A JOIN MIStandardMetrics.dbo.tbl_PricePlan_Changes B
ON A.CTN = B.Memo_CTN

--if the sale was standalone, fetch the current tariff the customer is on
UPDATE #VSSSales
SET Tariff = B.SOC_Code,
LineRental = C.Rate
FROM #VSSSales A JOIN MIReporting.dbo.rep_000839_PricePlans B
ON A.CTN = B.Subscriber_CTN JOIN MIReferenceTables.dbo.tblSOCReference C
ON B.SOC_Code = C.SOC_Code
WHERE A.Tariff IS NULL


--Update any additional services sold on the product that could discount it
--need to amend the SOC Code to be relative at the time
UPDATE #VSSSales
SET AddSOC = B.SOC_Code
FROM #VSSSales A JOIN MIStandardMetrics.dbo.tbl_Additional_Services B
ON A.CTN = B.CTN
WHERE B.SOC_Code IN ('VSS512','VSS524')

UPDATE #VSSSales
SET SubsidyType = 
CASE	WHEN AddSOC IS NOT NULL THEN 'HP'
	WHEN LineRental >=33.33 THEN 'VHSpend'
	WHEN LineRental >= 20.83 THEN 'HSpend'
	WHEN LineRental <20.83 THEN 'LSpend'
	ELSE 'Exception' END


UPDATE #VSSSales
SET AdditionalContribution =
CASE 	WHEN SubsidyType = 'HP' THEN ProductCost
	WHEN SubsidyType = 'VHSpend' THEN ProductCost - 20
	WHEN SubsidyType = 'HSpend' THEN ProductCost - 50
	WHEN SubsidyType = 'LSpend' THEN ProductCost - 50
	ELSE 0 END

UPDATE tblinSpireSalesDataCurrent
SET Service10Volume = 1,
Service10BundledVolume = 0,
Service10Profit = B.AdditionalContribution
FROM tblinSpireSalesDataCurrent A JOIN #VSSSales B
ON A.CTN = B.CTN





--Patch up NULLs

UPDATE tblinSpireSalesDataCurrent
SET GPNotionalProfit = ISNULL(GPNotionalProfit,0),
NPNotionalProfit = ISNULL(NPNotionalProfit,0),
Service1Volume = ISNULL(Service1Volume,0),
Service1BundledVolume = ISNULL(Service1BundledVolume,0),
Service1Profit = ISNULL(Service1Profit,0),
Service2Volume = ISNULL(Service2Volume,0),
Service2BundledVolume = ISNULL(Service2BundledVolume,0),
Service2Profit = ISNULL(Service2Profit,0),
Service3Volume = ISNULL(Service3Volume,0),
Service3BundledVolume = ISNULL(Service3BundledVolume,0),
Service3Profit = ISNULL(Service3Profit,0),
Service4Volume = ISNULL(Service4Volume,0),
Service4BundledVolume = ISNULL(Service4BundledVolume,0),
Service4Profit = ISNULL(Service4Profit,0),
Service5Volume = ISNULL(Service5Volume,0),
Service5BundledVolume = ISNULL(Service5BundledVolume,0),
Service5Profit = ISNULL(Service5Profit,0),
Service6Volume = ISNULL(Service6Volume,0),
Service6BundledVolume = ISNULL(Service6BundledVolume,0),
Service6Profit = ISNULL(Service6Profit,0),
Service7Volume = ISNULL(Service7Volume,0),
Service7BundledVolume = ISNULL(Service7BundledVolume,0),
Service7Profit = ISNULL(Service7Profit,0),
Service8Volume = ISNULL(Service8Volume,0),
Service8BundledVolume = ISNULL(Service8BundledVolume,0),
Service8Profit = ISNULL(Service8Profit,0),
Service9Volume = ISNULL(Service9Volume,0),
Service9BundledVolume = ISNULL(Service9BundledVolume,0),
Service9Profit = ISNULL(Service9Profit,0),
Service10Volume = ISNULL(Service10Volume,0),
Service10BundledVolume = ISNULL(Service10BundledVolume,0),
Service10Profit = ISNULL(Service10Profit,0)

--*****************************************************************************************************************************
--                                                                                                          RIV
--*****************************************************************************************************************************

CREATE TABLE #RIVValues (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
RIV MONEY,
DRIV MONEY)

INSERT INTO #RIVValues
SELECT Order_Ref, CTN, CAST(Txn_Flag_C AS MONEY), 0
FROM tbl_Transaction_Current 
WHERE Txn_ProductType = 'Contract' AND Txn_Flag_A = 'SUI/RSC'

UPDATE tblinSpireSalesDataCurrent
SET RIV = B.RIV
FROM tblinSpireSalesDataCurrent A JOIN #RIVValues B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

UPDATE tblinSpireSalesDataCurrent
SET DefaultRIV = B.DefaultRIV
FROM tblinSpireSalesDataCurrent A JOIN dbo.tbl_RIVDefault B
ON A.Department = B.Department
WHERE A.RIV IS NULL
AND A.ContractGrossVolume > 0

UPDATE tblinSpireSalesDataCurrent
SET RIV = ISNULL(RIV,0),
DefaultRIV = ISNULL(DefaultRIV,0)

--*****************************************************************************************************************************
--                                                                                        CAMPAIGNS AND GROUPINGS
--*****************************************************************************************************************************

UPDATE tblinSpireSalesDataCurrent
SET TariffGroup = 'MBB'
FROM tblinSpireSalesDataCurrent A JOIN MIReferenceTables.dbo.tblSIMOList B
ON A.PricePlanSOC = B.SOCCode
WHERE SOCType = 'MBB'

UPDATE tblinSpireSalesDataCurrent
SET TariffGroup = 'SIMOnly'
FROM tblinSpireSalesDataCurrent
WHERE Simonlyvolume > 0
AND TariffGroup IS NULL

UPDATE tblinSpireSalesDataCurrent
SET TariffGroup = 'None'
WHERE PricePlanSOC IS NULL

UPDATE tblinSpireSalesDataCurrent
SET TariffGroup = 'Voice'
WHERE TariffGroup IS NULL

UPDATE tblInSpireSalesDataCurrent
SET TariffGroup = 'Voice - Legacy'
WHERE TariffGroup = 'Voice'
AND PricePlanSOC NOT IN (SELECT SOCCode FROM MIStandardMetrics.dbo.tblSOCGreenFieldTrial)
AND BusinessUnit = 'CBU'



--New update for Termination Type
UPDATE tblinSpireSalesDataCurrent
SET Campaign = B.Job_name
FROM tblinSpireSalesDataCurrent A JOIN MICampaignSupport.dbo.tblTopicalCampaignTypeByDials B
ON A.CTN = B.CTN 
WHERE A.OrderDate = B.Call_Date
AND A.OrderType = 'Retention'

--New update for non campaign diary deals
UPDATE tblinSpireSalesDataCurrent
SET Campaign = 'Diary - Non Campaign'
FROM tblinSpireSalesDataCurrent A JOIN MICampaignSupport.dbo.tblTopicalCampaignTypeByDials B
ON A.CTN = B.CTN 
WHERE A.Campaign IS NULL AND OrderDate > Call_Date-30 
AND A.OrderType = 'Retention'

--New update for Termination Type
UPDATE tblinSpireSalesDataCurrent
SET Campaign = 'Diary - Associated BAN'
FROM tblinSpireSalesDataCurrent A JOIN MICampaignSupport.dbo.tblMasterTerminationRequest_History B
ON A.BAN = B.BAN 
WHERE A.Campaign IS NULL AND OrderDate > B.Date_Added-30 
AND A.OrderType = 'Retention'

--New update for Acquisition
UPDATE tblinSpireSalesDataCurrent
SET Campaign = 'Farm The Base'
FROM tblinSpireSalesDataCurrent A JOIN MIReporting.dbo.rep_000805_Current B
ON A.BAN = B.BAN
WHERE Campaign IS NULL
AND A.OrderType = 'Acquisition'
AND A.Department IN ('Outbound Telesales', 'Direct Sales')
AND A.CTN NOT LIKE B.Subscriber_CTN

--Update PAYT Migrations in From Voda - Voda (as treated as migration not connection)

UPDATE tblinSpireSalesDataCurrent
SET Campaign = 'PAYT Migration In'
FROM tblinSpireSalesDataCurrent A JOIN MIReporting.dbo.tblMigrationsFromPAYT B
ON A.CTN = B.CTN 
WHERE (A.OrderDate >= B.Memo_Date - 7 AND A.OrderDate < B.Memo_Date + 7)
AND A.OrderType = 'Acquisition'
AND A.Department NOT LIKE '%LBM%'

UPDATE tblinSpireSalesDataCurrent
SET Campaign = B.Department_Subset1
FROM tblinSpireSalesDataCurrent A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login
WHERE B.Department = 'LBM Campaigns' 

UPDATE tblinSpireSalesDataCurrent
SET Campaign = B.Department_Subset1
FROM tblinSpireSalesDataCurrent A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID
WHERE B.Department = 'LBM Campaigns' 

UPDATE tblinSpireSalesDataCurrent
SET Campaign = Campaign + ' ' + 'PAYT Migration In'
FROM tblinSpireSalesDataCurrent A JOIN MIReporting.dbo.tblMigrationsFromPAYT B
ON A.CTN = B.CTN 
WHERE (A.OrderDate >= B.Memo_Date - 7 AND A.OrderDate < B.Memo_Date + 7)
AND A.OrderType = 'Acquisition'
AND A.Department = 'LBM Campaigns'

UPDATE tblinSpireSalesDataCurrent
SET Campaign = 'Non Campaign'
WHERE Campaign IS NULL

--WF6352 - New Supplier Campaign - DH 03/11/2011

--UPDATE tblinSpireSalesDataCurrent
--SET Campaign =  B.Dealer_Code
--FROM tblinSpireSalesDataCurrent A 
--JOIN MIReporting.dbo.rep_000805_Current B
--ON A.CTN = B.Subscriber_CTN
--WHERE A.Department = 'New Suppliers'
--AND Campaign = 'Non Campaign'
--
--UPDATE tblinSpireSalesDataCurrent
--SET Campaign =  C.Dealer_Name
--FROM tblinSpireSalesDataCurrent A 
--JOIN MIReferenceTables.dbo.VW_Gemini_DealerCode C
--ON A.Campaign = C.Dealer_Code
--WHERE A.Department = 'New Suppliers'

--End of WF6352


--Fix up order type flag from recent contract activity
-- CREATE TABLE #RecentContracts (
-- CTN VARCHAR(100),
-- OrderDate DATETIME,
-- OrderType VARCHAR(100))
-- 
-- INSERT INTO #RecentContracts
-- SELECT CTN, OrderDate, OrderType
-- FROM tblInspireSalesDataHistory
-- WHERE ContractGrossVolume > 0
-- 
-- 
-- UPDATE tblinSpireSalesDataCurrent
-- SET OrderType = B.OrderType
-- FROM tblinSpireSalesDataCurrent A JOIN #RecentContracts B
-- ON A.CTN = B.CTN
-- WHERE A.OrderDate BETWEEN B.OrderDate AND B.OrderDate + 18

UPDATE tblinSpireSalesDataCurrent
SET OrderType = 'Maintenance' WHERE ContractGrossVolume = 0 AND SIMOnlyVolume = 0



--*******************************************************
--NEW SIMO DUPLICATION FIX SR 26/07/2011

CREATE TABLE #RecentCont (
CTN VARCHAR(100),
BAN VARCHAR(100),
OrderDate DATETIME,
ContractGrossVolume INT,
SIMOnlyVolume INT,
PricePlanSOC VARCHAR(100))

INSERT INTO #RecentCont
SELECT CTN, BAN, OrderDate, ContractGrossVolume, SIMOnlyVolume, PricePlanSOC
FROM dbo.tblinSpireSalesDataHistoryACCORD
WHERE 
OrderDate > GetDate()-18 AND
(
ContractGrossVolume > 0
OR SIMOnlyVolume > 0 )


UPDATE tblInSpireSalesDataCurrent
SET SIMONlyVolume = 0,
ContractSIMOnly = 0,
PricePlanDescription = 'Reported ' + CAST(Datepart(d,B.OrderDate) AS VARCHAR(10)) + '/' + CAST(Datepart(m,B.OrderDate) AS VARCHAR(10)) + ' ' + PricePlanDescription
FROM tblInSpireSalesDataCurrent A
JOIN #RecentCont B
ON A.CTN = B.CTN
AND
A.PricePlanSOC = B.PricePlanSOC
WHERE A.ContractGrossVolume = 0
AND A.SIMOnlyVolume = 1



-- NEEDS TO GO BACK IN FOR LIVE
-- 
DELETE FROM tblinSpireSalesDataHistory
WHERE OrderDate IN (SELECT OrderDate FROM tblinSpireSalesDataCurrent)

INSERT INTO tblinSpireSalesDataHistory
SELECT * FROM tblinSpireSalesDataCurrent








--Delete date if already in table

DECLARE  	@VSSDate DATETIME
SET 		@VSSDate = (SELECT max(OrderDate) FROM tblinspiresalesdatacurrent)


DELETE FROM	 VSSSalesHistory
WHERE		 OrderDate = @VSSDate

--Insert into history table

INSERT INTO 	dbo.VSSSalesHistory(
		OrderDate,
		OrderNumber,
		CTN,
		ProductCode,
		ProductDescription,
		ProductCost,
		ProductRevenue,
		Tariff,
		LineRental,
		AddSOC,
		SubsidyType,
		AdditionalContribution)
Select 		OrderDate,
		OrderNumber,
		CTN,
		ProductCode,
		ProductDescription,
		ProductCost,
		ProductRevenue,
		Tariff,
		LineRental,
		AddSOC,
		SubsidyType,
		AdditionalContribution
FROM		#VSSSales









--Added code to support Accord Sales data

TRUNCATE TABLE tblinSpireSalesDataCurrentACCORD

INSERT INTO dbo.tblinSpireSalesDataCurrentACCORD
SELECT *, 'Non Accord', NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL FROM tblinSpireSalesDataCurrent

UPDATE tblinSpireSalesDataCurrentACCORD
SET AccordFlag = 'Accord',
AccordMaxBudget = B.AccordmaxBudget,
AccordTargetBudget = B.AccordTargetBudget,
AccordCosts = B.AccordCosts,
AccordFCV = B.AccordFVC,
AccordNP = B.AccordNP,
AccordActualCosts = ((HandsetCosts + DatacardCosts + NetbookCosts + AccessoryCost + DeliveryCost + CreditNoteCost)-(HandsetSubsidy + HandsetRevenue + DatacardSubsidy + DatacardRevenue + NetbookSubsidy + NetbookRevenue + DeliveryRevenue)),
AccordTariff = B.Tariff,
AccordDiscount = CASE WHEN B.DiscountFlag = 'SVAP' THEN 'Acc' ELSE 'NonAcc' END
FROM tblinSpireSalesDataCurrentACCORD A JOIN dbo.tblNotionalProfit_AccordValues B
ON A.CTN = B.CTN AND A.OrderDate = B.ModifiedDate AND A.AgentID = B.OrderUser
AND B.OrderState IN (SELECT OrderStatus FROM dbo.tblSCMOrderStatus WHERE ValidOrder = 'True')


UPDATE tblinSpireSalesDataCurrentACCORD
SET AccordAdjNotProfit = AccordFCV - AccordActualCosts


UPDATE tblinSpireSalesDataCurrentACCORD
SET Service1Profit = 0,Service2Profit = 0,Service3Profit = 0,Service4Profit = 0,Service5Profit = 0,Service6Profit = 0,Service7Profit = 0,Service8Profit = 0,Service9Profit = 0,
GPNotionalProfit = 0, NPNotionalProfit = 0
WHERE AccordFlag = 'Accord'

UPDATE tblinSpireSalesDataCurrentACCORD
SET DiscountCosts = 0
WHERE AccordFlag = 'Accord' AND AccordDiscount NOT LIKE 'NonAcc'

UPDATE tblinSpireSalesDataCurrentACCORD
SET PricePlanRecCommCost = 0, PricePlanFixCommCost = 0, ServicesRecCommCost = 0, ServicesFixCommCost = 0
WHERE AccordFlag = 'Accord' AND AccordTariff = PricePlanSOC

--UPDATE tblinSpireSalesDataCurrentACCORD
--SET GPNotionalProfit = AccordFCV,
--NPNotionalProfit = AccordFCV
--WHERE AccordFlag = 'Accord'

--Patch to ensure agents are not paid more than £1200 profit
UPDATE tblinSpireSalesDataCurrentACCORD
SET GPNotionalProfit = CASE WHEN AccordAdjNotProfit > 1200 THEN 1200 + AccordActualCosts ELSE AccordFCV END,
NPNotionalProfit = CASE WHEN AccordAdjNotProfit > 1200 THEN 1200 + AccordActualCosts ELSE AccordFCV END
WHERE AccordFlag = 'Accord'

--SELECT * FROM tblinSpireSalesDataCurrentACCORD WHERE AccordFlag = 'Accord'



UPDATE tblinspiresalesdatacurrentaccord
SET AccordMaxBudget = 0, AccordTargetBudget = 0, AccordCosts = 0, AccordFCV = 0, AccordNP = 0, AccordActualCosts = 0, AccordAdjNotProfit = 0
WHERE ContractGrossVolume = 0

UPDATE tblinspiresalesdatacurrentaccord
SET GPNotionalProfit = 0, NPNotionalProfit = 0
WHERE ContractGrossVolume = 0 AND GPNotionalProfit > 0


DELETE FROM tblinSpireSalesDataHistoryACCORD
WHERE OrderDate IN (SELECT OrderDate FROM tblinSpireSalesDataCurrentACCORD)

INSERT INTO tblinSpireSalesDataHistoryACCORD
SELECT * FROM tblinSpireSalesDataCurrentACCORD








































