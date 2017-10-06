SELECT 
ConnectionMonth, SubscriberStatus, DelinqState, PaymentTypeGroup, AccountTypeGroup, CustomerHVC,
Count(CTN) AS TotalCustomers, 
SUM(ISNULL(SOC_DDM250,0)) AS DDM250,
SUM(ISNULL(SOC_CHQ_ADFEE,0)) AS CHQ_ADFEE,
SUM(ISNULL(SOC_PCHQ300,0)) AS PCHQ300
FROM NonDDPayers
GROUP BY ConnectionMonth, SubscriberStatus, DelinqState, PaymentTypeGroup, AccountTypeGroup, CustomerHVC 