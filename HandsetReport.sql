SELECT BusinessUnit, Channel, Department, Site, OrderMonth,
SUM(CASE WHEN OrderType = 'Retention' THEN HandsetVolume + DatacardVolume + NetbookVolume END) AS RetentionOrderHandsets,
SUM(CASE WHEN OrderType = 'Retention' THEN HandsetExchanges END) AS RetentionExchangeHandsets,
SUM(CASE WHEN OrderType = 'Acquisition' THEN HandsetVolume + DatacardVolume + NetbookVolume END) AS AcquisitionOrderHandsets,
SUM(CASE WHEN OrderType = 'Acquisition' THEN HandsetExchanges END) AS AcquisitionExchangeHandsets,
SUM(CASE WHEN OrderType = 'Maintenance' THEN HandsetVolume + DatacardVolume + NetbookVolume END) AS MaintenanceOrderHandsets,
SUM(CASE WHEN OrderType = 'Maintenance' THEN HandsetExchanges END) AS MaintenanceExchangeHandsets
FROM dbo.tblinSpireSalesDataSummaryACCORD_History
GROUP BY BusinessUnit, Channel, Department, Site, OrderMonth
