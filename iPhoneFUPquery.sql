CREATE TABLE #iPhoneFups (
CTN VARCHAR(100),
BAN VARCHAR(100),
OrderDate DATETIME,
Agent VARCHAR(100),
Department VARCHAR(100),
Handset VARCHAR(100),
SIMCardIndicator VARCHAR(10),
SaleContractLength INT,
CurrentContractEndDate DATETIME,
CommitmentPeriod INT )

INSERT INTO #iPhoneFups
SELECT CTN, BAN, OrderDate, Agent, Department, HandsetDescription, NULL, ContractGrossPeriod, NULL, NULL
FROM tblinspiresalesdatahistoryaccord 
WHERE Channel = 'Call Centre - Sales'
AND HandsetDescription LIKE '%iphone%'

DELETE FROM #iPhoneFups
WHERE Handset LIKE '%3Gs%'
SELECT * FROM #iPhoneFups

UPDATE #iPhoneFups
SET CurrentContractEndDate = B.Commitment_End_Date
FROM #iPhoneFups A JOIN MIReporting.dbo.rep_000805_Current B
ON A.CTN = B.Subscriber_CTN

UPDATE #iPhoneFups
SET CommitmentPeriod = DateDiff(m,OrderDate, CurrentContractEndDate)
WHERE CurrentContractEndDate IS NOT NULL

SELECT * FROM #iPhoneFups
WHERE CommitmentPeriod > 30 AND CommitmentPeriod < 40
