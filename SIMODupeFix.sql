DROP TABLE #RecentCont

CREATE TABLE #RecentCont (
CTN VARCHAR(100),
BAN VARCHAR(100),
OrderDate DATETIME,
ContractGrossVolume INT,
SIMOnlyVolume INT,
PricePlanSOC VARCHAR(100))

INSERT INTO #RecentCont
SELECT CTN, BAN, OrderDate, ContractGrossVolume, SIMOnlyVolume, PricePlanSOC
FROM dbo.tblinSpireSalesDataHistoryACCORD
WHERE 
OrderDate > GetDate()-18 AND
(
ContractGrossVolume > 0
OR SIMOnlyVolume > 0 )


SELECT Max(OrderDate) FROM tblInSpireSalesDataCurrent

DELETE FROM #RecentCont WHERE OrderDate = '07-15-2011'

UPDATE tblInSpireSalesDataCurrent
SET SIMONlyVolume = 0,
ContractSIMOnly = 0,
PricePlanDescription = 'Reported ' + CAST(Datepart(d,B.OrderDate) AS VARCHAR(10)) + '/' + CAST(Datepart(m,B.OrderDate) AS VARCHAR(10)) + ' ' + PricePlanDescription
FROM tblInSpireSalesDataCurrent A
JOIN #RecentCont B
ON A.CTN = B.CTN
AND
A.PricePlanSOC = B.PricePlanSOC
WHERE A.ContractGrossVolume = 0
AND A.SIMOnlyVolume = 1

TRUNCATE TABLE tblInSpireSalesDataCurrent
INSERT INTO tblInSpireSalesDataCurrent
SELECT * FROM tblInSpireSalesDataHistory
WHERE ORderDate = '07-15-2011'


SELECT * FROM tblInSpireSalesDataCurrent
WHERE PricePlanDescription LIKE 'Reported%'