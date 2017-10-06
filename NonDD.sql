CREATE TABLE #NonDDAnalysis (
CTN VARCHAR(100),
BAN VARCHAR(100),
PaymentMethod  VARCHAR(100),
AccountType  VARCHAR(100),
CustomerSegment VARCHAR(100),
AdminSOC  VARCHAR(100),
AdminSOCLR Money,
AdminSOCDiscountValue Money )

INSERT INTO #NonDDAnalysis
SELECT Subscriber_CTN, BAN, Payment_Type, Account_Type, NULL, NULL, NULL,NULL
FROM rep_000805_Current
WHERE Payment_Type NOT LIKE 'D'


UPDATE #NonDDAnalysis
SET CustomerSegment = B.Grouping
FROM #NonDDAnalysis A JOIN MIReferenceTables.dbo.tbl_gemini_accounttypes B
ON A.AccountType = B.Account_Type

UPDATE #NonDDAnalysis
SET AdminSOC = B.SOC_Code
FROM #NonDDAnalysis A JOIN dbo.rep_000839_Current B
ON A.CTN = B.Subscriber_CTN
WHERE B.SOC_Code IN ('PAYADFEE','CHQ_ADFEE','PCHQ3.00')

UPDATE #NonDDAnalysis
SET AdminSOCLR = B.Rate
FROM #NonDDAnalysis A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.AdminSOC = B.SOC_Code

DROP TABLE #NonDDDisc

CREATE TABLE #NonDDDisc (
BAN VARCHAR(100),
SOCCode VARCHAR(100),
LineR MONEY,
MoneyValue MONEY,
PercValue DECIMAL(18,2),
DiscValue MONEY)

INSERT INTO #NonDDDisc
SELECT BAN, SOC_Code, NULL, Discount_Amount, Discount_Percent, NULL
FROM rep_000835_Current
WHERE SOC_Code IN ('PAYADFEE','CHQ_ADFEE','PCHQ3.00')

UPDATE #NonDDDisc
SET LineR = B.Rate 
FROM #NonDDDisc A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.SOCCode = B.SOC_Code

UPDATE #NonDDDisc
SET PercValue = PercValue / 100

UPDATE #NonDDDisc
SET DiscValue = (LineR * PercValue)

UPDATE #NonDDDisc
SET DiscValue = MoneyValue
WHERE DiscValue IS NULL


UPDATE #NonDDAnalysis
SET AdminSOCDiscountValue = B.DiscValue
FROM #NonDDAnalysis A JOIN #NonDDDisc B
ON A.BAN = B.BAN
WHERE AdminSOC IS NOT NULL

DELETE  FROM #NonDDAnalysis WHERE CustomerSegment = 'Business'


UPDATE #NonDDAnalysis
SET AdminSOCDiscountValue = NULL WHERE AdminSOC IS NULL

SELECT * FROM #NonDDAnalysis