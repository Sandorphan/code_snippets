CREATE TABLE tbliPhoneTariffServices (
OrderDate DATETIME, 
CTN VARCHAR(100),
Department VARCHAR(100),
Site VARCHAR(100),
Channel VARCHAR(100),
BusUnit VARCHAR(100),
TariffSOC VARCHAR(100),
TariffDesc VARCHAR(100),
AddServiceSOC VARCHAR(100),
AddServiceSOCDesc VARCHAR(100))

INSERT INTO tbliPhoneTariffServices
SELECT Order_Date, CTN, Dl_Department, Dl_Site, Dl_Channel, Dl_BusinessUnit, Txn_ProductCode, Txn_ProductDescription,
NULL, NULL
FROM tbl_transaction_current where txn_producttype = 'Price Plan' AND Txn_ProductDescription LIKE '%IPN%'


SELECT * FROm tbliPhoneTariffServices A LEFT OUTER JOIN SPSVRSQL01.MIStandardMetrics.dbo.tbl_Additional_Services B
ON  A.CTN = B.CTN