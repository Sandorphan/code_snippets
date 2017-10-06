SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


ALTER   PROCEDURE spSCMAccordData AS

INSERT INTO tblNotionalProfit_AccordValues
SELECT fld2, fld27, NULL,  fld16, 
CAST(SUBSTRING(Fld4,4,2) + '-' +  SUBSTRING(Fld4,1,2) + '-' + SUBSTRING(Fld4,7,4) + ' 00:00:00.000' AS DATETIME),
CAST(SUBSTRING(Fld24,4,2) + '-' +  SUBSTRING(Fld24,1,2) + '-' + SUBSTRING(Fld24,7,4) AS DATETIME) ,
NULL, NULL, NULL, CAST(fld31 AS MONEY), CAST(fld28 AS MONEY)
FROM tblscmtempimport where fld1 = 'WarehouseDataReportOrder'
AND fld27 IS NOT NULL




--SELECT * FROM #TempNotionalProfit

UPDATE tblNotionalProfit_AccordValues
SET CTN = B.fld10
FROM tblNotionalProfit_AccordValues A JOIN tblscmtempimport_TempHistory B
ON A.OrderNumber = B.fld2
AND B.fld1 = 'TariffItem'
WHERE B.ImportDate > '05-28-2010'

UPDATE tblNotionalProfit_AccordValues
SET Accordmaxbudget = CAST(B.fld6 AS MONEY)
FROM tblNotionalProfit_AccordValues A JOIN tblscmtempimport_TempHistory B
ON A.OrderNumber = B.fld2
AND B.fld1 = 'Selection'
WHERE B.ImportDate > '05-28-2010'


SELECT * FROM  tblscmtempimport_TempHistory
WHERE fld1 = 'Selection' 
AND ImportDate > '05-28-2010'

UPDATE tblNotionalProfit_AccordValues
SET AccordTargetBudget = AccordMaxBudget * 0.75

UPDATE tblNotionalProfit_AccordValues
SET AccordFVC = AccordCosts + AccordNP




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

