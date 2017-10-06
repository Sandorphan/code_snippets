USE [MIStandardMetrics]
GO
/****** Object:  StoredProcedure [dbo].[spInSpireSalesRRODataBackfix]    Script Date: 11/23/2011 08:30:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[spInSpireSalesRRODataBackfix] 
 AS

DECLARE @Days INT

SET @Days = 3


TRUNCATE TABLE tblinSpireSalesDataCurrentRRO

INSERT INTO tblinSpireSalesDataCurrentRRO 
SELECT OrderNumber,
OrderDate,
OrderWeek,
OrderMonth,
CTN,
BAN,
AgentID,
Agent,
Team,
CCM,
Site,
Department,
RFunction,
Channel,
BusinessUnit,
Network,
Segment,
Campaign,
OrderType,
TariffGroup,
SubscriberStatus,
HandsetDescription,
PricePlanDescription,
PricePlanSOC,
ContractGrossVolume,
ContractNetVolume,
ShortTermExtensions,
ContractGrossPeriod,
ContractNetPeriod,
SIMOnlyVolume,
ContractSIMOnly,
MaintenanceOrders,
ContractPeriodSummary,
HandsetVolume,
HandsetCosts,
HandsetSubsidy,
HandsetRevenue,
DatacardVolume,
DatacardCosts,
DatacardSubsidy,
DatacardRevenue,
NetbookVolume,
NetbookCosts,
NetbookSubsidy,
NetbookRevenue,
HandsetExchanges,
HandsetExchangeCost,
AccessoryVolume,
AccessoryCost,
AccessoryRevenue,
DeliveryVolume,
DeliveryCost,
DeliveryRevenue,
CreditNoteVolume,
CreditNoteCost,
PricePlanChanges,
PricePlanSTCT,
PricePlanRecCommCost,
PricePlanFixCommCost,
Services,
ServicesRecCommCost,
ServicesFixCommCost,
Discounts,
DiscountPeriod,
DiscountCosts,
PricePlanLineRental,
GPNotionalProfit,
NPNotionalProfit,
Service1Volume,
Service1BundledVolume,
Service1Profit,
Service2Volume,
Service2BundledVolume,
Service2Profit,
Service3Volume,
Service3BundledVolume,
Service3Profit,
Service4Volume,
Service4BundledVolume,
Service4Profit,
Service5Volume,
Service5BundledVolume,
Service5Profit,
Service6Volume,
Service6BundledVolume,
Service6Profit,
Service7Volume,
Service7BundledVolume,
Service7Profit,
Service8Volume,
Service8BundledVolume,
Service8Profit,
Service9Volume,
Service9BundledVolume,
Service9Profit,
Service10Volume,
Service10BundledVolume,
Service10Profit,
AccordFlag,
AccordMaxBudget,
AccordTargetBudget,
NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tblinspiresalesdataHistoryaccord
WHERE Department IN ('Customer Retention','Outbound Retention')
AND OrderDate >= GetDate()-@Days

/******************************/

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
FROM tblinSpireSalesDataCurrentRRO
GROUP BY OrderNumber, CTN, OrderType, PricePlanLineRental

UPDATE #SIMOVas
SET SIMOProfit = 
CASE WHEN OrderType = 'Acquisition' AND SIMO > 0 THEN 6 * LineRental ELSE 0 END

UPDATE tblinSpireSalesDataCurrentRRO
SET Service1Volume = B.SIMO,
Service1BundledVolume = B.SIMOBundled,
Service1Profit = B.SIMOProfit
FROM tblinSpireSalesDataCurrentRRO A JOIN #SIMOVas B
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
FROM tbl_Transaction_History 
WHERE Txn_ProductCode IN ('INSBAND1','INSBAND2','INSBAND3','IPBAND4','TABINS')
AND Txn_ProductType = 'Extras'
AND Order_Date >= GetDate()-@Days
GROUP BY Order_Ref, CTN, Txn_ProductCode, Txn_Quantity


UPDATE #Insurance
SET INSProfit = INS * 150 WHERE SOC IN ('INSBAND1','INSBAND2','INSBAND3','IPBAND4','TABINS')


UPDATE tblinSpireSalesDataCurrentRRO
SET Service2Volume = B.INS,
Service2BundledVolume = B.INSBundled,
Service2Profit = B.INSProfit
FROM tblinSpireSalesDataCurrentRRO A JOIN #Insurance B
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
FROM tbl_Transaction_History 
WHERE Txn_ProductCode IN ('INT10ONCE','INT10ROLL','INT15ONCE','INT15ROLL','INT20ONCE','INT20ROLL')
AND Txn_ProductType = 'Extras'
AND Order_Date >= GetDate()-@Days
GROUP BY Order_Ref, CTN, Txn_ProductCode,Txn_Quantity

UPDATE #MobInt
SET MintProfit = Mint * 100 WHERE SOC IN ('INT10ONCE','INT10ROLL','INT15ONCE','INT15ROLL','INT20ONCE','INT20ROLL')



UPDATE tblinSpireSalesDataCurrentRRO
SET Service3Volume = B.MInt,
Service3BundledVolume = B.MIntBundled,
Service3Profit = B.MIntProfit
FROM tblinSpireSalesDataCurrentRRO A JOIN #MobInt B
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
FROM tbl_Transaction_History 
WHERE Txn_ProductCode IN ('ATVMI_E')
AND Txn_ProductType = 'Extras'
AND Order_Date >= GetDate()-@Days
GROUP BY Order_Ref, CTN, Txn_ProductCode,Txn_Quantity




UPDATE tblinSpireSalesDataCurrentRRO
SET Service4Volume = B.MInt,
Service4BundledVolume = B.MIntBundled,
Service4Profit = 0
FROM tblinSpireSalesDataCurrentRRO A JOIN #Stuff B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN

--Service 5 ---        HOUSEHOLD VAS



--Service 6 ---        MusicStation


--Service 7 ---        Mob TV


--Service 8 ---        SATNav



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
FROM tbl_Transaction_History
WHERE Txn_ProductCode IN ('YP43UON5','YP4MMS100','YP4MMSVMI','YP4NGEO5','YPL1KLL5','YPLISMS5A','YPLMMS5','YPLNGEO5','YPLUON5','YP41KLL5','YPLNGEO25','YPL1KLNG5','YPLMMS25','DATARMCON','4TRACKPK','CBUMUSIC','MUS10T1MF','25TRACKPK','YP4MMS25 ','YP4NGEO25')
AND Txn_ProductType = 'Extras'
AND Order_Date >= GetDate()-@Days
GROUP BY Order_Ref, CTN, Txn_ProductCode



UPDATE tblinSpireSalesDataCurrentRRO
SET Service9Volume = B.S9SOC,
Service9BundledVolume = B.S9Bund,
Service9Profit = B.S9Prof
FROM tblinSpireSalesDataCurrentRRO A JOIN (SELECT OrderNo, CTN, SUM(MMSBundled) AS S9Bund, SUM(MMS) AS S9SOC, SUM(MMSProfit) AS S9ProfFROM #CTRSales GROUP BY OrderNo, CTN) B
ON A.OrderNumber = B.OrderNo
AND A.CTN = B.CTN



/*********************************/
UPDATE tblinSpireSalesDataCurrentRRO
SET GPNotionalProfit = (ContractGrossPeriod * PricePlanLineRental),
NPNotionalProfit = (ContractnetPeriod * PricePlanLineRental)
WHERE ContractGrossVolume > 0


CREATE TABLE #Discounts (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOC VARCHAR(100),
DiscVol INT,
DiscPeriod INT,
DiscCost MONEY,
DiscFullCost MONEY,
SOCType VARCHAR(10))

INSERT INTO #Discounts
SELECT Order_Ref, CTN, Txn_ProductCode, Txn_Quantity, Txn_Gross_Period, Txn_Recurring_Cost,0, NULL
FROM tbl_Transaction_History
WHERE Txn_ProductType LIKE '%Discount%'
AND Order_Date >= GetDate()-@Days

UPDATE #Discounts
SET SOCType = B.Service_Type
FROM #Discounts A JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.SOC = B.SOC_Code


UPDATE #Discounts
SET DiscFullCost = DiscPeriod * DiscCost

CREATE TABLE #DiscountsSummary (
OrderNo VARCHAR(100),
CTN VARCHAR(100),
SOCType VARCHAR(10),
DiscVol INT,
DiscPeriod INT,
DiscCost MONEY)

INSERT INTO #DiscountsSummary
SELECT OrderNo, CTN, SOCType, SUM(DiscVol), SUM(DiscPeriod), SUM(DiscFullCost)
FROM #Discounts 
GROUP BY OrderNo, CTN,SOCType


UPDATE tblinSpireSalesDataCurrentRRO
SET DiscountPPCosts = B.DiscCost
FROM tblinSpireSalesDataCurrentRRO A JOIN #DiscountsSummary B
ON A.CTN = B.CTN
AND B.SOCType = 'P'

UPDATE tblinSpireSalesDataCurrentRRO
SET DiscountSVCosts = B.DiscCost
FROM tblinSpireSalesDataCurrentRRO A JOIN #DiscountsSummary B
ON A.CTN = B.CTN
AND (B.SOCType <> 'P' OR B.SOCType IS NULL)

UPDATE tblinSpireSalesDataCurrentRRO
SET DiscountPPCosts = ISNULL(DiscountPPCosts,0),
DiscountSVCosts = ISNULL(DiscountSVCosts,0)


UPDATE tblinSpireSalesDataCurrentRRO
SET DiscountCosts = (ISNULL(DiscountPPCosts,0) + ISNULL(DiscountSVCosts,0))


UPDATE tblinSpireSalesDataCurrentRRO
SET SIMORevenue = GPNotionalProfit + Service1Profit + Service2Profit + Service3Profit + Service4Profit + Service5Profit + Service6Profit + Service7Profit + Service8Profit + Service9Profit
WHERE ContractSIMONly > 0

UPDATE tblinSpireSalesDataCurrentRRO
SET SIMORevenue = ISNULL(SIMORevenue,0)

UPDATE tblinSpireSalesDataCurrentRRO
SET DiscountPPPenalty = DiscountPPCosts * 0.5,
DiscountSVPenalty = DiscountSVCosts * 0.5

UPDATE tblinSpireSalesDataCurrentRRO
SET DiscountPPPenalty = ISNULL(DiscountPPPenalty,0),
DiscountSVPenalty = ISNULL(DiscountSVPenalty,0)


DELETE FROM tblinSpireSalesDataHistoryRRO
WHERE OrderDate >= @Days

INSERT INTO tblinSpireSalesDataHistoryRRO
SELECT * FROM tblinSpireSalesDataCurrentRRO

--SELECT TOP 50 * FROM tblinSpireSalesDataCurrentRRO
--WHERE Team = 'Colin Finney'
--AND CTN IS NOT NULL

TRUNCATE TABLE tblinSpireSalesDataSummaryRRO_Daily

INSERT INTO tblinSpireSalesDataSummaryRRO_Daily
SELECT OrderDate,
OrderWeek,
OrderMonth,
Agent,Team,
CCM,
Site,
Department,
RFunction,
Channel,
BusinessUnit,
Network,
Segment,
Campaign,
OrderType,
TariffGroup,
SubscriberStatus,
AccordFlag,
SUM(ContractGrossVolume),
SUM(CASE WHEN AccordFlag = 'Accord' THEN ContractGrossVolume ELSE 0 END),
SUM(ContractNetVolume),
SUM(ShortTermExtensions),
SUM(ContractGrossPeriod),
SUM(ContractNetPeriod),
SUM(SIMOnlyVolume),
SUM(ContractSIMOnly),
SUM(MaintenanceOrders),
ContractPeriodSummary,
SUM(HandsetVolume),
SUM(HandsetCosts),
SUM(HandsetSubsidy),
SUM(HandsetRevenue),
SUM(DatacardVolume),
SUM(DatacardCosts),
SUM(DatacardSubsidy),
SUM(DatacardRevenue),
SUM(NetbookVolume),
SUM(NetbookCosts),
SUM(NetbookSubsidy),
SUM(NetbookRevenue),
SUM(HandsetExchanges),
SUM(HandsetExchangeCost),
SUM(AccessoryVolume),
SUM(AccessoryCost),
SUM(AccessoryRevenue),
SUM(DeliveryVolume),
SUM(DeliveryCost),
SUM(DeliveryRevenue),
SUM(CreditNoteVolume),
SUM(CreditNoteCost),
SUM(PricePlanChanges),
SUM(PricePlanSTCT),
SUM(PricePlanRecCommCost),
SUM(PricePlanFixCommCost),
SUM(Services),
SUM(ServicesRecCommCost),
SUM(ServicesFixCommCost),
SUM(Discounts),
SUM(DiscountPeriod),
SUM(DiscountCosts),
SUM(PricePlanLineRental),
SUM(GPNotionalProfit),
SUM(NPNotionalProfit),
SUM(Service1Volume),
SUM(Service1BundledVolume),
SUM(Service1Profit),
SUM(Service2Volume),
SUM(Service2BundledVolume),
SUM(Service2Profit),
SUM(Service3Volume),
SUM(Service3BundledVolume),
SUM(Service3Profit),
SUM(Service4Volume),
SUM(Service4BundledVolume),
SUM(Service4Profit),
SUM(Service5Volume),
SUM(Service5BundledVolume),
SUM(Service5Profit),
SUM(Service6Volume),
SUM(Service6BundledVolume),
SUM(Service6Profit),
SUM(Service7Volume),
SUM(Service7BundledVolume),
SUM(Service7Profit),
SUM(Service8Volume),
SUM(Service8BundledVolume),
SUM(Service8Profit),
SUM(Service9Volume),
SUM(Service9BundledVolume),
SUM(Service9Profit),
SUM(Service10Volume),
SUM(Service10BundledVolume),
SUM(Service10Profit),
SUM(AccordMaxBudget),
SUM(AccordTargetBudget),
SUM(NewMaxBudget),
SUM(NewTargetBudget),
SUM(DiscountPPPenalty),
SUM(DiscountSVPenalty),
SUM(SIMORevenue),
SUM(DiscountPPCosts),
SUM(DiscountSVCosts)
FROM tblinSpireSalesDataCurrentRRO
GROUP BY 
OrderDate,
OrderWeek,
OrderMonth,
Agent,
Team,
CCM,
Site,
Department,
RFunction,
Channel,
BusinessUnit,
Network,
Segment,
Campaign,
OrderType,
TariffGroup,
SubscriberStatus,
ContractPeriodSummary,
AccordFlag


DELETE FROM tblinSpireSalesDataSummaryRRO_History
WHERE OrderDate >= @Days

INSERT INTO tblinSpireSalesDataSummaryRRO_History
SELECT * FROM tblinSpireSalesDataSummaryRRO_Daily


--The Margin Tables
TRUNCATE TABLE tblInspireMarginDataSummaryRRO_Current

INSERT INTO tblInspireMarginDataSummaryRRO_Current
SELECT OrderDate, OrderWeek, OrderMonth, Agent, Team, CCM, Department, Site, RFunction, Channel, BusinessUnit, 
SUM(CASE WHEN OrderType = 'Retention' THEN ContractGrossVolume ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN AccordContracts ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' AND SIMOnlyVolume > 0 THEN SimOnlyVolume - ContractSIMOnly ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN Service9Volume ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN (GPNotionalProfit + Service1Profit + Service2Profit + Service3Profit + Service4Profit + Service5Profit +Service6Profit + Service7Profit + Service8Profit + Service9Profit) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN (HandsetCosts + DatacardCosts + NetbookCosts + AccessoryCost + DeliveryCost + CreditNoteCost) - (HandsetRevenue + HandsetSubsidy + DatacardRevenue + NetbookRevenue + AccessoryRevenue + DeliveryRevenue  + Service10Profit) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN (PricePlanRecCommCost + PricePlanFixCommCost + ServicesRecCommCost + ServicesFixCommCost + DiscountCosts) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN GPNotionalProfit ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN (Service1Profit + Service2Profit + Service3Profit + Service4Profit + Service5Profit +Service6Profit + Service7Profit + Service8Profit + Service9Profit) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN (HandsetCosts + DatacardCosts + NetbookCosts + AccessoryCost + DeliveryCost) - (HandsetRevenue + HandsetSubsidy + DatacardRevenue + NetbookRevenue + AccessoryRevenue + DeliveryRevenue  + Service10Profit) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN SIMORevenue ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN (PricePlanRecCommCost + PricePlanFixCommCost + ServicesRecCommCost + ServicesFixCommCost + DiscountPPPenalty + DiscountSVPenalty) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN  DiscountPPCosts ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN  DiscountSVCosts ELSE 0 END),
SUM(CASE WHEN OrderType = 'Retention' THEN CreditNoteCost ELSE 0 END),

--SUM(CASE WHEN OrderType = 'Retention' THEN MaxBudget ELSE 0 END),
SUM(CASE WHEN OrderType = 'Acquisition' THEN ContractGrossVolume ELSE 0 END),
SUM(CASE WHEN OrderType = 'Acquisition' AND SIMOnlyVolume > 0 THEN SimOnlyVolume - ContractSIMOnly ELSE 0 END),
SUM(CASE WHEN OrderType = 'Acquisition' THEN GPNotionalProfit + Service1Profit + Service2Profit + Service3Profit + Service4Profit + Service5Profit +Service6Profit + Service7Profit + Service8Profit + Service9Profit ELSE 0 END),
SUM(CASE WHEN OrderType = 'Acquisition' THEN (HandsetCosts + DatacardCosts + NetbookCosts + AccessoryCost + DeliveryCost + CreditNoteCost) - (HandsetRevenue + HandsetSubsidy + DatacardRevenue + NetbookRevenue + AccessoryRevenue + DeliveryRevenue + Service10Profit) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Acquisition' THEN (PricePlanRecCommCost + PricePlanFixCommCost + ServicesRecCommCost + ServicesFixCommCost + DiscountCosts) ELSE 0 END),
SUM(CASE WHEN OrderType = 'Acquisition' THEN Service9Volume ELSE 0 END),
SUM(CASE WHEN OrderType = 'Maintenance' THEN MaintenanceOrders ELSE 0 END),
SUM(CASE WHEN OrderType = 'Maintenance' THEN Service9Volume ELSE 0 END),
SUM(CASE WHEN OrderType = 'Maintenance' THEN (HandsetCosts + DatacardCosts + NetbookCosts + AccessoryCost + DeliveryCost + CreditNoteCost + DiscountCosts) - (HandsetRevenue +  HandsetSubsidy+ DatacardRevenue + NetbookRevenue + AccessoryRevenue + DeliveryRevenue + Service10Profit) ELSE 0 END),
0,0,0,0,0
FROM tblinSpireSalesDataSummaryRRO_Daily
GROUP BY OrderDate, OrderWeek, OrderMonth, Agent, Team, CCM, Department, Site, RFunction, Channel, BusinessUnit


DELETE FROM tblInspireMarginDataSummaryRRO_History
WHERE OrderDate >= @Days

INSERT INTO tblInspireMarginDataSummaryRRO_History
SELECT * FROM tblInspireMarginDataSummaryRRO_Current



--Update SalesData


UPDATE tblInspireMarginDataSummaryRRO_History
SET Inbound_Calls = B.ACDCalls,
Outbound_Calls = B.OBDCallsConv + B.IBDCallsConv
FROM tblInspireMarginDataSummaryRRO_History A
JOIN  tblinSpireCallsFeedHistory B
ON A.Agent = B.Agent AND A.TM = B.Team AND A.OrderDate = B.CallDate


INSERT INTO tblInspireMarginDataSummaryRRO_History
SELECT CallDate, NULL, NULL, A.Agent, A.Team, A.CCM, A.Department, A.Site, A.RFunction, A.Channel, A.BusUnit,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,A.IBCalls, A.OBCalls,0,0,0
FROM vwInspireSUMCalls A LEFT OUTER JOIN tblInspireMarginDataSummaryRRO_History B
ON A.Agent = B.Agent AND A.Team = B.TM AND A.CallDate = B.OrderDate
WHERE B.OrderDate IS NULL
AND A.Agent IS NOT NULL
AND IBCalls + OBCalls > 0
AND CallDate > '08-31-2011'
AND A.Department = 'Customer Retention'

INSERT INTO tblInspireMarginDataSummaryRRO_History
SELECT WorkDate, NULL, NULL, A.Agent, A.TM, A.CCM, A.Department, A.Site, A.RFunction, A.Channel, A.BusinessUnit,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,GrossManday,0,0
FROM tblInSpireIEXDataNew_History A LEFT OUTER JOIN tblInspireMarginDataSummaryRRO_History B
ON A.Agent = B.Agent AND A.TM = B.TM AND A.Workdate = B.OrderDate
WHERE B.OrderDate IS NULL
AND A.Agent IS NOT NULL
AND GrossManday > 0
AND WorkDate > '08-31-2011'
AND A.Department = 'Customer Retention'
GROUP BY WorkDate, A.Agent, A.TM, A.CCM, A.Department, A.Site, A.RFunction, A.Channel, A.BusinessUnit, GrossManday



UPDATE tblInspireMarginDataSummaryRRO_History
SET OrderWeek = B.WeekText,
OrderMonth = B.MonthText
FROM tblInspireMarginDataSummaryRRO_History A JOIN MIReferencetables.dbo.tbl_ref_dates B
ON A.OrderDate = B.NewDate
WHERE OrderWeek IS NULL

UPDATE tblInspireMarginDataSummaryRRO_History
SET Mandays = B.GrossManday
FROM tblInspireMarginDataSummaryRRO_History A
JOIN  tblInSpireIEXDataNew_History B
ON A.Agent = B.Agent AND A.TM = B.TM AND A.OrderDate = B.WorkDate

UPDATE tblInspireMarginDataSummaryRRO_History
SET RetentionSIRFails = B.SIRFails
FROM tblInspireMarginDataSummaryRRO_History A JOIN tblInSpireSIRSummary B
ON A.OrderDate = B.OrderDate
AND A.Agent = B.Agent
And B.OrderType = 'Retention'

UPDATE tblInspireMarginDataSummaryRRO_History
SET AcquisitionSIRFails = B.SIRFails
FROM tblInspireMarginDataSummaryRRO_History A JOIN tblInSpireSIRSummary B
ON A.OrderDate = B.OrderDate
AND A.Agent = B.Agent
And B.OrderType = 'Acquisition'

UPDATE tblInspireMarginDataSummaryRRO_History
SET RetentionSIRFails = 0
WHERE RetentionSIRFails IS NULL

UPDATE tblInspireMarginDataSummaryRRO_History
SET AcquisitionSIRFails = 0
WHERE AcquisitionSIRFails IS NULL


DELETE FROM tblInspireMarginDataSummaryRRO_History WHERE OrderDate > (SELECT Max(OrderDate) FROM tblInspireMarginDataSummaryRRO_Current)


TRUNCATE TABLE MIOutputs.dbo.tblinSpireSalesDataHistoryRRO
INSERT INTO MIOutputs.dbo.tblinSpireSalesDataHistoryRRO
SELECT * FROM MIStandardMetrics.dbo.tblinSpireSalesDataHistoryRRO

TRUNCATE TABLE MIOutputs.dbo.tblinSpireSalesDataSummaryRRO_History
INSERT INTO MIOutputs.dbo.tblinSpireSalesDataSummaryRRO_History
SELECT * FROM MIStandardMetrics.dbo.tblinSpireSalesDataSummaryRRO_History

TRUNCATE TABLE MIOutputs.dbo.tblInspireMarginDataSummaryRRO_History
INSERT INTO MIOutputs.dbo.tblInspireMarginDataSummaryRRO_History
SELECT * FROM MIStandardMetrics.dbo.tblInspireMarginDataSummaryRRO_History