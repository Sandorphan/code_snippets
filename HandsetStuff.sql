SELECT OrderDate, OrderMonth, CTN, Department, Site, HandsetDescription, HandsetCosts, HandsetRevenue FROm dbo.tblinSpireSalesDataHistoryACCORD
WHERE OrderType = 'Maintenance' AND HandsetDescription IS NOT NULL
AND Channel = 'Call Centre - Customer' AND BusinessUnit = 'CBU'
AND OrderDate > '01-31-2012'
AND HandsetCosts > 0