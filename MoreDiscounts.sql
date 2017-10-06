UPDATE tblDiscountAnalysis
SET DiscountPeriod = TenureRemaining


UPDATE tblDiscountAnalysis
SET TenureRemaining = DateDiff(m,GetDate(),DiscountEnd)


UPDATE tblDiscountAnalysis
SET TenureRemaining = 9999
WHERE DiscountEnd IS NULL


UPDATE tblDiscountAnalysis
SET ActiveCustomer = B.Subscriber_Status
FROM tblDiscountAnalysis A JOIN Rep_000805_Current B
ON A.CTN = B.Subscriber_CTN

UPDATE tblDiscountAnalysis
SET ActiveCustomer = 'BAN'
FROM tblDiscountAnalysis A JOIN Rep_000805_Current B
ON A.BAN = B.BAN
WHERE ActiveCustomer IS NULL

UPDATE tblDiscountAnalysis
SET StartMonth = 
CASE
WHEN DiscountStart < '01-01-2000' THEN '<2000'
WHEN DiscountStart < '01-01-2001' THEN '<2001'
WHEN DiscountStart < '01-01-2002' THEN '<2002'
WHEN DiscountStart < '01-01-2003' THEN '<2003'
WHEN DiscountStart < '01-01-2004' THEN '<2004'
WHEN DiscountStart < '01-01-2005' THEN '<2005'
WHEN DiscountStart < '01-01-2006' THEN '<2006'
WHEN DiscountStart < '01-01-2007' THEN '<2007'
WHEN DiscountStart < '01-01-2008' THEN '<2008'
WHEN DiscountStart < '01-01-2009' THEN '<2009'
ELSE NULL END


UPDATE tblDiscountAnalysis
SET StartMonth = B.MonthText
FROM tblDiscountAnalysis A JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON A.DiscountStart = B.NewDate
WHERE A.StartMonth IS NULL

UPDATE tblDiscountAnalysis
SET StartMonth = '>2025'
WHERE StartMonth IS NULL

SELECT * FROM tblDiscountAnalysis WHERE StartMonth IS NULL

SELECT StartMonth, DiscountPeriod, TenureRemaining, AccountType, COUNT(BAN), SUM(MonthlyValue) FROM tblDiscountAnalysis
GROUP BY StartMonth, DiscountPeriod, TenureRemaining, AccountType
ORDER BY StartMonth ASC
