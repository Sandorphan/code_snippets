SELECT * FROM tblPaulsWaffyData

CREATE TABLE tblQuoteData (
OrderDate DATETIME,
CTN VARCHAR(100),
AgentID VARCHAR(100),
ContractLength INT)

INSERT INTO tblQuoteData
SELECT CAST(Col002 AS DATETIME), SUBSTRING(Col008,1,5) + SUBSTRING(Col008,7,6),
Col003, CAST(Col010 AS INT)
FROM tblPaulsWaffyData
WHERE Col001 IN ('20090404','20090411')


SELECT * FROM tblQuoteData
DROP TABLE tblFixCOM

CREATE TABLE tblFixCOM (
QuoteDate DATETIME,
CTN VARCHAR(100),
BAN VARCHAR(100),
AgentID VARCHAR(100),
COMOrderNumber VARCHAR(100),
QuoteContLength INT,
COMContLength INT,
COMNetLength INT,
COMContStart DATETIME ,
COMContEnd DATETIME ,
COMOldStart DATETIME ,
COMOldEnd DATETIME ,
COMNewSOC VARCHAR(100),
COMOldSOC VARCHAR(100),
COMCredit MONEY,
COMOrderState VARCHAR(100))

--Also Create tables for extras and discounts once a confirmed order list is created.

INSERT INTO tblFixCOM
SELECT OrderDate, CTN, NULL,  AgentID, NULL, ContractLength, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL FROM tblQuoteData





CREATE TABLE tblFixOrderHeaders (
OrderNo VARCHAR(100),
SOCCode VARCHAR(100), 
CTN VARCHAR(100), 
BAN VARCHAR(100), 
ContLen INT,
OrdState VARCHAR(100),
ModDate DATETIME,
OrdUser VARCHAR(100))

INSERT INTO tblFixOrderHeaders 
SELECT fld2, fld5, fld10, fld11, fld20, OrderStatus, DateLastModified, OrderCreator FROM tblSCMTempImport_History A JOIN tblSCMOrderHeaderAllHistory B
ON fld2 = B.OrderNumber WHERE fld10 IN (SELECT CTN FROM tblFixCOM)
AND fld1 = 'TariffItem' 


CREATE TABLE tblFixOrderHeaders_SpecificDate (
OrderNo VARCHAR(100),
SOCCode VARCHAR(100), 
CTN VARCHAR(100), 
BAN VARCHAR(100), 
ContLen INT,
OrdState VARCHAR(100),
ModDate DATETIME,
OrdUser VARCHAR(100))

TRUNCATE TABLE tblFixOrderHeaders_SpecificDate

INSERT INTO tblFixOrderHeaders_SpecificDate
SELECT * FROM tblFixOrderHeaders 
WHERE ModDate IN ('04-04-2009','04-11-2009')
GROUP BY OrderNo, SOCCOde, CTN, BAN, ContLen, OrdState, ModDate, OrdUser

DELETE FROM tblFixOrderHeaders_SpecificDate
WHERE OrdState NOT IN (SELECT OrderStatus FROM tblSCMOrderStatus WHERE ValidOrder = 'True')

SELECT * FROM tblFixCOM A JOIN tblFixOrderHeaders_SpecificDate B ON A.CTN = B.CTN ORDER BY A.CTN
WHERE OrderNo IS NULL


UPDATE tblFixCOM
SET
AgentID = OrdUser,
BAN = B.BAN,
COMOrderNumber = B.OrderNo,
COMContLength = B.ContLen,
COMNetLength = NULL,
COMContStart = NULL,
COMContEnd = NULL, 
COMOldStart = NULL,
COMOldEnd = NULL,
COMNewSOC = B.SOCCode
FROM tblFixCOM A JOIN dbo.tblFixOrderHeaders_SpecificDate B ON A.CTN = B.CTN

UPDATE tblFIXCom
SET COMOldStart = B.Commitment_Start_Date,
COMOldEnd = B.Commitment_End_Date
FROM tblFIXCom A JOIN SPSVRMI01.MI_Archive.dbo.rep_000805_200903 B
ON A.CTN = B.Subscriber_CTN

UPDATE tblFIXCom
SET COMContStart = B.Commitment_Start_Date,
COMContEnd = B.Commitment_End_Date
FROM tblFIXCom A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN

UPDATE tblFixCOM
SET COMNetLength = DateDiff(m,ComOldEnd,Dateadd(d,7,COMContEnd))
WHERE ComOldEnd > QuoteDate


UPDATE tblFixCOM
SET COMNetLength = DateDiff(m,QuoteDate,Dateadd(d,7,COMContEnd))
WHERE ComOldEnd <= QuoteDate

UPDATE tblFixCOM
SET COMNetLength = 0
WHERE COMNetLength < 0

UPDATE tblFixCOM
SET COMNetLength = 0
WHERE COMNetLength IS NULL


DELETE FROM tblFIXCom WHERE COMOrderNumber IS NULL

UPDATE tblFixCOM
SET COMOldSOC = B.fld4
FROM tblFixCOM A JOIN tblSCMTempImport_History B ON A.COMOrderNumber = B.fld2
WHERE B.fld1 = 'OldTariff'

UPDATE tblFixCOM
SET COMCredit = CAST(B.fld10 AS MONEY)
FROM tblFixCOM A JOIN tblSCMTempImport_History B ON A.COMOrderNumber = B.fld2
WHERE B.fld1 = 'BillingCreditItem'

UPDATE tblFixCOM
SET COMCredit = 0 WHERE ComCredit IS NULL

UPDATE tblFixCOM
SET COMOrderState = 'Unreported' WHERE CTN IN (SELECT A.CTN FROM tblFixCOM A LEFT OUTER JOIN (SELECT * FROM tbl_Contract_Upgrades_History WHERE Order_Date  BETWEEN '04-02-2009' AND '04-15-2009') B ON A.CTN = B.CTN
WHERE B.CTN IS NULL)

SELECT * FROM tblFIXCOM

TRUNCATE TABLE tbl_Contract_Upgrades
INSERT INTO tbl_Contract_Upgrades
SELECT BAN, CTN, NULL, '2222', QuoteDate, ComContStart, ComContEnd, ComOldStart, ComOldEnd, NULL, COMContLength, COMNetLength, 0,0, 'Retention'
FROM tblFIXCom
WHERE COMOrderState = 'Unreported'
GROUP BY BAN, CTN, QuoteDate, ComContStart, ComContEnd, ComOldStart, ComOldEnd,  COMContLength, COMNetLength

INSERT INTO tbl_Contract_Upgrades_History
SELECT * FROM tbl_Contract_Upgrades


TRUNCATE TABLE tbl_PricePlan_Changes

INSERT INTO tbl_PricePlan_Changes
SELECT BAN, CTN, '2222', QuoteDate, COmOldSOC, '01-01-2009', QuoteDate, NULL, COMNewSOC, QuoteDate, NULL, NULL, NULL, 'Retention', NULL, NULL, Getdate()
FROM tblFIXCOM
WHERE COMOrderState = 'Unreported'
GROUP BY BAN, CTN,  QuoteDate, COmOldSOC, COMNewSOC

UPDATE tbl_PricePlan_Changes
SET Prev_Rate = B.Rate
FROM tbl_PricePlan_Changes A JOIN MIReferenceTables.dbo.tblSOCReference B ON A.Prev_SOC_Code = B.SOC_Code

UPDATE tbl_PricePlan_Changes
SET New_Rate = B.Rate
FROM tbl_PricePlan_Changes A JOIN MIReferenceTables.dbo.tblSOCReference B ON A.New_SOC_Code = B.SOC_Code

INSERT INTO tbl_PricePlan_Changes_History
SELECT * FROM tbl_PricePlan_Changes


CREATE TABLE tblFIXDiscounts (
OrderDate DATETIME,
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
BAN VARCHAR(100),
AgentID VARCHAR(100),
SOCCode VARCHAR(100),
DiscountStart DATETIME,
DiscountEnd DATETIME, 
PercValue DECIMAL (18,2),
MoneyValue MONEY,
DiscountType VARCHAR(100),
LineRental MONEY,
DiscountLevel VARCHAR(100),
DiscountStatus VARCHAR(100))

TRUNCATE TABLE tblFIXDiscounts
INSERT INTO tblFIXDiscounts
SELECT QuoteDate, COMOrderNumber, CTN, BAN, '2222', Fld4, fld5, fld6, CAST(fld9 AS DECIMAL(18,2))/100, 0, fld7, NULL, 'CTN', 'New'
FROM tblFIXCOM JOIN tblSCMTempImport_History ON COMOrderNumber = fld2
WHERE fld7 = 'percentage'
GROUP BY QuoteDate, COMOrderNumber, CTN, BAN, Fld4, fld5, fld6, fld9, fld7

INSERT INTO tblFIXDiscounts
SELECT QuoteDate, COMOrderNumber, CTN, BAN, '2222', Fld4, fld5, fld6, 0, CAST(fld9 AS MONEY), fld7, NULL, 'CTN', 'New'
FROM tblFIXCOM JOIN tblSCMTempImport_History ON COMOrderNumber = fld2
WHERE fld7 = 'amount'
GROUP BY QuoteDate, COMOrderNumber, CTN, BAN,  Fld4, fld5, fld6,  fld9 , fld7

SELECT * FROM tblFixDiscounts ORDER BY CTN

DELETE FROM tblFixDiscounts WHERE DiscountStart < OrderDate

UPDATE tblFixDiscounts
SET DiscountStatus = 'Reported' FROM 
tblFixDiscounts A JOIN (SELECT * FROM mireporting.dbo.discounts_daily_tracker where Memo_Agent_ID = '2222' AND memo_Date between '04-04-2009' AND '04-12-2009') B
ON A.CTN = B.CTN AND A.SOCCode = B.SOC_Code

SELECT * FROM tblFixDiscounts WHERE CTN =  '07827325482'

INSERT INTO mireporting.dbo.discounts_daily_tracker
SELECT BAN, CTN, NULL, '2222', NULL, NULL, NULL, NULL, NULL, NULL, OrderDate, SOCCode, NULL, 
NULL, LineRental, 'R', PercValue, MoneyValue, DiscountStart, DiscountEnd, NULL, CTN, NULL, NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'FIXCOM'
FROM tblFixDiscounts

UPDATE mireporting.dbo.discounts_daily_tracker
SET Discount_Period = DATEDIFF(m,Start_Date, End_Date)
WHERE Contract_Flag = 'FIXCOM'

UPDATE mireporting.dbo.discounts_daily_tracker
SET Line_Rental = B.Rate
FROM mireporting.dbo.discounts_daily_tracker A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.SOC_Code = B.SOC_Code

UPDATE mireporting.dbo.discounts_daily_tracker
SET Total_Discount_Value = (Line_Rental * Discount_Percent) * Discount_Period,
Max_Discount_Value = (Line_Rental * Discount_Percent) * Discount_Period
WHERE Contract_Flag = 'FIXCOM'

UPDATE mireporting.dbo.discounts_daily_tracker
SET Total_Discount_Value = ISNULL(Total_Discount_Value,0) + Discount_Amount,
Max_Discount_Value = ISNULL(Max_Discount_Value,0) + Discount_Amount
WHERE Contract_Flag = 'FIXCOM'

UPDATE mireporting.dbo.discounts_daily_Tracker
SET
Monthly_Discount_Value = Total_Discount_Value / Discount_Period
--Max_Monthly_Discount_Value = Max_Monthly_Discount_Value / Discount_Period
WHERE Contract_Flag = 'FIXCOM'
AND Total_Discount_Value  > 0
AND Discount_Period > 0

UPDATE mireporting.dbo.discounts_daily_Tracker
SET
--Monthly_Discount_Value = Total_Discount_Value / Discount_Period
Max_Monthly_Discount_Value = Max_Monthly_Discount_Value / Discount_Period
WHERE Contract_Flag = 'FIXCOM'
AND Max_Monthly_Discount_Value  > 0
AND Discount_Period > 0


SELECT * FROM mireporting.dbo.discounts_daily_Tracker WHERE Contract_Flag = 'FIXCOM'