
TRUNCATE TABLE tblinSpireSalesDataCurrentACCORD

INSERT INTO dbo.tblinSpireSalesDataCurrentACCORD
SELECT *, 'Non Accord', NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL FROM tblinSpireSalesDataHistory
WHERE OrderDate > '05-31-2010'

UPDATE tblinSpireSalesDataCurrentACCORD
SET AccordFlag = 'Accord',
AccordMaxBudget = B.AccordmaxBudget,
AccordTargetBudget = B.AccordTargetBudget,
AccordCosts = B.AccordCosts,
AccordFCV = B.AccordFVC,
AccordNP = B.AccordNP,
AccordActualCosts = ((HandsetCosts + DatacardCosts + NetbookCosts + AccessoryCost + DeliveryCost + CreditNoteCost)-(HandsetSubsidy + HandsetRevenue + DatacardSubsidy + DatacardRevenue + NetbookSubsidy + NetbookRevenue + DeliveryRevenue)),
AccordTariff = B.Tariff,
AccordDiscount = CASE WHEN B.DiscountFlag = 'SVAP' THEN 'Acc' ELSE 'NonAcc' END
FROM tblinSpireSalesDataCurrentACCORD A JOIN dbo.tblNotionalProfit_AccordValues B
ON A.CTN = B.CTN AND A.OrderDate = B.ModifiedDate AND A.AgentID = B.OrderUser

UPDATE tblinSpireSalesDataCurrentACCORD
SET AccordAdjNotProfit = AccordFCV - AccordActualCosts


UPDATE tblinSpireSalesDataCurrentACCORD
SET Service1Profit = 0,Service2Profit = 0,Service3Profit = 0,Service4Profit = 0,Service5Profit = 0,Service6Profit = 0,Service7Profit = 0,Service8Profit = 0,Service9Profit = 0,
GPNotionalProfit = 0, NPNotionalProfit = 0
WHERE AccordFlag = 'Accord'

UPDATE tblinSpireSalesDataCurrentACCORD
SET DiscountCosts = 0
WHERE AccordFlag = 'Accord' AND AccordDiscount NOT LIKE 'NonAcc'

UPDATE tblinSpireSalesDataCurrentACCORD
SET PricePlanRecCommCost = 0, PricePlanFixCommCost = 0, ServicesRecCommCost = 0, ServicesFixCommCost = 0
WHERE AccordFlag = 'Accord' AND AccordTariff = PricePlanSOC

UPDATE tblinSpireSalesDataCurrentACCORD
SET GPNotionalProfit = AccordFCV,
NPNotionalProfit = AccordFCV
WHERE AccordFlag = 'Accord'

UPDATE tblinspiresalesdatacurrentaccord
SET AccordMaxBudget = 0, AccordTargetBudget = 0, AccordCosts = 0, AccordFCV = 0, AccordNP = 0, AccordActualCosts = 0, AccordAdjNotProfit = 0
WHERE ContractGrossVolume = 0


TRUNCATE TABLE tblinSpireSalesDataHistoryACCORD

INSERT INTO tblinSpireSalesDataHistoryACCORD
SELECT * FROM tblinSpireSalesDataCurrentACCORD