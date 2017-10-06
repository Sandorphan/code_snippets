SELECT Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit, OrderDate,
OrderType, 
Count(CTN) AS Orders,
SUM(Num_of_Callbacks) AS TotalCallbacks,
SUM(SIR_FAIL_IND) AS SIR_Fails
FROM RP_DTL_SIR_SCORE
WHERE Channel = 'Call Centre - Sales'
GROUP BY Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit, OrderDate,
OrderType