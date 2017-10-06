CREATE TABLE #ContractIssues (
OrderDate DATETIME,
CTN VARCHAR(100),
BAN VARCHAR(100),
UserID VARCHAR(100),
CommitmentStartDate DATETIME,
CommitmentEndDate DATETIME,
SOC VARCHAR(100),
SOCDesc VARCHAR(100),
SVAPSOC VARCHAR(100),
SVAPContPeriod INT )

INSERT INTO #ContractIssues
SELECT Order_Date, CTN, BAN, Agent_ID, New_Contract_Start_Date, New_Contract_End_Date, NULL, NULL, NULL, NULL
FROM dbo.tbl_Contract_Upgrades_History
WHERE Order_Date > GetDate()-5

UPDATE #ContractIssues
SET SOC = B.New_SOC_Code
FROM #ContractIssues A JOIN dbo.tbl_PricePlan_Changes_History B
ON A.CTN = B.Memo_CTN AND A.OrderDate = B.Memo_Date
AND B.Memo_Date > GetDate()-5

SELECT * FROM #ContractIssues WHERE SOC = 'VFPM'

CREATE TABLE #TmpFixSOCs (
CTN VARCHAR(100),
AgentID VARCHAR(100),
SOCCode VARCHAR(100),
LineRental MONEY,
AdjustedSOCode VARCHAR(100),
AdjustedLineRental MONEY,
AdjustedSOCDescription VARCHAR(100),
AdjustedContractLength INT)

INSERT INTO #TmpFixSOCs
SELECT CTN, Txn_Agent_ID, Txn_ProductCode, Txn_Recurring_Revenue, NULL, NULL, NULL, NULL
FROM tbl_Transaction_Current
WHERE Txn_ProductType = 'Price Plan' AND Txn_ProductCode IN ('vbusiness','VFPM')


UPDATE #TmpFixSOCs
SET AdjustedSOCOde = B.fld5,
AdjustedSOCDescription = B.fld6,
AdjustedLineRental = CAST(B.fld9 AS MONEY),
AdjustedContractLength = CAST(B.fld20 AS INT)
FROM #TmpFixSOCs A JOIN tblSCMTempImport B
ON A.CTN = B.fld10
WHERE B.fld1 = 'TariffItem'

SELECT * FROM #TmpFixSOCs

