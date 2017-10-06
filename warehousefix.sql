SELECT * FROM tblWarehouseFix

SELECT TOP 100 * FROM tblSCMHardwareFeedHistory


UPDATE tblSCMHardwareFeedHistory
SET BookedDate = '03-22-2009',
DespatchDate = '03-22-2009',
ProductIDNumber = B.FNESN,
OrderStatus = 'CharismaFix'
FROM tblSCMHardwareFeedHistory A
JOIN tblWarehouseFix B
ON A.OrderNumber = B.OHCLON
AND A.ProductID = B.DDITEM
WHERE A.ItemType IN ('HandsetItem','SIMItem','AccessoryItem')
AND A.WarehouseStatus IS NULL

UPDATE tblSCMHardwareFeedHistory
SET BookedDate = '03-22-2009',
DespatchDate = '03-22-2009',
ProductIDNumber = B.PAPARC,
OrderStatus = 'CharismaFix'
FROM tblSCMHardwareFeedHistory A
JOIN tblWarehouseFix B
ON A.OrderNumber = B.OHCLON
AND A.ProductID = B.DDITEM
WHERE A.ItemType IN ('DeliveryItem')
AND A.WarehouseStatus IS NULL

UPDATE tblSCMHardwareFeedHistory
SET WarehouseStatus = 'S02', ProductStatus = 'Despatched'
WHERE OrderStatus = 'CharismaFix' 

SELECT * FROM tblSCMHardwareFeedHistory WHERE OrderStatus = 'CharismaFix' ORDER BY OrderNumber