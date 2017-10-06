TRUNCATE TABLE tblinSpireSalesDataCurrentACCORD


INSERT INTO dbo.tblinSpireSalesDataCurrentACCORD
SELECT *, 'Non Accord', NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL FROM tblinSpireSalesDataHistory
WHERE OrderDate > '05-31-2010'

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
ON A.CTN = B.CTN AND A.OrderDate = B.ModifiedDate

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

UPDATE tblinSpireSalesDataCurrentACCORD
SET GPNotionalProfit = AccordFCV,
NPNotionalProfit = AccordFCV
WHERE AccordFlag = 'Accord'

UPDATE tblinspiresalesdatacurrentaccord
SET AccordMaxBudget = 0, AccordTargetBudget = 0, AccordCosts = 0, AccordFCV = 0, AccordNP = 0, AccordActualCosts = 0, AccordAdjNotProfit = 0
WHERE ContractGrossVolume = 0

TRUNCATE TABLE  tblinSpireSalesDataHistoryACCORD


INSERT INTO tblinSpireSalesDataHistoryACCORD
SELECT * FROM tblinSpireSalesDataCurrentACCORD

SELECT * FROM tblinSpireSalesDataCurrentACCORD
WHERE Agent = 'Kieran Williams' AND CTN = '07717368021'




SELECT 
OrderDate,
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
SUM(RIV),
SUM(DefaultRIV)
FROM tblinSpireSalesDataCurrentACCORD
WHERE Department IN ('Customer Retention','High Value Retention','Outbound Retention')
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


