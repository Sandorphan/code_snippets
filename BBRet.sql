SELECT BookedDate, ProductDescription, 
SUM(CASE WHEN BookedDate IS NOT NULL THEN 1 ELSE 0 END) AS SalesOrders,
SUM(CASE WHEN DespatchDate IS NOT NULL THEN 1 ELSE 0 END) AS SalesDespatches,
SUM(CASE WHEN ReturnDate IS NOT NULL THEN 1 ELSE 0 END) AS SalesReturns
FROM dbo.tblSCMHardwareFeedHistory
WHERE BookedDate > '05-31-2011'
AND ProductDescription LIKE '%blackberry%'
AND ItemType = 'HandsetItem'
GROUP BY BookedDate, ProductDescription

