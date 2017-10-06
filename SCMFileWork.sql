-- TRUNCATE TABLE tblSCMTempImport
-- 
-- SELECT * FROM  tblSCMTempImport WHERE Fld1 = 'WarehouseDataReportOrder'

TRUNCATE TABLE tblSCMOrderHeaderCurrent

INSERT INTO tblSCMOrderHeaderCurrent
SELECT Fld2, Fld3, 
--Manipulation of the date/time creation field to split into two distinct fields - Date only and Tine only
CAST(SUBSTRING(Fld4,4,2) + '-' +  SUBSTRING(Fld4,1,2) + '-' + SUBSTRING(Fld4,7,4) + ' 00:00:00.000' AS DATETIME),
SUBSTRING(Fld4,12,10),
Fld5, Fld6, Fld7, Fld8, Fld9, Fld10, Fld11, Fld12, Fld13, Fld14, Fld15, Fld16, Fld17,
Fld18, Fld19, Fld20, Fld21, 
--CTN and Selection Numbers from the TARIFF selection
B.CTN, B.Selection,
Fld22, Fld23,
CAST(SUBSTRING(Fld24,4,2) + '-' +  SUBSTRING(Fld24,1,2) + '-' + SUBSTRING(Fld24,7,4) + ' ' + SUBSTRING(Fld24,12,10) AS DATETIME),
Fld25, CAST(Fld26 AS MONEY), Fld27
FROM tblSCMTempImport LEFT OUTER JOIN (SELECT Fld2 AS OrderNo, Fld10 AS CTN, Fld7 AS Selection FROM tblSCMTempImport WHERE Fld1 = 'TariffItem') B
ON Fld2 = B.OrderNo
WHERE Fld1 = 'WarehouseDataReportOrder'
GROUP BY Fld2, Fld3, 
--Manipulation of the date/time creation field to split into two distinct fields - Date only and Tine only
CAST(SUBSTRING(Fld4,4,2) + '-' +  SUBSTRING(Fld4,1,2) + '-' + SUBSTRING(Fld4,7,4) + ' 00:00:00.000' AS DATETIME),
SUBSTRING(Fld4,12,10),
Fld5, Fld6, Fld7, Fld8, Fld9, Fld10, Fld11, Fld12, Fld13, Fld14, Fld15, Fld16, Fld17,
Fld18, Fld19, Fld20, Fld21, 
--CTN and Selection Numbers from the TARIFF selection
B.CTN, B.Selection,
Fld22, Fld23, Fld24, Fld25, CAST(Fld26 AS MONEY), Fld27



--Add in admin routines here and append of data to history tables
--Some thought needs to be given to the prevention of duplication! Poss Order number and Mod date unique?

--=============================================================================================================
--                            HANDSETS              
--=============================================================================================================

TRUNCATE TABLE tblSCMHandsetsCurrent

INSERT INTO tblSCMHandsetsCurrent
SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  CAST(fld10 AS Money), CAST(fld11 AS Money), CAST(fld9 AS MONEY), fld14,fld12, 'Booked'
FROM tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderCurrent) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'HandsetItem'
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  fld10, fld11, fld9, fld14,fld12

UPDATE tblSCMHandsetsCurrent
SET HandsetStatus = 'Despatched'
WHERE IMEINumber IS NOT NULL

UPDATE tblSCMHandsetsCurrent
SET HandsetStatus = 'Returned'
WHERE ReturnReason IS NOT NULL


--Add in admin routines here and append of data to history tables
--Some thought needs to be given to the prevention of duplication! Poss Order number and Mod date unique?

--=============================================================================================================
--                            PRICE PLANS AND COMMITMENT                 
--=============================================================================================================
TRUNCATE TABLE tblSCMPricePlansCurrent

INSERT INTO tblSCMPricePlansCurrent
SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, fld5, fld6, CAST(fld9 AS MONEY), NULL, CAST(fld12 AS INT), CAST(fld13 as INT),
CAST(fld14 AS MONEY), CAST(fld15 AS MONEY), CAST(fld20 AS INT), fld17, CAST(fld16 AS DATETIME)
FROM  tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderCurrent) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'TariffItem'
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, fld5, fld6, CAST(fld9 AS MONEY),  CAST(fld12 AS INT), CAST(fld13 as INT),
CAST(fld14 AS MONEY), CAST(fld15 AS MONEY), CAST(fld20 AS INT), fld17, CAST(fld16 AS DATETIME)
	
UPDATE tblSCMPricePlansCurrent
SET Prev_SOC_Code = B.fld4 
FROM tblSCMPricePlansCurrent JOIN (SELECT Fld2, Fld3, Fld4 FROM tblSCMTempImport WHERE fld1 = 'OldTariff') B
ON OrderNumber = B.fld2
AND OrderSelection = b.fld3
	


--Add in admin routines here and append of data to history tables
--Some thought needs to be given to the prevention of duplication! Poss Order number and Mod date unique?


--=============================================================================================================
--                            ADDITIONAL SERVICES                 
--=============================================================================================================
TRUNCATE TABLE tblSCMAddServicesCurrent
	
INSERT INTO tblSCMAddServicesCurrent
SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,fld5, fld6, CAST(fld9 AS Money), CAST(fld11 as INT),
CAST(fld12 AS MONEY), CAST(fld13 AS MONEY), CAST(fld14 as DATETIME), CAST(fld15 AS DATETIME)
FROM  tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderCurrent) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'ServiceItem'
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,fld5, fld6, CAST(fld9 AS Money), CAST(fld11 as INT),
CAST(fld12 AS MONEY), CAST(fld13 AS MONEY), CAST(fld14 as DATETIME), CAST(fld15 AS DATETIME)

--Add in admin routines here and append of data to history tables
--Some thought needs to be given to the prevention of duplication! Poss Order number and Mod date unique?


--=============================================================================================================
--                            ACCESSORIES                 
--=============================================================================================================



TRUNCATE TABLE tblSCMAccessoryCurrent

INSERT INTO tblSCMAccessoryCurrent
SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  CAST(fld10 AS Money), CAST(fld11 AS Money), CAST(fld9 AS MONEY), fld12, 'Booked'
FROM tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderCurrent) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'AccessoryItem'
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode, '0' + Fld5, fld6, fld7,  fld10, fld11, fld9, fld12


UPDATE tblSCMAccessoryCurrent
SET AccessoryStatus = 'Returned'
WHERE ReturnReason IS NOT NULL



--Add in admin routines here and append of data to history tables
--Some thought needs to be given to the prevention of duplication! Poss Order number and Mod date unique?


--=============================================================================================================
--                            DISCOUNTS                 
--=============================================================================================================

INSERT INTO tblSCMDiscountsCurrent
SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,Fld4, NULL, fld7, fld8, CAST(fld9 as DECIMAL(18,2)), 
CAST(Fld5 AS DATETIME), CAST(fld6 as DATETIME), NULL, NULL
FROM  tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderCurrent) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'Discount'
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,Fld4, fld7, fld8, CAST(fld9 as DECIMAL(18,2)), 
CAST(Fld5 AS DATETIME), CAST(fld6 as DATETIME)



UPDATE tblSCMDiscountsCurrent
SET DiscountPeriod = Datediff(m,DiscountStart, DiscountEnd)

UPDATE tblSCMDiscountsCurrent
SET DiscountTotalValue = DiscountValue * DiscountPeriod
WHERE DiscountValueType = 'amount'
AND DiscountType IN ('RC','OC')

UPDATE tblSCMDiscountsCurrent
SET DiscountTotalValue = ((DiscountValue * ISNULL(SOC_LR,0)) * DiscountPeriod) / 100
WHERE DiscountValueType = 'percentage'
AND DiscountType IN ('RC','OC')


--Add in admin routines here and append of data to history tables
--Some thought needs to be given to the prevention of duplication! Poss Order number and Mod date unique?


--=============================================================================================================
--                            CREDITS                 
--=============================================================================================================


INSERT INTO tblSCMCreditCurrent
SELECT B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,CAST(Fld10 AS Money)
FROM  tblSCMTempImport JOIN (SELECT * FROM tblSCMOrderHeaderCurrent) B
ON fld2 = B.OrderNumber
AND fld3 = B.SelectionNumber
WHERE fld1 = 'BillingCreditItem'
GROUP BY B.OrderNumber, B.CTN, B.SelectionNumber, B.BAN, B.OrderCreatedDate, B.OrderType, B.OrderCreatedTime, B.OrderCreator,
B.DateLastModified, B.OrderCloser,B.DealerCode,Fld10




--=============================================================================================================
--                            CONTRACTS                 
--=============================================================================================================


INSERT INTO tblSCMContractsCurrent
SELECT OrderNumber, CTN, OrderSelection, BAN, OrderDate, OrderType, OrderTime, OrderUser,
ModifiedDate, ModifiedUser,DealerCode, 'Contract', NULL, NULL, NULL, NULL, NULL, ContractPeriod, NULL
FROM tblSCMPricePlansCurrent

SELECT * FROM tblSCMCreditCurrent
WHERE OrderDate = '09-16-2008'

