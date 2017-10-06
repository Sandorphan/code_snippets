UPDATE tbl_Transaction_History
SET Dl_Agent = B.Name,
Dl_Team = B.TM,
Dl_CCM = B.CCM,
Dl_Site = B.Site,
Dl_Department = B.Department,
Dl_Function = B.Reporting_Function,
Dl_Channel = B.Channel,
Dl_Segment = B.Segment,
Dl_BusinessUnit = B.Business_Unit
FROM tbl_Transaction_History A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.Dl_Agent_ID = B.Crystal_Login
WHERE Order_Date > '03-31-2012'

UPDATE tbl_Transaction_History
SET Dl_Agent = B.Name,
Dl_Team = B.TM,
Dl_CCM = B.CCM,
Dl_Site = B.Site,
Dl_Department = B.Department,
Dl_Function = B.Reporting_Function,
Dl_Channel = B.Channel,
Dl_Segment = B.Segment,
Dl_BusinessUnit = B.Business_Unit
FROM tbl_Transaction_History A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.Dl_Agent_ID = B.Gemini_ID
WHERE Order_Date > '03-31-2012'


UPDATE tblInSpireSalesDataHistory
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireSalesDataHistory A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login
WHERE OrderDate > '03-31-2012'


UPDATE tblInSpireSalesDataHistory
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireSalesDataHistory A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID
WHERE OrderDate > '03-31-2012'


UPDATE tblInSpireSalesDataHistoryACCORD
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireSalesDataHistoryACCORD A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login
WHERE OrderDate > '03-31-2012'

UPDATE tblInSpireSalesDataHistoryACCORD
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireSalesDataHistoryACCORD A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID
WHERE OrderDate > '03-31-2012'

UPDATE tblInSpireSalesDataHistoryRRO
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireSalesDataHistoryRRO A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login
WHERE OrderDate > '03-31-2012'

UPDATE tblInSpireSalesDataHistoryRRO
SET Agent = B.Name,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
RFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblInSpireSalesDataHistoryRRO A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID
WHERE OrderDate > '03-31-2012'








--Returns Data Update into Monthly Only Summary
-- 
-- TRUNCATE TABLE tblInSpireReturnsSummary
-- 
-- INSERT INTO tblInSpireReturnsSummary
-- SELECT Booked_Month, Commission_Month,Agent_Name, Department, SUM(Total_Booked), SUM(Total_Returned_with18days), SUM(Total_Returned)
-- FROM MIReporting.dbo.Tbl_Returns_Reporting
-- GROUP BY  Booked_Month, Commission_Month,Agent_Name,  Department
-- 


--Fix new inspire
TRUNCATE TABLE tblinSpireSalesDataSummaryACCORD_Daily

INSERT INTO tblinSpireSalesDataSummaryACCORD_Daily
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
SUM(DefaultRIV),
SUM(AccordMaxBudget),
SUM(AccordTargetBudget)
FROM tblinSpireSalesDataHistoryACCORD
WHERE OrderDate > '03-31-2012'
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

DELETE FROM tblinSpireSalesDataSummaryACCORD_History
WHERE OrderDate > '03-31-2012'

INSERT INTO tblinSpireSalesDataSummaryACCORD_History
SELECT * FROM tblinSpireSalesDataSummaryACCORD_Daily





--Fix new rro
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
FROM tblinSpireSalesDataHistoryRRO
WHERE OrderDate > '03-31-2012'
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
WHERE OrderDate > '03-31-2012'

INSERT INTO tblinSpireSalesDataSummaryRRO_History
SELECT * FROM tblinSpireSalesDataSummaryRRO_Daily