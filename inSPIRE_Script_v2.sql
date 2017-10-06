ALTER PROCEDURE spInspireData AS


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
WHERE Dl_Department IN ('Customer Saves','Outbound Retention','Direct Sales Inbound')
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
SIMOnlyVolume = CASE WHEN Txn_ProductDescription LIKE 'SIMO%' THEN 1 ELSE 0 END,
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
ContractPeriodSummary = CASE WHEN Txn_Gross_Period < 12 THEN 0 WHEN Txn_Gross_Period < 18 THEN 12 WHEN Txn_Gross_Period < 24 THEN 18 ELSE 24 END
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


DECLARE @StormSubsidy MONEY
DECLARE @N96Subsidy MONEY

SET @StormSubsidy = (SELECT (MAX(Current_Price) - 295) AS StormSubsidy FROM MIReporting.dbo.New_Handset_Table WHERE Handset_Description LIKE '%Storm%' AND Product_Type = 'Handset')
SET @N96Subsidy = (SELECT (MAX(Current_Price) - 275) AS N96Subsidy FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '063860' AND Product_Type = 'Handset')


UPDATE #HandsetSummary
SET HandsetSubsidy = @StormSubsidy * HandsetQty
WHERE OrderType = 'Retention'
AND Txn_ProductCode IN (SELECT Oracle_Code FROM MIReporting.dbo.New_Handset_Table WHERE Handset_Description LIKE '%Storm%' AND Product_Type = 'Handset')

UPDATE #HandsetSummary
SET HandsetSubsidy = @StormSubsidy * HandsetQty
WHERE OrderType = 'Retention'
AND Txn_ProductCode IN (SELECT HermesCode FROM MIReporting.dbo.New_Handset_Table WHERE Handset_Description LIKE '%Storm%' AND Product_Type = 'Handset')


UPDATE #HandsetSummary
SET HandsetSubsidy = @N96Subsidy * HandsetQty
WHERE OrderType = 'Retention'
AND Txn_ProductCode IN (SELECT Oracle_Code FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '063860' AND Product_Type = 'Handset')

UPDATE #HandsetSummary
SET HandsetSubsidy = @N96Subsidy * HandsetQty
WHERE OrderType = 'Retention'
AND Txn_ProductCode IN (SELECT HermesCode FROM MIReporting.dbo.New_Handset_Table WHERE Oracle_Code = '063860' AND Product_Type = 'Handset')

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

INSERT INTO #AccessorySummary
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
INSBundled INT,
INS INT,
INSProfit MONEY)

INSERT INTO #Insurance
SELECT Order_Ref, CTN, 0, Txn_Quantity, Txn_Quantity * 26.48
FROM tbl_Transaction_Current A JOIN MIReferenceTables.dbo.tblSOC_Attributes B
ON A.Txn_ProductCode = B.SOC_Code 
WHERE B.SOC_Attr_13 = 'Y' 
AND A.Txn_ProductType = 'Extras'
GROUP BY Order_Ref, CTN, Txn_Quantity

UPDATE tblinSpireSalesDataCurrent
SET Service2Volume = B.INS,
Service2BundledVolume = B.INSBundled,
Service2Profit = B.INSProfit
FROM tblinSpireSalesDataCurrent A JOIN #Insurance B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 3 ---           MOBILE INTERNET

CREATE TABLE #MobInt (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
MIntBundled INT,
Mint INT,
MintProfit MONEY)

INSERT INTO #MobInt
SELECT Order_Ref, CTN, 0, Txn_Quantity, Txn_Quantity * 34.4
FROM tbl_Transaction_Current A JOIN MIReferenceTables.dbo.tblSOC_Attributes B
ON A.Txn_ProductCode = B.SOC_Code 
WHERE B.SOC_Attr_11 = 'Y' 
AND A.Txn_ProductType = 'Extras'
GROUP BY Order_Ref, CTN, Txn_Quantity

INSERT INTO #MobInt
SELECT Order_Ref, CTN, Txn_Quantity,0,0
FROM tbl_Transaction_Current A JOIN MIReferenceTables.dbo.tblSOC_Attributes B
ON A.Txn_ProductCode = B.SOC_Code 
WHERE B.SOC_Attr_11 = 'Y' 
AND A.Txn_ProductType = 'Price Plan'
GROUP BY Order_Ref, CTN, Txn_Quantity

UPDATE tblinSpireSalesDataCurrent
SET Service3Volume = B.MInt,
Service3BundledVolume = B.MIntBundled,
Service3Profit = B.MIntProfit
FROM tblinSpireSalesDataCurrent A JOIN #MobInt B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 4 ---           BLACKBERRY

CREATE TABLE #BBSales (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
BBBundled INT,
BB INT,
BBProfit MONEY)

INSERT INTO #BBSales
SELECT Order_Ref, CTN, Txn_ProductCode, 0, 1,
CASE WHEN Txn_ProductCode IN ('ATBISWB','ATVBEWB') THEN 54.40
WHEN Txn_ProductCode IN ('ATBIS','ATVBE') THEN 20
ELSE 0 END
FROM tbl_Transaction_Current
WHERE Txn_ProductCode IN ('ATBISWB','ATVBEWB','ATBIS','ATVBE')
AND Txn_ProductType = 'Extras'
GROUP BY Order_Ref, CTN, Txn_ProductCode

UPDATE tblinSpireSalesDataCurrent
SET Service4Volume = B.BB,
Service4BundledVolume = B.BBBundled,
Service4Profit = B.BBProfit
FROM tblinSpireSalesDataCurrent A JOIN #BBSales B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 5 ---         TBA

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
Service5Profit = ISNULL(Service5Profit,0)

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
FROM tblinSpireSalesDataCurrent A JOIN MIReferenceTables.dbo.tblMBBSOCs B
ON A.PricePlanSOC = B.SOC

UPDATE tblinSpireSalesDataCurrent
SET TariffGroup = 'None'
WHERE PricePlanSOC IS NULL

UPDATE tblinSpireSalesDataCurrent
SET TariffGroup = 'Voice'
WHERE TariffGroup IS NULL


UPDATE tblinSpireSalesDataCurrent
SET Campaign = B.Campaign
FROM tblinSpireSalesDataCurrent A JOIN MICampaignSupport.dbo.tblTopicalCampaignTypeByDials B
ON A.CTN = B.CTN AND A.OrderDate = B.Call_Date

UPDATE tblinSpireSalesDataCurrent
SET Campaign = 'Non Campaign'
WHERE Campaign IS NULL

DELETE FROM tblinSpireSalesDataHistory
WHERE OrderDate IN (SELECT OrderDate FROM tblinSpireSalesDataCurrent)

INSERT INTO tblinSpireSalesDataHistory
SELECT * FROM tblinSpireSalesDataCurrent


