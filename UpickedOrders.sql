DROP TABLE #UnpickedOrders

CREATE TABLE #UnpickedOrders (
CTN VARCHAR(100),
BAN VARCHAR(100),
COMOrderNumber VARCHAR(100) ,
Agent VARCHAR(100),
Department VARCHAR(100),
Site VARCHAR(100),
GeminiContractDate DATETIME,
ContractStartDate DATETIME,
ContractEndDate DATETIME,
HandsetCode VARCHAR(100) ,
HandsetDescription VARCHAR(100),
HandsetQuote DATETIME,
HandsetPicked DATETIME,
HandsetDespatched DATETIME, 
HandsetWHState VARCHAR(100),
HandsetIMEI VARCHAR(100),
InStats VARCHAR(100) )

INSERT INTO #UnpickedOrders

SELECT CTN, BAN, NULL, Dl_Agent, Dl_Department, Dl_Site, Order_Date, Txn_Start_Date, Txn_End_Date, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM tbl_Transaction_History
WHERE Txn_ProductType = 'Contract'
AND Txn_Agent_ID = '2222' AND Dl_Department IN ('Customer Saves','Inbound Retention','Outbound Retention','High Value Retention','Direct Sales Inbound','Outboud Telesales')
AND Order_Date > '01-31-2009'

UPDATE #UnpickedOrders
SET COMOrderNumber = B.OrderNumber
FROM #UnpickedOrders A JOIN tblSCMOrderHeaderAllHistory B
ON A.GeminiContractDate = B.DateLastModified
AND A.CTN = B.CTN
WHERE B.OrderStatus IN (SELECT OrderStatus FROM dbo.tblSCMOrderStatus WHERE ValidOrder = 'True')

DELETE FROM #UnpickedOrders WHERE COMOrderNumber IS NULL

UPDATE #UnpickedOrders
SET HandsetCode = B.ProductID, 
HandsetDescription = B.ProductDescription, 
HandsetQuote = B.QuoteDate, 
HandsetPicked = B.BookedDate, 
HandsetDespatched = B.DespatchDate, 
HandsetWHState = B.WarehouseStatus, 
HandsetIMEI = B.ProductIDNumber
FROM #UnpickedOrders A JOIN dbo.tblSCMHardwareFeedHistory B
ON A.COMOrderNumber = B.OrigOrderNumber
AND A.CTN = B.CTN
WHERE B.ItemType = 'HandsetItem'



SELECT * FROM #UnpickedOrders
WHERE HandsetQuote IS NOT NULL
AND HandsetWHState IS NULL


SELECT Oracle_Code, Current_Price FROM MIReporting.dbo.New_Handset_Table WHERE Product_Type = 'Handset'

