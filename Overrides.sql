SELECT 
OrderDate, CTN, Agent, Team, 
HandsetCosts-HandsetRevenue,
((((GPNotionalProfit-(DiscountPPCosts+CreditNoteCost)))*0.406)-DiscountPPPenalty) AS TargetBudget,
1.15*((((GPNotionalProfit-(DiscountPPCosts+CreditNoteCost)))*0.406)-DiscountPPPenalty) AS MaxBudget
FROM dbo.tblinSpireSalesDataHistoryRRO 
where (HandsetCosts-HandsetRevenue) > 
(((((GPNotionalProfit-(DiscountPPCosts+CreditNoteCost)))*0.406)-DiscountPPPenalty))
AND Site = 'Stoke'
AND Team NOT IN ('Karen Machin','Nina Farr')
AND HandsetCosts > 0
AND HandsetDescription NOT LIKE '%apple%'
AND OrderDate > '09-30-2011'
AND OrderType = 'Retention'
