CREATE TABLE #Contracts (
OrderDate DATETIME,
CTN VARCHAR(50) NULL,
Userx VARCHAR(50) NULL)

INSERT INTO #Contracts
SELECT OrderDate, CTN, OrderUser
FROM dbo.tblSCMContractsHistory

UPDATE tbl_Transaction_History
SET Dl_Agent_ID = B.UserX
FROM tbl_Transaction_History A JOIN #Contracts B
ON A.CTN = B.CTN AND A.Order_Date = B.OrderDate


UPDATE tbl_Transaction_Summary
SET Agent_ID = B.UserX
FROM tbl_Transaction_Summary A JOIN #Contracts B
ON A.CTN = B.CTN AND A.Order_Date = B.OrderDate
WHERE A.Order_Date > '10-31-2008'