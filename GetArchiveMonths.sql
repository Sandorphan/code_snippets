CREATE PROCEDURE spArchiveInSpireData @Period INT AS

--The @Period variabe controls the month you are archiving
--Eg if you select 4 it will archive the complete month 4 months ago from today.

DECLARE @StartDate AS DATETIME, @EndDate AS DATETIME, @Today AS DATETIME, @SMonth AS VARCHAR(2), @SYear AS VARCHAR(4) 

SET @Today = GetDate()
SET @SMonth = Month(DateAdd(m,-4,@Today))
SET @SYear = Year(Dateadd(m,-4,@Today))


SET @SMonth = 
CASE WHEN LEN(@SMonth) = 1 THEN CAST('0' + @SMonth AS VARCHAR(2))
		ELSE  CAST(@SMonth AS VARCHAR(2)) END

SET @StartDate = @SMonth + '-01-' + @SYear + ' 00:00:00'

SET @EndDate = (SELECT DATEADD(d,-1,DATEADD(mm, DATEDIFF(m,0,@StartDate)+1,0)))

SELECT @StartDate, @EndDate



--Archive the inSpire Data Summary Table 
 CREATE TABLE #tblInspireDataSummary (
	[OrderDate] [datetime] NULL ,
	[OrderWeek] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderMonth] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Agent] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Team] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[CCM] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Site] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Department] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[RFunction] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Channel] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[BusinessUnit] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Network] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Segment] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Campaign] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderType] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[TariffGroup] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[SubscriberStatus] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[ContractGrossVolume] [int] NULL ,
	[ContractNetVolume] [int] NULL ,
	[ShortTermExtensions] [int] NULL ,
	[ContractGrossPeriod] [int] NULL ,
	[ContractNetPeriod] [int] NULL ,
	[SIMOnlyVolume] [int] NULL ,
	[ContractSIMOnly] [int] NULL ,
	[MaintenanceOrders] [int] NULL ,
	[ContractPeriodSummary] [int] NULL ,
	[HandsetVolume] [int] NULL ,
	[HandsetCosts] [money] NULL ,
	[HandsetSubsidy] [money] NULL ,
	[HandsetRevenue] [money] NULL ,
	[DatacardVolume] [int] NULL ,
	[DatacardCosts] [money] NULL ,
	[DatacardSubsidy] [money] NULL ,
	[DatacardRevenue] [money] NULL ,
	[NetbookVolume] [int] NULL ,
	[NetbookCosts] [money] NULL ,
	[NetbookSubsidy] [money] NULL ,
	[NetbookRevenue] [money] NULL ,
	[HandsetExchanges] [int] NULL ,
	[HandsetExchangeCost] [money] NULL ,
	[AccessoryVolume] [int] NULL ,
	[AccessoryCost] [money] NULL ,
	[AccessoryRevenue] [money] NULL ,
	[DeliveryVolume] [int] NULL ,
	[DeliveryCost] [money] NULL ,
	[DeliveryRevenue] [money] NULL ,
	[CreditNoteVolume] [int] NULL ,
	[CreditNoteCost] [money] NULL ,
	[PricePlanChanges] [int] NULL ,
	[PricePlanSTCT] [int] NULL ,
	[PricePlanRecCommCost] [money] NULL ,
	[PricePlanFixCommCost] [money] NULL ,
	[Services] [int] NULL ,
	[ServicesRecCommCost] [money] NULL ,
	[ServicesFixCommCost] [money] NULL ,
	[Discounts] [int] NULL ,
	[DiscountPeriod] [int] NULL ,
	[DiscountCosts] [money] NULL ,
	[PricePlanLineRental] [money] NULL ,
	[GPNotionalProfit] [money] NULL ,
	[NPNotionalProfit] [money] NULL ,
	[Service1Volume] [int] NULL ,
	[Service1BundledVolume] [int] NULL ,
	[Service1Profit] [money] NULL ,
	[Service2Volume] [int] NULL ,
	[Service2BundledVolume] [int] NULL ,
	[Service2Profit] [money] NULL ,
	[Service3Volume] [int] NULL ,
	[Service3BundledVolume] [int] NULL ,
	[Service3Profit] [money] NULL ,
	[Service4Volume] [int] NULL ,
	[Service4BundledVolume] [int] NULL ,
	[Service4Profit] [money] NULL ,
	[Service5Volume] [int] NULL ,
	[Service5BundledVolume] [int] NULL ,
	[Service5Profit] [money] NULL ,
	[Service6Volume] [int] NULL ,
	[Service6BundledVolume] [int] NULL ,
	[Service6Profit] [money] NULL ,
	[Service7Volume] [int] NULL ,
	[Service7BundledVolume] [int] NULL ,
	[Service7Profit] [money] NULL ,
	[Service8Volume] [int] NULL ,
	[Service8BundledVolume] [int] NULL ,
	[Service8Profit] [money] NULL ,
	[Service9Volume] [int] NULL ,
	[Service9BundledVolume] [int] NULL ,
	[Service9Profit] [money] NULL ,
	[Service10Volume] [int] NULL ,
	[Service10BundledVolume] [int] NULL ,
	[Service10Profit] [money] NULL ,
	[RIV] [money] NULL ,
	[DefaultRIV] [money] NULL 
) ON [PRIMARY]

INSERT INTO #tblInspireDataSummary

SELECT     @EndDate, OrderMonth, OrderMonth, Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit, Network, Segment, Campaign, 
                      OrderType, TariffGroup, SubscriberStatus, SUM(ContractGrossVolume) AS Expr1, SUM(ContractNetVolume) AS Expr2, SUM(ShortTermExtensions) 
                      AS Expr3, SUM(ContractGrossPeriod) AS Expr4, SUM(ContractNetPeriod) AS Expr5, SUM(SIMOnlyVolume) AS Expr6, SUM(ContractSIMOnly) AS Expr7, 
                      SUM(MaintenanceOrders) AS Expr8, SUM(ContractPeriodSummary) AS Expr9, SUM(HandsetVolume) AS Expr10, SUM(HandsetCosts) AS Expr11, 
                      SUM(HandsetSubsidy) AS Expr12, SUM(HandsetRevenue) AS Expr13, SUM(DatacardVolume) AS Expr14, SUM(DatacardCosts) AS Expr15, 
                      SUM(DatacardSubsidy) AS Expr16, SUM(DatacardRevenue) AS Expr17, SUM(NetbookVolume) AS Expr18, SUM(NetbookCosts) AS Expr19, 
                      SUM(NetbookSubsidy) AS Expr20, SUM(NetbookRevenue) AS Expr21, SUM(HandsetExchanges) AS Expr22, SUM(HandsetExchangeCost) AS Expr23, 
                      SUM(AccessoryVolume) AS Expr24, SUM(AccessoryCost) AS Expr25, SUM(AccessoryRevenue) AS Expr26, SUM(DeliveryVolume) AS Expr27, 
                      SUM(DeliveryCost) AS Expr28, SUM(DeliveryRevenue) AS Expr29, SUM(CreditNoteVolume) AS Expr30, SUM(CreditNoteCost) AS Expr31, 
                      SUM(PricePlanChanges) AS Expr32, SUM(PricePlanSTCT) AS Expr33, SUM(PricePlanRecCommCost) AS Expr34, SUM(PricePlanFixCommCost) 
                      AS Expr35, SUM(Services) AS Expr36, SUM(ServicesRecCommCost) AS Expr37, SUM(ServicesFixCommCost) AS Expr38, SUM(Discounts) AS Expr39, 
                      SUM(DiscountPeriod) AS Expr40, SUM(DiscountCosts) AS Expr41, SUM(PricePlanLineRental) AS Expr42, SUM(GPNotionalProfit) AS Expr43, 
                      SUM(NPNotionalProfit) AS Expr44, SUM(Service1Volume) AS Expr45, SUM(Service1BundledVolume) AS Expr46, SUM(Service1Profit) AS Expr47, 
                      SUM(Service2Volume) AS Expr48, SUM(Service2BundledVolume) AS Expr49, SUM(Service2Profit) AS Expr50, SUM(Service3BundledVolume) AS Expr76,
                       SUM(Service3Volume) AS Expr75, SUM(Service3Profit) AS Expr74, SUM(Service4Volume) AS Expr73, SUM(Service4BundledVolume) AS Expr72, 
                      SUM(Service4Profit) AS Expr71, SUM(Service5Volume) AS Expr70, SUM(Service5BundledVolume) AS Expr69, SUM(Service5Profit) AS Expr68, 
                      SUM(Service6Volume) AS Expr67, SUM(Service6BundledVolume) AS Expr66, SUM(Service6Profit) AS Expr65, SUM(Service7Volume) AS Expr64, 
                      SUM(Service7BundledVolume) AS Expr63, SUM(Service7Profit) AS Expr62, SUM(Service8Volume) AS Expr61, SUM(Service8BundledVolume) AS Expr60,
                       SUM(Service8Profit) AS Expr59, SUM(Service9Volume) AS Expr58, SUM(Service9BundledVolume) AS Expr57, SUM(Service9Profit) AS Expr56, 
                      SUM(Service10Volume) AS Expr55, SUM(Service10BundledVolume) AS Expr54, SUM(Service10Profit) AS Expr53, SUM(RIV) AS Expr52, SUM(DefaultRIV) 
                      AS Expr51
FROM         tblinSpireSalesDataSummary_History
WHERE 	     OrderDate BETWEEN @StartDate AND @EndDate
GROUP BY OrderMonth, Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit, Network, Segment, Campaign, 
                      OrderType, TariffGroup, SubscriberStatus

SELECT * FROM #tblInspireDataSummary ORDER BY Agent

--Archive the inSpire Margin Data Table

--Archive the inSpire Product Tables

--Archive the inSpire Call Tables

--Archive the inSpire IEX Tables