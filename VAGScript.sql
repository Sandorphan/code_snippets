DROP TABLE #VSSSales

CREATE TABLE #VSSSales (
OrderDate DATETIME,
OrderNumber VARCHAR(100),
CTN VARCHAR(100),
ProductCode VARCHAR(100),
ProductDescription VARCHAR(100),
ProductCost MONEY,
ProductRevenue MONEY,
Tariff VARCHAR(100),
LineRental MONEY,
AddSOC VARCHAR(100),
SubsidyType VARCHAR(100),
AdditionalContribution MONEY)

--get Vodafone Sure Signal sales from the COM hardware table
INSERT INTO #VSSSales (OrderDate, OrderNumber, CTN, ProductCode, ProductDescription, ProductCost, ProductRevenue)
SELECT BookedDate, OrderNumber, CTN, ProductID, ProductDescription, ProductCost, ProductPrice
FROM MIStandardMetrics.dbo.tblSCMHardwareFeedCurrent
WHERE ProductID = '066965'
AND BookedDate IS NOT NULL

--Get the tariff that was sold at point of sale
UPDATE #VSSSales
SET Tariff = B.New_SOC_Code,
LineRental = B.New_Rate
FROM #VSSSales A JOIN MIStandardMetrics.dbo.tbl_PricePlan_Changes B
ON A.CTN = B.Memo_CTN

--if the sale was standalone, fetch the current tariff the customer is on
UPDATE #VSSSales
SET Tariff = B.SOC_Code,
LineRental = C.Rate
FROM #VSSSales A JOIN MIReporting.dbo.rep_000839_PricePlans B
ON A.CTN = B.Subscriber_CTN JOIN MIReferenceTables.dbo.tblSOCReference C
ON B.SOC_Code = C.SOC_Code
WHERE A.Tariff IS NULL


--Update any additional services sold on the product that could discount it
--need to amend the SOC Code to be relative at the time
UPDATE #VSSSales
SET AddSOC = B.SOC_Code
FROM #VSSSales A JOIN MIStandardMetrics.dbo.tbl_Additional_Services B
ON A.CTN = B.CTN
WHERE B.SOC_Code IN ('VSS512','VSS524')

UPDATE #VSSSales
SET SubsidyType = 
CASE	WHEN AddSOC IS NOT NULL THEN 'HP'
	WHEN LineRental >= 21.28 THEN 'HSpend'
	WHEN LineRental <21.28 THEN 'LSpend'
	ELSE 'Exception' END


UPDATE #VSSSales
SET AdditionalContribution =
CASE 	WHEN SubsidyType = 'HP' THEN ProductCost
	WHEN SubsidyType = 'HSpend' THEN ProductCost - 50
	WHEN SubsidyType = 'LSpend' THEN ProductCost - 120
	ELSE 0 END


SELECT * FROM #VSSSales