INSERT INTO tblinspiresalesdatahistoryfix
select * from tblinspiresalesdatahistory where ContractGrossVolume > 0 AND PricePlanSOC IS NULL and orderdate > '07-31-2009'

UPDATE tblinspiresalesdatahistoryfix
SET PricePlanSOC = B.SOC_Code
FROM tblinspiresalesdatahistoryfix A JOIN MIReporting.dbo.rep_000839_priceplans B
ON A.CTN = B.Subscriber_CTN

SELECT * FROM tblinspiresalesdatahistoryfix WHERE CTN = '07833257889'

UPDATE tblinspiresalesdatahistoryfix
SET PricePlanDescription = B.SOC_Description,
PricePlanLineRental = B.Rate
FROM tblinspiresalesdatahistoryfix A JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.PricePlanSOC = B.SOC_Code



UPDATE tblinspiresalesdatahistoryfix
SET 
SIMOnlyVolume = CASE WHEN PricePlanDescription LIKE '%SIMO%' THEN 1 WHEN PricePlanDescription LIKE '%Mobile BB%' THEN 1 ELSE 0 END,
PricePlanChanges = 0,
PricePlanSTCT = 1
FROM tblinspiresalesdatahistoryfix


UPDATE tblinspiresalesdatahistoryfix
SET PricePlanSTCT = 0
WHERE PricePlanSOC IS NULL

UPDATE tblinspiresalesdatahistoryfix
SET ContractSIMOnly = CASE WHEN SimOnlyVolume > 0 AND ContractGrossPeriod > 11 THEN 1 ELSE 0 END

UPDATE tblinspiresalesdatahistoryfix
SET GPNotionalProfit = PricePlanLineRental * ContractGrossperiod,
NPNotionalProfit = PricePlanLineRental * ContractNetPeriod

UPDATE tblinspiresalesdatahistoryfix
SET TariffGroup = 'MBB'
FROM tblinspiresalesdatahistoryfix A JOIN MIReferenceTables.dbo.tblMBBSOCs B
ON A.PricePlanSOC = B.SOC

UPDATE tblinspiresalesdatahistoryfix
SET TariffGroup = 'SIMOnly'
FROM tblinspiresalesdatahistoryfix
WHERE Simonlyvolume > 0

UPDATE tblinspiresalesdatahistoryfix
SET TariffGroup = 'None'
WHERE PricePlanSOC IS NULL

UPDATE tblinspiresalesdatahistoryfix
SET TariffGroup = 'Voice'
WHERE TariffGroup IS NULL