/* Table requirements for new reporting suite
SALES VOLUMES AND COMMERCIAL KPIs
Data to capture: */
--GROUP INFORMATION
DROP TABLE #NewReporting
CREATE TABLE #NewReporting (
OrderNumber VARCHAR(100),OrderDate DATETIME,OrderWeek DATETIME,OrderMonth VARCHAR(100),CTN VARCHAR(100),BAN VARCHAR(100),AgentID VARCHAR(100),
Agent VARCHAR(100),Team VARCHAR(100),CCM VARCHAR(100),Site VARCHAR(100),Department VARCHAR(100),RFunction VARCHAR(100),
Channel VARCHAR(100),BusinessUnit VARCHAR(100),Network VARCHAR(100),Segment VARCHAR (100),Campaign VARCHAR(100),
OrderType VARCHAR(100),TariffGroup VARCHAR(100),SubscriberStatus VARCHAR(100),
-- PRODUCT INFORMATION
HandsetDescription VARCHAR(100),PricePlanDescription VARCHAR(100),
--SALES VOLUMES
ContractGrossVolume INT,ContractNetVolume INT,ShortTermExtensions INT,ContractGrossPeriod INT,ContractNetPeriod INT,SIMOnlyVolume INT,
ContractSIMOnly INT,MaintenanceOrders INT,ContractPeriodSummary INT,
--HARDWARE COSTS
HandsetVolume INT,HandsetCosts MONEY,HandsetSubsidy MONEY,HandsetRevenue MONEY,
DatacardVolume INT,DatacardCosts MONEY,DatacardSubsidy MONEY,DatacardRevenue MONEY,
NotebookVolume INT,NotebookCosts MONEY,NotebookSubsidy MONEY,NotebookRevenue MONEY,
HandsetExchanges INT, HandsetExchangeCost MONEY,
AccessoryVolume INT, AccessoryCost MONEY, AccessoryRevenue MONEY,
DeliveryVolume INT, DeliveryCost MONEY, DeliveryRevenue MONEY,
CreditNoteVolume INT, CreditNoteCost MONEY,
--AIRTIME COSTS
PricePlanChanges INT, PricePlanSTCT INT, PricePlanCommercialCost MONEY, Services INT, ServicesCommercialCost MONEY,
Discounts INT, DiscountPeriod INT, DiscountCosts MONEY,
--NOTIONAL PROFIT 
PricePlanLineRental MONEY, GPNotionalProfit MONEY, NPNotionalProfit MONEY, 
Service1Volume INT, Service1BundledVolume INT, Service1Profit MONEY,
Service2Volume INT, Service2BundledVolume INT, Service2Profit MONEY,
Service3Volume INT, Service3BundledVolume INT, Service3Profit MONEY,
Service4Volume INT, Service4BundledVolume INT, Service4Profit MONEY,
Service5Volume INT, Service5BundledVolume INT, Service5Profit MONEY,
--OTHER DATA
RIV MONEY, DefaultRIV MONEY, HandsetReturnVolume INT, HandsetReturns INT )

INSERT INTO #NewReporting (OrderNumber, OrderDate, CTN, BAN, AgentID, Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit, 
Network, Segment, OrderType, SubscriberStatus)
SELECT Order_Ref, Order_Date,  CTN, BAN, Dl_Agent_ID, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
Dl_Network, Dl_AccountType, Dl_ActivityType, Dl_Subscription_Status
FROM tbl_Transaction_Current

--REMOVE PRE GO LIVE - TEST DATA ONLY
WHERE Dl_Department IN ('Customer Saves','Outbound Retention','Direct Sales Inbound')
GROUP BY Order_Ref, Order_Date,  CTN, BAN, Dl_Agent_ID, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
Dl_Network, Dl_AccountType, Dl_ActivityType, Dl_Subscription_Status


UPDATE #NewReporting
SET OrderWeek = CAST(B.WeekText AS DATETIME),
OrderMonth = B.MonthText
FROM #NewReporting A JOIN MIReferencetables.dbo.tbl_ref_dates B
ON A.OrderDate = B.NewDate

UPDATE #NewReporting
SET HandsetDescription = B.Txn_ProductDescription
FROM #NewReporting A JOIN tbl_Transaction_Current B
ON A.OrderNumber = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Handset'

UPDATE #NewReporting
SET PricePlanDescription = B.Txn_ProductDescription,
PricePlanLineRental = B.Txn_Recurring_Revenue,
SIMOnlyVolume = CASE WHEN Txn_ProductDescription LIKE 'SIMO%' THEN 1 ELSE 0 END,
PricePlanChanges = CASE WHEN Txn_ProductCode <> Dl_Flag_A OR Dl_Flag_A IS NULL THEN 1 ELSE 0 END,
PricePlanSTCT = CASE WHEN Txn_ProductCode = Dl_Flag_A THEN 1 ELSE 0 END
FROM #NewReporting A JOIN tbl_Transaction_Current B
ON A.OrderNumber = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Price Plan'


UPDATE #NewReporting
SET ContractGrossVolume = CASE WHEN Txn_Gross_Period > 11 THEN 1 ELSE 0 END,
ContractNetVolume = CASE WHEN Txn_Net_Period > 11 THEN 1 ELSE 0 END,
ShortTermExtensions = CASE WHEN Txn_Gross_Period > 0 AND Txn_Gross_Period < 12 THEN 1 ELSE 0 END,
ContractGrossPeriod = Txn_Gross_Period,0,
ContractNetPeriod = Txn_Net_Period,
ContractPeriodSummary = CASE WHEN Txn_Gross_Period < 12 THEN 0 WHEN Txn_Gross_Period < 18 THEN 12 WHEN Txn_Gross_Period < 24 THEN 18 ELSE 24 END
FROM #NewReporting A JOIN tbl_Transaction_Current B
ON A.OrderNumber = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType LIKE '%Contract%'

UPDATE #NewReporting
SET ContractSIMOnly = CASE WHEN SimOnlyVolume > 0 AND ContractGrossPeriod > 11 THEN 1 ELSE 0 END

UPDATE #NewReporting
SET OrderType = 'Maintenance',
MaintenanceOrders = 1
WHERE SIMOnlyVolume = 0 AND ContractGrossVolume = 0

UPDATE #NewReporting
SET ContractGrossVolume = ISNULL(ContractGrossVolume,0),
ContractNetVolume = ISNULL(ContractNetVolume,0),
ShortTermExtensions = ISNULL(ShortTermExtensions,0),
ContractGrossPeriod = ISNULL(ContractGrossPeriod,0),
ContractNetPeriod = ISNULL(ContractNetPeriod,0),
SIMOnlyVolume = ISNULL(SIMOnlyVolume,0),
MaintenanceOrders = ISNULL(MaintenanceOrders,0),
ContractPeriodSummary = ISNULL(ContractPeriodSummary,0)



--Handsets Summary
CREATE TABLE #HandsetSummary (
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
HandsetQty INT,
HandsetCost MONEY,
HandsetRev MONEY,
HandsetType VARCHAR(100))

INSERT INTO #HandsetSummary
SELECT
Order_Ref, CTN, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost), SUM(Txn_OneOff_Revenue), 'Handset'
FROM tbl_Transaction_Current B
WHERE B.Txn_ProductType = 'Handset'
AND (B.Txn_ProductDescription NOT LIKE '%Modem%'  AND B.Txn_ProductDescription NOT LIKE '%USB%' 
AND B.Txn_ProductDescription NOT LIKE '%Datacard%' AND B.Txn_ProductDescription NOT LIKE '%Mobile Connect%'
AND B.Txn_ProductDescription NOT LIKE '%Data Card%' AND B.Txn_ProductDescription NOT LIKE '%Option%'
AND B.Txn_ProductDescription NOT LIKE '%Notebook%')
GROUP BY Order_Ref, CTN

INSERT INTO #HandsetSummary
SELECT
Order_Ref, CTN, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost), SUM(Txn_OneOff_Revenue), 'Datacard'
FROM tbl_Transaction_Current B
WHERE B.Txn_ProductType = 'Handset'


UPDATE #HandsetSummary
SET HandsetType = 'Datacard' WHERE
AND (B.Txn_ProductDescription  LIKE '%Modem%'  OR B.Txn_ProductDescription  LIKE '%USB%' 
OR B.Txn_ProductDescription  LIKE '%Datacard%' AND B.Txn_ProductDescription  LIKE '%Mobile Connect%'
OR B.Txn_ProductDescription  LIKE '%Data Card%' AND B.Txn_ProductDescription  LIKE '%Option%')
GROUP BY Order_Ref, CTN

INSERT INTO #HandsetSummary
SELECT
Order_Ref, CTN, SUM(Txn_Quantity), SUM(Txn_OneOff_Cost), SUM(Txn_OneOff_Revenue), 'Notebook'
FROM tbl_Transaction_Current B
WHERE B.Txn_ProductType = 'Handset'
AND (B.Txn_ProductDescription  LIKE '%Notebook%'  )
GROUP BY Order_Ref, CTN
 

UPDATE #NewReporting
SET HandsetVolume = B.Txn_Quantity,
HandsetCosts = B.Txn_OneOff_Cost,
HandsetRevenue = B.Txn_OneOff_Revenue
FROM #NewReporting A JOIN tbl_Transaction_Current B
ON A.OrderNumber = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Handset'
AND (B.Txn_ProductDescription NOT LIKE '%Modem%'  AND B.Txn_ProductDescription NOT LIKE '%USB%' 
AND B.Txn_ProductDescription NOT LIKE '%Datacard%' AND B.Txn_ProductDescription NOT LIKE '%Mobile Connect%'
AND B.Txn_ProductDescription NOT LIKE '%Data Card%' AND B.Txn_ProductDescription NOT LIKE '%Option%'
AND B.Txn_ProductDescription NOT LIKE '%Notebook%')

SELECT SUM(Txn_Quantity) FROM tbl_Transaction_Current WHERE Txn_ProductType = 'Handset'