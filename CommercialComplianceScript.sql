spLeakageProcessing '07-01-2012'

ALTER PROC spLeakageProcessing @ActDate DATETIME AS


--Credit Notes

TRUNCATE TABLE tblDailyComplianceCreditNoteLeakageDetail 


INSERT INTO tblDailyComplianceCreditNoteLeakageDetail
SELECT Activity_Date, Operator_ID, NULL, Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit,
B.Reason_Group, BAN, Count(BAN) AS CountBAN, SUM(Amount) AS CreditValue, NULL, NULL, NULL
FROM tblCreditNotes_Current A JOIN MIReferenceTables.dbo.tbl_adjustment_reasons B
ON A.Reason_Code = B.Reason_Code
GROUP BY Activity_Date, Operator_ID,  Agent, Team, CCM, Site, Department, Rpt_Function, Channel, Business_Unit,
B.Reason_Group, BAN

UPDATE tblDailyComplianceCreditNoteLeakageDetail
SET Agent = 'Unknown',
Team = 'Unknown',
CCM = 'Unknown',
Site = 'Unknown',
Department = 'Unknown',
ReportFunction = 'Unknown',
Channel = 'Unknown',
BusinessUnit = 'Unknown'
FROM tblDailyComplianceCreditNoteLeakageDetail
WHERE Agent IS NULL

UPDATE tblDailyComplianceCreditNoteLeakageDetail
SET ExceptionFlag = 'Yes',
ExceptionValue = CreditValue - 15
WHERE CreditValue > 15
AND CreditType = 'Goodwill'


UPDATE tblDailyComplianceCreditNoteLeakageDetail
SET ExceptionFlag = 'Yes',
ExceptionValue = CreditValue - 25
WHERE CreditValue > 25
AND CreditType = 'Charge Adjustment'

UPDATE tblDailyComplianceCreditNoteLeakageDetail
SET ExceptionFlag = 'Yes',
ExceptionValue = CreditValue
WHERE CreditType NOT IN ('Goodwill','Charge Adjustment')

UPDATE tblDailyComplianceCreditNoteLeakageDetail
SET ExceptionFlag = 'No', ExceptionValue = 0
WHERE ExceptionFlag IS NULL

UPDATE tblDailyComplianceCreditNoteLeakageDetail
SET MultiBan = CASE WHEN BANCount > 1 THEN 'Yes' ELSE 'No' END

UPDATE tblDailyComplianceCreditNoteLeakageDetail
SET AgentPIN = B.Switch_ID
FROM tblDailyComplianceCreditNoteLeakageDetail A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID

--Clockbacks

TRUNCATE TABLE tblDailyComplianceClockbackLeakageDetail 


INSERT INTO tblDailyComplianceClockbackLeakageDetail
SELECT Order_Date, Agent_ID, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, CTN, BAN, 
Old_Contract_End_Date, 
New_Contract_End_Date,
NULL, NULL, NULL, NULL 
FROM tbl_Contract_Upgrades
WHERE Contract_Type = 'Retention'

UPDATE tblDailyComplianceClockbackLeakageDetail
SET MonthsReduced = DATEDIFF(m,OriginalContractEndDate, AmendedContractEndDate)

DELETE FROM tblDailyComplianceClockbackLeakageDetail WHERE MonthsReduced >= 0 OR MonthsReduced IS NULL
DELETE FROM tblDailyComplianceClockbackLeakageDetail WHERE AgentID IN ('666800011','666800009')

UPDATE tblDailyComplianceClockbackLeakageDetail
SET Agent = B.Name,
AgentPIN = B.Switch_ID,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
ReportFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblDailyComplianceClockbackLeakageDetail A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID

UPDATE tblDailyComplianceClockbackLeakageDetail
SET Agent = 'Unknown',
Team = 'Unknown',
CCM = 'Unknown',
Site = 'Unknown',
Department = 'Unknown',
ReportFunction = 'Unknown',
Channel = 'Unknown',
BusinessUnit = 'Unknown'
FROM tblDailyComplianceClockbackLeakageDetail
WHERE Agent IS NULL


UPDATE tblDailyComplianceClockbackLeakageDetail
SET SOCCode = B.SOC_Code
FROM tblDailyComplianceClockbackLeakageDetail A JOIN MIReporting.dbo.rep_000839_PricePlans B
ON A.CTN = B.Subscriber_CTN

UPDATE tblDailyComplianceClockbackLeakageDetail
SET LineRental = B.Rate
FROM tblDailyComplianceClockbackLeakageDetail A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.SOCCode = B.SOC_COde

UPDATE tblDailyComplianceClockbackLeakageDetail
SET LeakageValue = (MonthsReduced * -1 ) * LineRental


--Discounts
TRUNCATE TABLE tblDailyComplianceRecurringDiscountLeakage 


INSERT INTO tblDailyComplianceRecurringDiscountLeakage
SELECT Memo_Date, Memo_Agent_ID, NULL, Agent, Team, CCM, Site, Department, Reporting_Group, NULL, NULL,
CTN, memo_BAN, SOC_Code, Line_Rental, Discount_Percent, Discount_Amount, SOC_Type, Start_Date, End_Date, Discount_Period,
NULL, Max_Discount_Value, 'Recurring'
FROM MIReporting.dbo.discounts_daily_tracker
WHERE Memo_Date = @ActDate
AND Revenue_Code IN ('R','O')

INSERT INTO tblDailyComplianceRecurringDiscountLeakage
SELECT Memo_Date, Memo_Agent_ID, NULL, Agent, Team, CCM, Site, Department, Reporting_Group, NULL, NULL,
CTN, memo_BAN, SOC_Code, Line_Rental, Discount_Percent, Discount_Amount, SOC_Type, Start_Date, End_Date, Discount_Period,
NULL, Max_Discount_Value, 'Usage'
FROM MIReporting.dbo.discounts_daily_tracker
WHERE Memo_Date = @ActDate
AND Revenue_Code IN ('U')

UPDATE tblDailyComplianceRecurringDiscountLeakage
SET DiscountTenure = 24 WHERE DiscountEndDate IS NULL

UPDATE tblDailyComplianceRecurringDiscountLeakage
SET AgentID = B.ordercloser
FROM tblDailyComplianceRecurringDiscountLeakage A JOIN tblscmorderheaderallcurrent B
ON A.CTN = B.CTN
AND A.AgentID IN ('666800011','666800009')

UPDATE tblDailyComplianceRecurringDiscountLeakage
SET Agent = B.Name,
AgentPIN = B.Switch_ID,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
ReportFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblDailyComplianceRecurringDiscountLeakage A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login

UPDATE tblDailyComplianceRecurringDiscountLeakage
SET Agent = 'Unknown',
Team = 'Unknown',
CCM = 'Unknown',
Site = 'Unknown',
Department = 'Unknown',
ReportFunction = 'Unknown',
Channel = 'Unknown',
BusinessUnit = 'Unknown'
FROM tblDailyComplianceRecurringDiscountLeakage
WHERE Agent IS NULL

UPDATE tblDailyComplianceRecurringDiscountLeakage
SET NoEndDateFlag = CASE WHEN DiscountEndDate IS NULL THEN 'Y' ELSE 'N' END

UPDATE tblDailyComplianceRecurringDiscountLeakage
SET SOCType = 'Price Plan' WHERE SOCType IS NULL

-- Hardware

TRUNCATE TABLE tblDailyComplianceHardwareLeakage 


INSERT INTO tblDailyComplianceHardwareLeakage
SELECT BookedDate, OrderUser, NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
CTN, BAN, ProductID, ProductDescription, ItemType, NULL, NULL, NULL, ProductCost, Round(ProductPrice,2), NULL, ExchangeFlag, NULL
FROM tblSCMHardwareFeedHistory WHERE BookedDate = @ActDate
AND ItemType NOT LIKE 'SimItem'

UPDATE tblDailyComplianceHardwareLeakage
SET Agent = B.Name,
AgentPIN = B.Switch_ID,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
ReportFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblDailyComplianceHardwareLeakage A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login

UPDATE tblDailyComplianceHardwareLeakage
SET Agent = 'Unknown',
Team = 'Unknown',
CCM = 'Unknown',
Site = 'Unknown',
Department = 'Unknown',
ReportFunction = 'Unknown',
Channel = 'Unknown',
BusinessUnit = 'Unknown'
FROM tblDailyComplianceHardwareLeakage
WHERE Agent IS NULL

UPDATE tblDailyComplianceHardwareLeakage
SET ContractStartDate = B.Commitment_Start_Date,
ConnectionDate = B.Connection_Date
FROM tblDailyComplianceHardwareLeakage A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN

UPDATE tblDailyComplianceHardwareLeakage
SET OrderType = 
CASE WHEN ConnectionDate >= GetDate()-15 THEN 'Acquisition'
WHEN ContractStartDate >= GetDate()-15 THEN 'Retention'
ELSE 'Maintenance' END 

UPDATE tblDailyComplianceHardwareLeakage
SET ExceptionFlag = 
CASE WHEN (OrderType = 'Maintenance' AND ExchangeFlag = 'New' AND Contribution < Cost) THEN 'Y' ELSE 'N' END

--Disconnections


TRUNCATE TABLE tblDailyComplianceDisconnectionsLeakage 


INSERT INTO tblDailyComplianceDisconnectionsLeakage
SELECT DisconnectionDate, AgentID, NULL, Agent, Team, CCM, Site, Department, RptFunction, Channel, BusinessUnit,
CTN, BAN, SameDay, OneDay, ShortFuse, Notice, ContractFlag, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM dbo.tblDisconnectionLeakageDetail_Current

UPDATE tblDailyComplianceDisconnectionsLeakage
SET AgentPIN = B.Switch_ID
FROM tblDailyComplianceDisconnectionsLeakage A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Gemini_ID

UPDATE tblDailyComplianceDisconnectionsLeakage
SET AgentPIN = B.Switch_ID
FROM tblDailyComplianceDisconnectionsLeakage A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login

UPDATE tblDailyComplianceDisconnectionsLeakage
SET ContractEndDate = B.Commitment_End_Date 
FROM tblDailyComplianceDisconnectionsLeakage A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_Ctn

UPDATE tblDailyComplianceDisconnectionsLeakage
SET EligibilityFlag =
CASE WHEN ContractFlag = 'Out of Contract Disconnection' THEN 'Eligible'
WHEN ContractFlag = 'Acquisition Disconnection' THEN '14 Day Return' 
WHEN Datediff(d,ContractEndDate, ActivityDate) < -50 THEN 'Ineligible'
ELSE 'Eligible' END

UPDATE tblDailyComplianceDisconnectionsLeakage
SET MonthsRemaining = CASE WHEN Datediff(m,ActivityDate,ContractEndDate) < 0 THEN 0 ELSE Datediff(m,ActivityDate,ContractEndDate) END

UPDATE tblDailyComplianceDisconnectionsLeakage
SET MonthsRemaining = 0
WHERE ContractEndDate IS NULL

UPDATE tblDailyComplianceDisconnectionsLeakage
SET SOC = B.SOC_Code
FROM tblDailyComplianceDisconnectionsLeakage A JOIN MIReporting.dbo.rep_000839_PricePlans B
ON A.CTN = B.Subscriber_CTN

UPDATE tblDailyComplianceDisconnectionsLeakage
SET LineRental = B.Rate
FROM tblDailyComplianceDisconnectionsLeakage A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.SOC = B.SOC_COde

UPDATE tblDailyComplianceDisconnectionsLeakage
SET ExceptionFlag = CASE WHEN MonthsRemaining > 0 THEN 'Y' 
WHEN MonthsRemaining = 0 AND SameDay = 1 THEN 'Y'
WHEN MonthsRemaining = 0 AND NextDay = 1 THEN 'Y'
ELSE 'N' END
WHERE EligibilityFlag NOT LIKE '14 Day Return'

UPDATE tblDailyComplianceDisconnectionsLeakage
SET ExceptionFlag = 'N' WHERE EligibilityFlag = '14 Day Return'

UPDATE tblDailyComplianceDisconnectionsLeakage
SET ExceptionValue = CASE WHEN MonthsRemaining = 0 THEN 1 * LineRental ELSE MonthsRemaining * LineRental END
WHERE ExceptionFlag = 'Y'

UPDATE tblDailyComplianceDisconnectionsLeakage
SET ExceptionValue = 0
WHERE ExceptionFlag = 'N'


--PAC

--Disconnections


TRUNCATE TABLE tblDailyCompliancePACLeakage 


INSERT INTO tblDailyCompliancePACLeakage
SELECT Memo_Date, Memo_Agent_ID, NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
CTN, BAN, NULL, NULL, NULL, NULL, NULL, NULL,NULL
FROM MIReporting.dbo.Topical_SP01_Memo where memo_date = '07-01-2012'


UPDATE tblDailyCompliancePACLeakage
SET ContractEndDate = B.Commitment_End_Date 
FROM tblDailyCompliancePACLeakage A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_Ctn

UPDATE tblDailyCompliancePACLeakage
SET MonthsRemaining = CASE WHEN Datediff(m,ActivityDate,ContractEndDate) < 0 THEN 0 ELSE Datediff(m,ActivityDate,ContractEndDate) END,
DaysRemaining = CASE WHEN Datediff(d,ActivityDate,ContractEndDate) < 0 THEN 0 ELSE Datediff(d,ActivityDate,ContractEndDate) END


UPDATE tblDailyCompliancePACLeakage
SET MonthsRemaining = 0
WHERE ContractEndDate IS NULL

UPDATE tblDailyCompliancePACLeakage
SET SOC = B.SOC_Code
FROM tblDailyCompliancePACLeakage A JOIN MIReporting.dbo.rep_000839_PricePlans B
ON A.CTN = B.Subscriber_CTN

UPDATE tblDailyCompliancePACLeakage
SET LineRental = B.Rate
FROM tblDailyCompliancePACLeakage A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.SOC = B.SOC_COde

UPDATE tblDailyCompliancePACLeakage
SET Agent = B.Name,
AgentPIN = B.Switch_ID,
Team = B.TM,
CCM = B.CCM,
Site = B.Site,
Department = B.Department,
ReportFunction = B.Reporting_Function,
Channel = B.Channel,
BusinessUnit = B.Business_Unit
FROM tblDailyCompliancePACLeakage A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.AgentID = B.Crystal_Login

UPDATE tblDailyCompliancePACLeakage
SET Agent = 'Unknown',
Team = 'Unknown',
CCM = 'Unknown',
Site = 'Unknown',
Department = 'Unknown',
ReportFunction = 'Unknown',
Channel = 'Unknown',
BusinessUnit = 'Unknown'
FROM tblDailyCompliancePACLeakage
WHERE Agent IS NULL

UPDATE tblDailyCompliancePACLeakage
SET ExceptionFlag = 
CASE WHEN DaysRemaining > 50 THEN 'Y'
WHEN DaysRemaining > 0 AND Channel NOT LIKE 'Call Centre - Sales' THEN 'Y'
ELSE 'N' END 

UPDATE tblDailyCompliancePACLeakage
SET ExceptionValue = LineRental * MonthsRemaining
WHERE ExceptionFlag = 'Y'

UPDATE tblDailyCompliancePACLeakage
SET ExceptionValue = 0 WHERE ExceptionFlag = 'N'




CREATE TABLE #ComplianceSummary (
ActivityDate DATETIME,
AgentID VARCHAR(100),
AgentPIN VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
ReportFunction VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
Calls INT,
GoodwillCredits INT,
GoodwillCreditValue MONEY,
GoodwillMultiBANCredits INT,
GoodwillExceptionCredits INT,
GoodwillExceptionCreditValue MONEY,
ChargeCredits INT,
ChargeCreditValue MONEY,
ChargeMultiBANCredits INT,
ChargeExceptionCredits INT,
ChargeExceptionCreditValue MONEY,
OtherCredits INT,
OtherCreditsValue MONEY,
OtherMultiBANCredits INT,
ClockbackExceptions INT,
ClockbackMonths INT,
ClockbackExceptionValue MONEY,
RecurringDiscounts INT,
RecurringDiscountsTotalMonths INT,
RecurringDiscountLifetimeValue MONEY,
RecurringDiscountsNoEndDateExceptions INT,
UsageDiscounts INT,
HandsetOrdersRetention INT,
HandsetOrdersRetentionCost MONEY,
HandsetOrdersAcquisition INT,
HandsetOrdersAcquisitionCost MONEY,
HandsetOrdersExchange INT,
HandsetOrdersExchangeCost MONEY,
HandsetOrdersMaintenanceExceptions INT,
HandsetOrdersMaintenanceExceptionsCost MONEY,
AccessoryOrders INT,
AccessoryOrdersCost MONEY,
AccessoryOrdersExceptions INT,
AccessoryOrdersExceptionsCost MONEY,
DeliveryOrders INT,
DeliveryOrdersCost MONEY,
DeliveryOrderExceptions INT,
DeliveryOrderExceptionsCost MONEY,
DisconnectionVolume INT,
DisconnectSameDay INT,
DisconnectNextDay INT,
DisconnectShortFuse INT,
DisconnectNotice INT,
DisconnectionExceptions INT,
DisconnectionExceptionsCost MONEY,
PACVolume INT,
PACExceptions INT,
PACExceptionCost MONEY )

INSERT INTO #ComplianceSummary
SELECT ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tblDailyComplianceCreditNoteLeakageDetail
GROUP BY ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit

INSERT INTO #ComplianceSummary
SELECT ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tblDailyComplianceClockbackLeakageDetail
WHERE AgentID NOT IN (SELECT AgentID FROM #ComplianceSummary)
GROUP BY ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit


INSERT INTO #ComplianceSummary
SELECT ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tblDailyComplianceRecurringDiscountLeakage
WHERE AgentID NOT IN (SELECT AgentID FROM #ComplianceSummary)
GROUP BY ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit


INSERT INTO #ComplianceSummary
SELECT ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tblDailyComplianceHardwareLeakage
WHERE AgentID NOT IN (SELECT AgentID FROM #ComplianceSummary)
GROUP BY ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit

INSERT INTO #ComplianceSummary
SELECT ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tblDailyComplianceDisconnectionsLeakage
WHERE AgentID NOT IN (SELECT AgentID FROM #ComplianceSummary)
GROUP BY ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit

INSERT INTO #ComplianceSummary
SELECT ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit,
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tblDailyCompliancePACLeakage
WHERE AgentID NOT IN (SELECT AgentID FROM #ComplianceSummary)
GROUP BY ActivityDate,AgentID,AgentPIN,Agent,Team,CCM,Site,Department,ReportFunction,Channel, BusinessUnit


-- Update the credit sections

UPDATE #ComplianceSummary
SET GoodwillCredits =  B.SumCredits,
GoodwillCreditValue = B.CreditValue,
GoodwillMultiBANCredits = B.MultiBAN,
GoodwillExceptionCredits = B.Exceptions,
GoodwillExceptionCreditValue = B.ExceptionValue
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(BAN) AS SumCredits, SUM(CreditValue) AS CreditValue, 
SUM(CASE WHEN MultiBAN = 'Yes' THEN 1 ELSE 0 END) AS MultiBAN, SUM(CASE WHEN ExceptionFlag = 'Yes' THEN 1 ELSE 0 END) AS Exceptions,
SUM(ExceptionValue) As ExceptionValue FROM tblDailyComplianceCreditNoteLeakageDetail WHERE CreditType = 'Goodwill' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET ChargeCredits =  B.SumCredits,
ChargeCreditValue = B.CreditValue,
ChargeMultiBANCredits = B.MultiBAN,
ChargeExceptionCredits = B.Exceptions,
ChargeExceptionCreditValue = B.ExceptionValue
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(BAN) AS SumCredits, SUM(CreditValue) AS CreditValue, 
SUM(CASE WHEN MultiBAN = 'Yes' THEN 1 ELSE 0 END) AS MultiBAN, SUM(CASE WHEN ExceptionFlag = 'Yes' THEN 1 ELSE 0 END) AS Exceptions,
SUM(ExceptionValue) As ExceptionValue FROM tblDailyComplianceCreditNoteLeakageDetail WHERE CreditType = 'Charge Adjustment' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET OtherCredits =  B.SumCredits,
OtherCreditsValue = B.CreditValue,
OtherMultiBANCredits = B.MultiBAN
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(BAN) AS SumCredits, SUM(CreditValue) AS CreditValue, 
SUM(CASE WHEN MultiBAN = 'Yes' THEN 1 ELSE 0 END) AS MultiBAN
FROM tblDailyComplianceCreditNoteLeakageDetail WHERE CreditType NOT IN ('Charge Adjustment','Goodwill') GROUP BY AgentID ) B
ON A.AgentID = B.AgentID


UPDATE #ComplianceSummary
SET ClockbackExceptions =  B.Clockbacks,
ClockbackMonths = B.ClockbackMonths,
ClockbackExceptionValue = B.ClockbackValue
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Clockbacks, SUM(MonthsReduced) * -1 AS ClockbackMonths,
SUM(LeakageValue) AS ClockbackValue
FROM tblDailyComplianceClockbackLeakageDetail  GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET RecurringDiscounts =  B.Discounts,
RecurringDiscountsTotalMonths = B.TtlMonths,
RecurringDiscountLifetimeValue = B.TtlValue,
RecurringDiscountsNoEndDateExceptions = B.TtlExceptions
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Discounts, SUM(DiscountTenure) AS TtlMonths,
SUM(DiscountValue) AS TtlValue, SUM(CASE WHEN NoEndDateFlag = 'Y' THEN 1 ELSE 0 END) AS TtlExceptions
FROM tblDailyComplianceRecurringDiscountLeakage WHERE DiscountType = 'Recurring'  GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET UsageDiscounts =  B.Discounts
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Discounts
FROM tblDailyComplianceRecurringDiscountLeakage WHERE DiscountType = 'Usage' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET HandsetOrdersRetention =  B.Handsets,
HandsetOrdersRetentionCost = B.HandsetCosts
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Handsets, SUM(Cost) - SUM(Contribution) AS HandsetCosts
FROM tblDailyComplianceHardwareLeakage WHERE OrderType = 'Retention' AND ProductType = 'HandsetItem' AND ExchangeFlag = 'New' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET HandsetOrdersAcquisition =  B.Handsets,
HandsetOrdersAcquisitionCost = B.HandsetCosts
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Handsets, SUM(Cost) - SUM(Contribution) AS HandsetCosts
FROM tblDailyComplianceHardwareLeakage WHERE OrderType = 'Acquisition' AND ProductType = 'HandsetItem' AND ExchangeFlag = 'New' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET HandsetOrdersExchange =  B.Handsets,
HandsetOrdersExchangeCost = B.HandsetCosts
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Handsets, SUM(Cost) - SUM(Contribution) AS HandsetCosts
FROM tblDailyComplianceHardwareLeakage WHERE ProductType = 'HandsetItem' AND ExchangeFlag = 'Exchange' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET HandsetOrdersMaintenanceExceptions =  B.Handsets,
HandsetOrdersMaintenanceExceptionsCost = B.HandsetCosts
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Handsets, SUM(Cost) - SUM(Contribution) AS HandsetCosts
FROM tblDailyComplianceHardwareLeakage WHERE OrderType = 'Maintenance' AND ProductType = 'HandsetItem' AND ExchangeFlag = 'New' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET AccessoryOrders =  B.Accs,
AccessoryOrdersCost = B.AccCosts,
AccessoryOrdersExceptions = B.AccExept,
AccessoryOrdersExceptionsCost = B.AccExCost
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Accs, SUM(Cost) - SUM(Contribution) AS AccCosts,
SUM(CASE WHEN Cost > Contribution THEN 1 ELSE 0 END) AS AccExept,
SUM(CASE WHEN Cost > Contribution THEN Cost - Contribution ELSE 0 END) AS AccExCost
FROM tblDailyComplianceHardwareLeakage WHERE  ProductType = 'AccessoryItem' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET DeliveryOrders =  B.Dels,
DeliveryOrdersCost = B.DelCosts,
DeliveryOrderExceptions = B.DelExept,
DeliveryOrderExceptionsCost = B.DelExCost
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Dels, SUM(Cost) - SUM(Contribution) AS DelCosts,
SUM(CASE WHEN Cost > Contribution THEN 1 ELSE 0 END) AS DelExept,
SUM(CASE WHEN Cost > Contribution THEN Cost - Contribution ELSE 0 END) AS DelExCost
FROM tblDailyComplianceHardwareLeakage WHERE  ProductType = 'DeliveryItem' GROUP BY AgentID ) B
ON A.AgentID = B.AgentID


UPDATE #ComplianceSummary
SET DisconnectionVolume =  B.Discon,
DisconnectSameDay = B.SameDay,
DisconnectNextDay = B.NextDay,
DisconnectShortFuse = B.SFuse,
DisconnectNotice = B.Notice,
DisconnectionExceptions = B.Exept,
DisconnectionExceptionsCost = B.ExCost
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS Discon, SUM(SameDay) AS SameDay,
SUM(NextDay) AS NextDay,SUM(ShortFuse) AS SFuse,SUM(Notice) AS Notice,
SUM(CASE WHEN ExceptionFlag = 'Y' THEN 1 ELSE 0 END) AS Exept,
SUM(ExceptionValue) AS ExCost
FROM tblDailyComplianceDisconnectionsLeakage GROUP BY AgentID ) B
ON A.AgentID = B.AgentID


UPDATE #ComplianceSummary
SET PACVolume =  B.PAC,
PACExceptions = B.PACEx,
PACExceptionCost = B.PACCost
FROM #ComplianceSummary A JOIN 
(SELECT AgentID, COUNT(CTN) AS PAC, SUM(CASE WHEN ExceptionFlag = 'Y' THEN 1 ELSE 0 END) AS PACEx,
SUM(ExceptionValue) AS PACCost
FROM tblDailyCompliancePACLeakage GROUP BY AgentID ) B
ON A.AgentID = B.AgentID

UPDATE #ComplianceSummary
SET
GoodwillCredits =ISNULL(GoodwillCredits,0),
GoodwillCreditValue = ISNULL(GoodwillCreditValue,0),
GoodwillMultiBANCredits = ISNULL(GoodwillMultiBANCredits,0),
GoodwillExceptionCredits = ISNULL(GoodwillExceptionCredits,0),
GoodwillExceptionCreditValue = ISNULL(GoodwillExceptionCreditValue,0),
ChargeCredits = ISNULL(ChargeCredits,0),
ChargeCreditValue = ISNULL(ChargeCreditValue,0),
ChargeMultiBANCredits = ISNULL(ChargeMultiBANCredits,0),
ChargeExceptionCredits = ISNULL(ChargeExceptionCredits,0),
ChargeExceptionCreditValue = ISNULL(ChargeExceptionCreditValue,0),
OtherCredits = ISNULL(OtherCredits,0),
OtherCreditsValue = ISNULL(OtherCreditsValue,0),
OtherMultiBANCredits = ISNULL(OtherMultiBANCredits,0),
ClockbackExceptions = ISNULL(ClockbackExceptions,0),
ClockbackMonths = ISNULL(ClockbackMonths,0),
ClockbackExceptionValue = ISNULL(ClockbackExceptionValue,0),
RecurringDiscounts = ISNULL(RecurringDiscounts,0),
RecurringDiscountsTotalMonths = ISNULL(RecurringDiscountsTotalMonths,0),
RecurringDiscountLifetimeValue = ISNULL(RecurringDiscountLifetimeValue,0),
RecurringDiscountsNoEndDateExceptions = ISNULL(RecurringDiscountsNoEndDateExceptions,0),
UsageDiscounts = ISNULL(UsageDiscounts,0),
HandsetOrdersRetention = ISNULL(HandsetOrdersRetention,0),
HandsetOrdersRetentionCost = ISNULL(HandsetOrdersRetentionCost,0),
HandsetOrdersAcquisition = ISNULL(HandsetOrdersAcquisition,0),
HandsetOrdersAcquisitionCost = ISNULL(HandsetOrdersAcquisitionCost,0),
HandsetOrdersExchange = ISNULL(HandsetOrdersExchange,0),
HandsetOrdersExchangeCost = ISNULL(HandsetOrdersExchangeCost,0),
HandsetOrdersMaintenanceExceptions = ISNULL(HandsetOrdersMaintenanceExceptions,0),
HandsetOrdersMaintenanceExceptionsCost = ISNULL(HandsetOrdersMaintenanceExceptionsCost,0),
AccessoryOrders = ISNULL(AccessoryOrders,0),
AccessoryOrdersCost = ISNULL(AccessoryOrdersCost,0),
AccessoryOrdersExceptions = ISNULL(AccessoryOrdersExceptions,0),
AccessoryOrdersExceptionsCost = ISNULL(AccessoryOrdersExceptionsCost,0),
DeliveryOrders = ISNULL(DeliveryOrders,0),
DeliveryOrdersCost = ISNULL(DeliveryOrdersCost,0),
DeliveryOrderExceptions = ISNULL(DeliveryOrderExceptions,0),
DeliveryOrderExceptionsCost = ISNULL(DeliveryOrderExceptionsCost,0),
DisconnectionVolume = ISNULL(DisconnectionVolume,0),
DisconnectSameDay = ISNULL(DisconnectSameDay,0),
DisconnectNextDay = ISNULL(DisconnectNextDay,0),
DisconnectShortFuse = ISNULL(DisconnectShortFuse,0),
DisconnectNotice = ISNULL(DisconnectNotice,0),
DisconnectionExceptions = ISNULL(DisconnectionExceptions,0),
DisconnectionExceptionsCost = ISNULL(DisconnectionExceptionsCost,0),
PACVolume = ISNULL(PACVolume,0),
PACExceptions = ISNULL(PACExceptions,0),
PACExceptionCost = ISNULL(PACExceptionCost,0)


--Final aggregate table to remove duplicates caused by multi system logins and IDs
TRUNCATE TABLE tblDailyComplianceSummary 


INSERT INTO tblDailyComplianceSummary
SELECT 
ActivityDate,
AgentPIN,
Agent,
Team,
CCM,
Site,
Department,
ReportFunction,
Channel,
BusinessUnit,
Calls,
SUM(GoodwillCredits),
SUM(GoodwillCreditValue),
SUM(GoodwillMultiBANCredits),
SUM(GoodwillExceptionCredits),
SUM(GoodwillExceptionCreditValue),
SUM(ChargeCredits),
SUM(ChargeCreditValue),
SUM(ChargeMultiBANCredits),
SUM(ChargeExceptionCredits),
SUM(ChargeExceptionCreditValue),
SUM(OtherCredits),
SUM(OtherCreditsValue),
SUM(OtherMultiBANCredits),
SUM(ClockbackExceptions),
SUM(ClockbackMonths),
SUM(ClockbackExceptionValue),
SUM(RecurringDiscounts),
SUM(RecurringDiscountsTotalMonths),
SUM(RecurringDiscountLifetimeValue),
SUM(RecurringDiscountsNoEndDateExceptions),
SUM(UsageDiscounts),
SUM(HandsetOrdersRetention),
SUM(HandsetOrdersRetentionCost),
SUM(HandsetOrdersAcquisition),
SUM(HandsetOrdersAcquisitionCost),
SUM(HandsetOrdersExchange),
SUM(HandsetOrdersExchangeCost),
SUM(HandsetOrdersMaintenanceExceptions),
SUM(HandsetOrdersMaintenanceExceptionsCost),
SUM(AccessoryOrders),
SUM(AccessoryOrdersCost),
SUM(AccessoryOrdersExceptions),
SUM(AccessoryOrdersExceptionsCost),
SUM(DeliveryOrders),
SUM(DeliveryOrdersCost),
SUM(DeliveryOrderExceptions),
SUM(DeliveryOrderExceptionsCost),
SUM(DisconnectionVolume),
SUM(DisconnectSameDay),
SUM(DisconnectNextDay),
SUM(DisconnectShortFuse),
SUM(DisconnectNotice),
SUM(DisconnectionExceptions),
SUM(DisconnectionExceptionsCost),
SUM(PACVolume),
SUM(PACExceptions),
SUM(PACExceptionCost)
FROM #ComplianceSummary
GROUP BY ActivityDate,
AgentPIN,
Agent,
Team,
CCM,
Site,
Department,
ReportFunction,
Channel,
BusinessUnit,
Calls

UPDATE tblDailyComplianceSummary
SET Calls = B.ACDCalls
FROM tblDailyComplianceSummary A JOIN dbo.tblinSpireCallsFeedHistory B
ON A.ActivityDate = B.CallDate AND A.AgentPIN = B.AgentLogin


UPDATE tblDailyComplianceSummary
SET Calls = 0 WHERE Calls IS NULL

SELECT * FROM tblDailyComplianceCreditNoteLeakageDetail
SELECT * FROm tblDailyComplianceClockbackLeakageDetail
SELECT * FROM tblDailyComplianceRecurringDiscountLeakage
SELECT * FROM tblDailyComplianceHardwareLeakage
SELECT * FROM tblDailyComplianceDisconnectionsLeakage
SELECT * FROM tblDailyCompliancePACLeakage
SELECT * FROM tblDailyComplianceSummary