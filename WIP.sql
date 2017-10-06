
TRUNCATE TABLE tblNotionalProfit_AccordValues

INSERT INTO tblNotionalProfit_AccordValues
SELECT a.fld2, a.fld27, a.fld3, a.fld22, B.fld10, b.fld3,   a.fld16, 
CAST(SUBSTRING(a.Fld4,4,2) + '-' +  SUBSTRING(a.Fld4,1,2) + '-' + SUBSTRING(a.Fld4,7,4) + ' 00:00:00.000' AS DATETIME),
CAST(SUBSTRING(a.Fld24,4,2) + '-' +  SUBSTRING(a.Fld24,1,2) + '-' + SUBSTRING(a.Fld24,7,4) AS DATETIME) ,
B.fld5, NULL, NULL, NULL, CAST(a.fld31 AS MONEY), CAST(a.fld28 AS MONEY)
FROM tblscmtempimport_temphistory  A
JOIN tblscmtempimport_temphistory B ON
A.fld2 = b.fld2
where a.fld1 = 'WarehouseDataReportOrder'
AND b.fld1 = 'TariffItem'
AND a.fld27 IS NOT NULL
AND a.ImportDate > '06-13-2010'
GROUP BY a.fld2, a.fld27, a.fld3, a.fld22, B.fld10, b.fld3,   a.fld16, A.Fld4, A.Fld24,A.Fld31, A.Fld28, B.fld5



UPDATE tblNotionalProfit_AccordValues
SET Accordmaxbudget = CAST(B.fld6 AS MONEY)
FROM tblNotionalProfit_AccordValues A JOIN tblscmtempimport_temphistory B
ON A.OrderNumber = B.fld2
AND B.fld1 = 'Selection'
AND A.LineNumber = B.fld3
WHERE  fld6 NOT LIKE '%true%' 
AND fld6 NOT LIKE '%false%'



UPDATE tblNotionalProfit_AccordValues
SET AccordTargetBudget = AccordMaxBudget * 0.75

UPDATE tblNotionalProfit_AccordValues
SET AccordFVC = AccordCosts + AccordNP

UPDATE tblNotionalProfit_AccordValues
SET AccordNP = 0,
AccordFVC = 0,
AccordCosts = 0
WHERE LineNumber > 1

DELETE FROM tblNotionalProfit_AccordValues WHERE CTN IS NULL


