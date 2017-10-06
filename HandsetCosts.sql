SELECT OrderNumber, OrderType, CTN, OrderUser, ProductID, ProductDescription,
ProductCost, ProductPrice, ProductOverridePrice, 
Current_Price,
CASE 
	WHEN ProductCost <> Current_Price THEN 'Change' ELSE 'Same' END AS PriceFlag
FROM tblSCMHandsetsCurrent A JOIN MIReporting.dbo.New_Handset_Table B
ON A.ProductID = B.Oracle_Code
--JOIN tblSCMOrderheaderCurrent C ON A.OrderNumber = B.OrderNumber
GROUP BY OrderNumber, OrderType, CTN, OrderUser, ProductID, ProductDescription,
ProductCost, ProductPrice, ProductOverridePrice, 
Current_Price,
CASE 
	WHEN ProductCost <> Current_Price THEN 'Change' ELSE 'Same' END