TRUNCATE TABLE tblinSpireSalesDataHistoryACCORD_FIX

INSERT INTO tblinSpireSalesDataHistoryACCORD_FIX
SELECT * FROM tblinSpireSalesDataHistoryACCORD
WHERE OrderDate BETWEEN '02-23-2011' AND '02-24-2011'

SELECT OrderDate, CTN, Agent, PricePlanLineRental,ContractGrossPeriod, GPNotionalProfit, ContractGrossVolume, HandsetCosts, AccordFlag, AccordFCV
FROM tblinSpireSalesDataHistoryACCORD_FIX
WHERE Team = 'Ben Smith'


UPDATE tblinSpireSalesDataHistoryACCORD_FIX
SET GPNotionalProfit = B.AccordFVC,
NPNotionalProfit = B.AccordFVC,
AccordFlag = 'Accord',
AccordMaxBudget = B.AccordMaxBudget,
AccordTargetBudget = B.AccordMaxBudget * 0.75,
AccordCosts = B.AccordCosts,
AccordFCV = B.AccordFVC,
AccordNP = 0,
AccordActualCosts = 0,
AccordAdjNotProfit = 0,
AccordTariff = NULL,
AccordDiscount = NULL
FROM tblinSpireSalesDataHistoryACCORD_FIX A
JOIN tblNotionalProfit_AccordValues B
ON A.CTN = B.CTN
WHERE ModifiedDate BETWEEN '02-23-2011' AND '02-24-2011'


UPDATE tblinSpireSalesDataHistoryACCORD_FIX
SET GPNotionalProfit = 0, NPNotionalProfit = 0
WHERE ContractGrossVolume = 0

DELETE FROM tblinSpireSalesDataHistoryACCORD
WHERE OrderDate BETWEEN '02-23-2011' AND '02-24-2011'

INSERT INTO tblinSpireSalesDataHistoryACCORD
SELECT * FROM tblinSpireSalesDataHistoryACCORD_FIX