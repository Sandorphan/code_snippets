DROP TABLE #tmpSCMFix
CREATE TABLE #tmpSCMFix (
Order_Date DATETIME,
CTN VARCHAR(100),
UserX VARCHAR(100))

INSERT INTO #tmpSCMFix
SELECT DISTINCT OrderDate, CTN, OrderUser
FROM tblSCMContractsHistory

TRUNCATE TABLE tbl_Transaction_Current
INSERT INTO tbl_TransactioN_Current
SELECT * FROM tbl_Transaction_History WHERE Order_Date BETWEEN '11-01-2008' AND '11-07-2008'

UPDATE tbl_Transaction_Current
SET Dl_Agent_ID = B.UserX,
Txn_Flag_C = 'COM_Agent_Table_Fix'
FROM tbl_Transaction_Current A JOIN #tmpSCMFix B
ON A.Order_Date = B.Order_date
AND A.CTN = B.CTN

SELECT * FROM tbl_Transaction_Current WHERE 
Txn_Flag_C = 'COM_Agent_Table_Fix'

UPDATE tbl_Transaction_Current
SET Dl_Agent = B.Name,
Dl_Team = B.TM,
Dl_CCM = B.CCM,
Dl_Department = B.Department,
Dl_Site = B.Site,
Dl_Function = B.Reporting_Function, 
Dl_Channel = B.Channel,
Dl_Segment = B.Segment,
Dl_BusinessUnit = B.Business_Unit
FROM tbl_Transaction_Current A
JOIN MIReferenceTables.dbo.tbl_agents B
ON A.Dl_Agent_ID = B.Crystal_Agent_Name
WHERE  A.Txn_Flag_C = 'COM_Agent_Table_Fix'

DELETE FROM tbl_Transaction_History
WHERE Order_Date BETWEEN  '11-01-2008' AND '11-07-2008'

INSERT INTO tbl_Transaction_History
SELECT * FROM tbl_Transaction_Current

EXEC sp_txn_summary