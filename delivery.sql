SELECT Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
Txn_ProductCode, Txn_ProductDescription, Current_Price,
Count(CTN) AS TotalDeliveryOrders,
SUM(CASE
	WHEN Current_Price <= Txn_OneOff_Revenue THEN 1 ELSE 0 END) AS CompliantOrders,
SUM(Current_Price) AS TotalCost, SUM(Txn_OneOff_Revenue) AS TotalRevenue
FROM tbl_Transaction_Current A JOIN MIReporting.dbo.New_Handset_Table B ON A.Txn_ProductCode = B.Oracle_Code
WHERE Txn_ProductType LIKE '%Delivery%'
AND Dl_Function = 'Commercial Operations' AND Dl_Channel = 'Call Centre - Sales'
GROUP BY Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
Txn_ProductCode, Txn_ProductDescription, Current_Price


