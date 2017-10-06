DROP TABLE #NoContracts

CREATE TABLE #NoContracts (
OrderDate DATETIME,
OrderRef VARCHAR(100),
CTN VARCHAR(100),
Department VARCHAR(100),
Handset VARCHAR(100),
STATSContractPeriod INT, 
COMContractPeriod INT,
MemoType VARCHAR(100))

INSERT INTO #NoContracts
SELECT Order_Date, NULL, CTN, Department, Primary_Handset, Contract_Gross_Period_Total, NULL, NULL
FROM tbl_Transaction_Summary
WHERE Order_Date IN ( '04-04-2009', '04-11-2009')


SELECT * FROM #NoContracts

DELETE FROM #NoContracts WHERE Handset = 'No Handset'
DELETE FROM #NoContracts WHERE Handset IS NULL
DELETE FROM #NoContracts WHERE STATSContractPeriod > 0
DELETE FROM #NoContracts WHERE Department NOT IN ('Inbound Retention','Customer Saves','Outbound Retention','High Value Retention','Customer Retention')
DELETE FROM #NoContracts WHERE Department IS NULL

UPDATE #NoContracts
SET OrderRef = B.OrderNumber,
COMContractPeriod = B.ContractPeriod
FROM #NoContracts A JOIN dbo.tblSCMPricePlansHistory B
ON A.CTN = B.CTN
AND A.OrderDate = B.OrderDate