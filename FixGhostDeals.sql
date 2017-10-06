SELECT * FROM tbl_Transaction_History WHERE CTN IN (
'07795631700', '07765246192')
AND Txn_ProductType LIKE '%Contract%'

DROP TABLE #RetailFixIssues
CREATE TABLE #RetailFixIssues (
OrderDate DATETIME,
CTN VARCHAR(100),
AgentID VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
Department VARCHAR(100),
Channel VARCHAR(100),
BU VARCHAR(10),
ContractGross INT,
ContractNet INT)

INSERT INTO #RetailFixIssues
SELECT Order_Date, CTN, Dl_Agent_ID, Dl_Agent, Dl_Team, Dl_Department, Dl_Channel, Dl_BusinessUnit, Txn_Gross_Period, Txn_Net_Period FROM tbl_Transaction_History WHERE 
Dl_Flag_C = 'Retail_Fix'
AND Txn_ProductType LIKE '%Contract%'
AND Dl_Channel NOT IN ('Retail','Indirect','Online','Enterprise Online')
AND Dl_Agent_ID = '666800009'
AND Order_Date > '08-31-2010'

SELECT * FROM #RetailFixIssues WHERE Len(Channel)>5