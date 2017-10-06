
DELETE FROM Master_Sales_History WHERE Order_Date =  '07-17-2006'


EXEC Multiple_Handsets '07-17-2006'

TRUNCATE TABLE Master_Sales
INSERT INTO Processes_Completed VALUES('**MASTER_SALES_INITIAL_STARTED**',GetDate())
EXEC Master_Sales_Initial  '07-17-2006'
INSERT INTO Processes_Completed VALUES('**MASTER_SALES_XREFS_STARTED**',GetDate())
EXEC Master_Sales_XRefs  '07-17-2006'

INSERT INTO Master_Sales_History
SELECT * FROM Master_Sales

INSERT INTO Processes_Completed VALUES('**MASTER_SALES_HISTORY_INSERT_FINISHED**',GetDate())
EXEC Master_Sales_History_XRefs
