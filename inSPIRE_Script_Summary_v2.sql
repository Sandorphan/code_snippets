CREATE PROCEDURE spInspireDataSummary As


TRUNCATE TABLE tblinSpireSalesDataSummary_Daily

INSERT INTO tblinSpireSalesDataSummary_Daily
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
SUM(ContractGrossVolume),
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
SUM(RIV),
SUM(DefaultRIV)
FROM tblinSpireSalesDataCurrent
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
ContractPeriodSummary



DELETE FROM tblinSpireSalesDataSummary_History
WHERE OrderDate IN (SELECT OrderDate FROM tblinSpireSalesDataSummary_Daily)

INSERT INTO tblinSpireSalesDataSummary_History
SELECT * FROM tblinSpireSalesDataSummary_Daily


--RECREATE THE MONTH TO DATE VIEW
--Using the month from the daily table, it removes the entire current month and resummarises it.
--Leaving history untouched

DECLARE @CurrMonth AS VARCHAR(100)

SET @CurrMonth = (SELECT DISTINCT OrderMonth FROM tblinSpireSalesDataSummary_Daily)

DELETE FROM tblinSpireSalesDataSummary_Monthly
WHERE OrderMonth = @CurrMonth

INSERT INTO tblinSpireSalesDataSummary_Monthly
SELECT 
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
SUM(ContractGrossVolume),
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
SUM(RIV),
SUM(DefaultRIV),0,0,0
FROM tblinSpireSalesDataSummary_History
WHERE OrderMonth = @CurrMonth
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
ContractPeriodSummary

CREATE TABLE #ReturnsSummary (
OrderMonth VARCHAR(100),
CommissionMonth VARCHAR(100),
Agent VARCHAR(100),
Department VARCHAR(100),
HandsetSales INT,
HandsetReturnCommissions INT,
HandsetReturnTotal INT)

INSERT INTO #ReturnsSummary
SELECT Booked_Month, Commission_Month,Agent_Name, Department, SUM(Total_Booked), SUM(Total_Returned_with18days), SUM(Total_Returned)
FROM MIReporting.dbo.Tbl_Returns_Reporting
GROUP BY  Booked_Month, Commission_Month,Agent_Name,  Department

UPDATE tblinSpireSalesDataSummary_Monthly
SET Returns_HSSales = B.HandsetSales,
Returns_HSRet = B.HandsetReturnCommissions,
Returns_HSRetTotal = B.HandsetReturnTotal
FROM tblinSpireSalesDataSummary_Monthly A JOIN #ReturnsSummary B
ON A.Agent = B.Agent
AND A.OrderMonth = B.CommissionMonth

SELECT * FROM tblinSpireSalesDataSummary_Monthly