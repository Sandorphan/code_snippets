DROP TABLE #tblinSpireSalesDataCurrentRRO
DROP TABLE #Discounts
DROP TABLE #DiscountsSummary


CREATE TABLE #tblinSpireSalesDataCurrentRRO (
	[OrderNumber] [varchar](100) NULL,
	[OrderDate] [datetime] NULL,
	[OrderWeek] [varchar](100) NULL,
	[OrderMonth] [varchar](100) NULL,
	[CTN] [varchar](100) NULL,
	[BAN] [varchar](100) NULL,
	[AgentID] [varchar](100) NULL,
	[Agent] [varchar](100) NULL,
	[Team] [varchar](100) NULL,
	[CCM] [varchar](100) NULL,
	[Site] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[RFunction] [varchar](100) NULL,
	[Channel] [varchar](100) NULL,
	[BusinessUnit] [varchar](100) NULL,
	[Network] [varchar](100) NULL,
	[Segment] [varchar](100) NULL,
	[Campaign] [varchar](100) NULL,
	[OrderType] [varchar](100) NULL,
	[TariffGroup] [varchar](100) NULL,
	[SubscriberStatus] [varchar](100) NULL,
	[HandsetDescription] [varchar](100) NULL,
	[PricePlanDescription] [varchar](100) NULL,
	[PricePlanSOC] [varchar](100) NULL,
	[ContractGrossVolume] [int] NULL,
	[ContractNetVolume] [int] NULL,
	[ShortTermExtensions] [int] NULL,
	[ContractGrossPeriod] [int] NULL,
	[ContractNetPeriod] [int] NULL,
	[SIMOnlyVolume] [int] NULL,
	[ContractSIMOnly] [int] NULL,
	[MaintenanceOrders] [int] NULL,
	[ContractPeriodSummary] [int] NULL,
	[HandsetVolume] [int] NULL,
	[HandsetCosts] [money] NULL,
	[HandsetSubsidy] [money] NULL,
	[HandsetRevenue] [money] NULL,
	[DatacardVolume] [int] NULL,
	[DatacardCosts] [money] NULL,
	[DatacardSubsidy] [money] NULL,
	[DatacardRevenue] [money] NULL,
	[NetbookVolume] [int] NULL,
	[NetbookCosts] [money] NULL,
	[NetbookSubsidy] [money] NULL,
	[NetbookRevenue] [money] NULL,
	[HandsetExchanges] [int] NULL,
	[HandsetExchangeCost] [money] NULL,
	[AccessoryVolume] [int] NULL,
	[AccessoryCost] [money] NULL,
	[AccessoryRevenue] [money] NULL,
	[DeliveryVolume] [int] NULL,
	[DeliveryCost] [money] NULL,
	[DeliveryRevenue] [money] NULL,
	[CreditNoteVolume] [int] NULL,
	[CreditNoteCost] [money] NULL,
	[PricePlanChanges] [int] NULL,
	[PricePlanSTCT] [int] NULL,
	[PricePlanRecCommCost] [money] NULL,
	[PricePlanFixCommCost] [money] NULL,
	[Services] [int] NULL,
	[ServicesRecCommCost] [money] NULL,
	[ServicesFixCommCost] [money] NULL,
	[Discounts] [int] NULL,
	[DiscountPeriod] [int] NULL,
	[DiscountCosts] [money] NULL,
	[PricePlanLineRental] [money] NULL,
	[GPNotionalProfit] [money] NULL,
	[NPNotionalProfit] [money] NULL,
	[Service1Volume] [int] NULL,
	[Service1BundledVolume] [int] NULL,
	[Service1Profit] [money] NULL,
	[Service2Volume] [int] NULL,
	[Service2BundledVolume] [int] NULL,
	[Service2Profit] [money] NULL,
	[Service3Volume] [int] NULL,
	[Service3BundledVolume] [int] NULL,
	[Service3Profit] [money] NULL,
	[Service4Volume] [int] NULL,
	[Service4BundledVolume] [int] NULL,
	[Service4Profit] [money] NULL,
	[Service5Volume] [int] NULL,
	[Service5BundledVolume] [int] NULL,
	[Service5Profit] [money] NULL,
	[Service6Volume] [int] NULL,
	[Service6BundledVolume] [int] NULL,
	[Service6Profit] [money] NULL,
	[Service7Volume] [int] NULL,
	[Service7BundledVolume] [int] NULL,
	[Service7Profit] [money] NULL,
	[Service8Volume] [int] NULL,
	[Service8BundledVolume] [int] NULL,
	[Service8Profit] [money] NULL,
	[Service9Volume] [int] NULL,
	[Service9BundledVolume] [int] NULL,
	[Service9Profit] [money] NULL,
	[Service10Volume] [int] NULL,
	[Service10BundledVolume] [int] NULL,
	[Service10Profit] [money] NULL,
	[AccordFlag] [varchar](20) NULL,
	[AccordMaxBudget] [money] NULL,
	[AccordTargetBudget] [money] NULL,
	[NewMaxBudget] money NULL,
	[NewTargetBudget] money null,
	[DiscountPPPenalty] [money] NULL,
	[DiscountSVPenalty] [money] NULL,
	[SIMORevenue] [money] NULL,
	[DiscountPPCosts] [money] NULL,
	[DiscountSVCosts] [money] NULL
) 

INSERT INTO #tblinSpireSalesDataCurrentRRO 
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
FROM tblinspiresalesdatacurrentaccord
WHERE Department = 'Customer Retention'

UPDATE #tblinSpireSalesDataCurrentRRO
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
FROM tbl_Transaction_Current
WHERE Txn_ProductType LIKE '%Discount%'

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


UPDATE #tblinSpireSalesDataCurrentRRO
SET DiscountPPCosts = B.DiscCost
FROM #tblinSpireSalesDataCurrentRRO A JOIN #DiscountsSummary B
ON A.CTN = B.CTN
AND B.SOCType = 'P'

UPDATE #tblinSpireSalesDataCurrentRRO
SET DiscountSVCosts = B.DiscCost
FROM #tblinSpireSalesDataCurrentRRO A JOIN #DiscountsSummary B
ON A.CTN = B.CTN
AND (B.SOCType <> 'P' OR B.SOCType IS NULL)

UPDATE #tblinSpireSalesDataCurrentRRO
SET DiscountPPCosts = ISNULL(DiscountPPCosts,0),
DiscountSVCosts = ISNULL(DiscountSVCosts,0)


UPDATE #tblinSpireSalesDataCurrentRRO
SET DiscountCosts = (ISNULL(DiscountPPCosts,0) + ISNULL(DiscountSVCosts,0))


UPDATE #tblinSpireSalesDataCurrentRRO
SET SIMORevenue = GPNotionalProfit + Service1Profit + Service2Profit + Service3Profit + Service4Profit + Service5Profit + Service6Profit + Service7Profit + Service8Profit + Service9Profit
WHERE ContractSIMONly > 0

UPDATE #tblinSpireSalesDataCurrentRRO
SET SIMORevenue = ISNULL(SIMORevenue,0)

UPDATE #tblinSpireSalesDataCurrentRRO
SET DiscountPPPenalty = DiscountPPCosts * 0.5,
DiscountSVPenalty = DiscountSVCosts * 0.5

UPDATE #tblinSpireSalesDataCurrentRRO
SET DiscountPPPenalty = ISNULL(DiscountPPPenalty,0),
DiscountSVPenalty = ISNULL(DiscountSVPenalty,0)


SELECT TOP 50 * FROM #tblinSpireSalesDataCurrentRRO
WHERE Team = 'Colin Finney'
AND CTN IS NOT NULL