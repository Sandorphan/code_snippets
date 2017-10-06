
SET DATEFORMAT mdy

DROP TABLE #StandardCTNDiscounts
DROP TABLE #StandardBANDiscounts

CREATE TABLE #StandardCTNDiscounts (
BAN VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
Memo_Date DATETIME NULL,
Memo_Agent_ID VARCHAR(50) NULL,
Charge_Type VARCHAR(5) NULL,
PercValue VARCHAR(50) NULL,
MoneyValue VARCHAR(50) NULL,
SOC_Code VARCHAR(50) NULL,
Start_Date VARCHAR(50) NULL,
End_Date VARCHAR(50) NULL,
Discount_Level VARCHAR(10) NULL,
Discount_Status VARCHAR(50) NULL)

CREATE TABLE #StandardBANDiscounts (
BAN VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
Memo_Date DATETIME NULL,
Memo_Agent_ID VARCHAR(50) NULL,
Charge_Type VARCHAR(5) NULL,
PercValue  VARCHAR(50) NULL,
MoneyValue  VARCHAR(50) NULL,
SOC_Code VARCHAR(50) NULL,
Start_Date VARCHAR(50) NULL,
End_Date VARCHAR(50) NULL,
Discount_Level VARCHAR(10) NULL,
Discount_Status VARCHAR(50) NULL,
Memo_System_Text VARCHAR(250))

INSERT INTO #StandardCTNDiscounts (BAN, CTN, Memo_Date, Memo_Agent_ID, Charge_Type, PercValue, MoneyValue, SOC_Code, 
Start_Date, End_Date, Discount_Level)
SELECT 
BAN,
--CTN
SUBSTRING(memo_System_Text,CHARINDEX('CTN= ',Memo_System_Text)+5,11),
Memo_Date,
Memo_Agent_ID,
--Charge Type
SUBSTRING(Memo_System_Text,CHARINDEX('Charge Type = ',Memo_System_Text)+14,1),
--Percentage Value
CAST(CASE
	WHEN Memo_System_Text LIKE '%Percentage%' THEN SUBSTRING(Memo_System_Text,CHARINDEX('Percentage=',Memo_System_Text)+11,(CHARINDEX(', Effective',Memo_System_Text)-CHARINDEX('Percentage=',Memo_System_Text)-11))
	ELSE '0.00' END AS VARCHAR(5)),
--Monetary Value
CAST(CASE
	WHEN Memo_System_Text LIKE '%Amount%' THEN SUBSTRING(Memo_System_Text,CHARINDEX('Amount=',Memo_System_Text)+7,(CHARINDEX(', Effective',Memo_System_Text)-CHARINDEX('Amount=',Memo_System_Text)-7))
	ELSE '0.00' END AS VARCHAR(5)),
--SOC Code
SUBSTRING(Memo_System_Text,CHARINDEX('/SOC = ',Memo_System_Text)+7,(CHARINDEX(', Charge',Memo_System_Text)-CHARINDEX('/SOC =',Memo_System_Text)-7)),
--Start Date
SUBSTRING(Memo_System_Text,CHARINDEX('Effective date = ',Memo_System_Text)+17,(CHARINDEX(', Expiration',Memo_System_Text)-CHARINDEX('Effective date = ',Memo_System_Text)-17)),
--End Date
SUBSTRING(Memo_System_Text,CHARINDEX('Expiration date = ',Memo_System_Text)+18,10),
'CTN'
FROM Rep_000802_Current
WHERE memo_Type = '0547'
AND SUBSTRING(memo_System_Text,CHARINDEX('CTN= ',Memo_System_Text)+5,11) LIKE '07%'
AND Memo_Agent_ID NOT LIKE '2222'


INSERT INTO #StandardBANDiscounts (BAN, CTN, Memo_Date, Memo_Agent_ID, Charge_Type, PercValue, MoneyValue, SOC_Code, 
Start_Date, End_Date, Discount_Level, Memo_System_Text)
SELECT 
BAN,
--CTN
NULL,
Memo_Date,
Memo_Agent_ID,
--Charge Type
SUBSTRING(Memo_System_Text,CHARINDEX('Charge Type = ',Memo_System_Text)+14,1),
--Percentage Value
CAST(CASE
	WHEN Memo_System_Text LIKE '%Percentage%' THEN SUBSTRING(Memo_System_Text,CHARINDEX('Percentage=',Memo_System_Text)+11,(CHARINDEX(', Effective',Memo_System_Text)-CHARINDEX('Percentage=',Memo_System_Text)-11))
	ELSE '0.00' END AS VARCHAR(5)),
--Monetary Value
CAST(CASE
	WHEN Memo_System_Text LIKE '%Amount%' THEN SUBSTRING(Memo_System_Text,CHARINDEX('Amount=',Memo_System_Text)+7,(CHARINDEX(', Effective',Memo_System_Text)-CHARINDEX('Amount=',Memo_System_Text)-7))
	ELSE '0.00' END AS VARCHAR(5)),
--SOC Code
SUBSTRING(Memo_System_Text,CHARINDEX('/SOC = ',Memo_System_Text)+7,(CHARINDEX(', Charge',Memo_System_Text)-CHARINDEX('/SOC =',Memo_System_Text)-7)),
--Start Date
SUBSTRING(Memo_System_Text,CHARINDEX('Effective date = ',Memo_System_Text)+17,(CHARINDEX(', Expiration',Memo_System_Text)-CHARINDEX('Effective date = ',Memo_System_Text)-17)),
--End Date
SUBSTRING(Memo_System_Text,CHARINDEX('Expiration date = ',Memo_System_Text)+18,10),
'BAN', memo_System_Text
FROM Rep_000802_Current
WHERE memo_Type = '0547'
AND SUBSTRING(memo_System_Text,CHARINDEX('CTN= ',Memo_System_Text)+5,11) NOT LIKE '07%'


UPDATE #StandardBANDiscounts
SET CTN = SUBSTRING(Memo_System_Text,35,11),
Discount_Level = 'CTN'
WHERE Memo_Agent_ID = '2222'
AND CTN IS NULL


UPDATE #StandardCTNDiscounts
SET End_Date = NULL
WHERE End_Date LIKE '.%'

UPDATE #StandardBANDiscounts
SET End_Date = NULL
WHERE End_Date LIKE '.%'


INSERT INTO #StandardCTNDiscounts SELECT BAN, CTN, Memo_Date, Memo_Agent_ID, Charge_Type, PercValue, MoneyValue, SOC_Code, 
Start_Date, End_Date, Discount_Level FROM #StandardBANDiscounts

CREATE TABLE #tblSCMDiscountsCurrent (
	[OrderNumber] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[CTN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderSelection] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[BAN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderDate] [datetime] NULL ,
	[OrderStatus] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderType] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderTime] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[OrderUser] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[ModifiedDate] [datetime] NULL ,
	[ModifiedUser] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[DealerCode] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[SOC_Code] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[SOC_LR] [money] NULL ,
	[DiscountValueType] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[DiscountType] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[DiscountValue] [decimal](18, 2) NULL ,
	[DiscountStart] [datetime] NULL ,
	[DiscountEnd] [datetime] NULL ,
	[DiscountPeriod] [int] NULL ,
	[DiscountTotalValue] [money] NULL )

INSERT INTO #tblSCMDiscountsCurrent
SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate,  B.OrderStatus,B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,Fld4, NULL, fld7, fld8, CAST(fld9 as DECIMAL(18,2)), 
CAST(Fld5 AS DATETIME), CAST(fld6 as DATETIME), NULL, NULL
FROM  MIStandardMetrics.dbo.tblSCMTempImport JOIN (SELECT * FROM MIStandardMetrics.dbo.tblSCMOrderHeaderAllCurrent) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'Discount'
AND B.OrderStatus IN (SELECT OrderStatus FROM MIStandardMetrics.dbo.tblSCMOrderStatus WHERE ValidOrder = 'True')
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate,  B.OrderStatus,B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,Fld4, fld7, fld8, CAST(fld9 as DECIMAL(18,2)), 
CAST(Fld5 AS DATETIME), CAST(fld6 as DATETIME)

UPDATE #tblSCMDiscountsCurrent
SET SOC_LR = B.Rate
FROM #tblSCMDiscountsCurrent A JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.SOC_Code = B.SOC_Code


UPDATE #tblSCMDiscountsCurrent
SET DiscountPeriod = Datediff(m,DiscountStart, DiscountEnd)

UPDATE #tblSCMDiscountsCurrent
SET DiscountTotalValue = DiscountValue * DiscountPeriod
WHERE DiscountValueType = 'amount'
AND DiscountType IN ('RC','OC')

UPDATE #tblSCMDiscountsCurrent
SET DiscountTotalValue = ((DiscountValue * ISNULL(SOC_LR,0)) * DiscountPeriod) / 100
WHERE DiscountValueType = 'percentage'
AND DiscountType IN ('RC','OC')

SELECT * FROM #tblSCMDiscountsCurrent
SELECT * FROM #StandardCTNDiscounts

UPDATE #StandardCTNDiscounts
SET PercValue = B.DiscountValue,
Start_Date = B.Discount_Start,
End_Date = B.Discount_End,
CTN = B.CTN,
Discount_Level = 'CTN'
FROM #StandardCTNDiscounts A JOIN #tblSCMDiscountsCurrent B
ON A.CTN = 


UPDATE #StandardBANDiscounts
SET Start_Date = CAST(CAST(SUBSTRING(Start_Date,7,2) AS VARCHAR(2)) + '/' + CAST(SUBSTRING(Start_Date,5,2) AS VARCHAR(2)) + '/' + CAST(SUBSTRING(Start_Date,1,4) AS VARCHAR(4)) AS VARCHAR(10))
WHERE Memo_Agent_ID = '2222'

UPDATE #StandardCTNDiscounts
SET End_Date = CAST(CAST(SUBSTRING(End_Date,7,2) AS VARCHAR(2)) + '/' + CAST(SUBSTRING(End_Date,5,2) AS VARCHAR(2)) + '/' + CAST(SUBSTRING(End_Date,1,4) AS VARCHAR(4)) AS VARCHAR(10))
WHERE Memo_Agent_ID = '2222'
AND End_Date IS NOT NULL


UPDATE #StandardCTNDiscounts
SET Start_Date = SUBSTRING(Start_Date,4,2) + '-' + SUBSTRING(Start_Date,1,2) + '-' + SUBSTRING(Start_Date,7,4) + ' 00:00:00.000'
WHERE Start_Date IS NOT NULL


UPDATE #StandardCTNDiscounts
SET End_Date = SUBSTRING(End_Date,4,2) + '-' + SUBSTRING(End_Date,1,2) + '-' + SUBSTRING(End_Date,7,4) + ' 00:00:00.000'
WHERE End_Date IS NOT NULL



UPDATE #StandardCTNDiscounts
SET Discount_Status = 'New'
WHERE CAST(Start_Date AS DATETIME) >= Memo_Date

UPDATE #StandardCTNDiscounts
SET Discount_Status = 'Cancelled'
WHERE CAST(End_Date AS DATETIME) = Memo_Date

UPDATE #StandardCTNDiscounts
SET Discount_Status = 'Change'
WHERE Discount_Status IS NULL

TRUNCATE TABLE tblDiscounts_Current

INSERT INTO tblDiscounts_Current
SELECT BAN,
CTN,
Memo_Date,
Memo_Agent_ID,
Charge_Type,
CAST(ISNULL(PercValue,0) AS DECIMAL(18,2))/100,
CAST(ISNULL(MoneyValue,0) AS MONEY),
SOC_Code,
CAST(Start_Date AS DATETIME),
CAST(End_Date AS DATETIME),
Discount_Level,
Discount_Status
FROM #StandardCTNDiscounts