

DROP TABLE tblStormReporting

CREATE TABLE tblStormReporting (
OrderDate DATETIME NULL,
OrderWeek VARCHAR(100),
OrderMonth VARCHAR(100),
CTN VARCHAR(100),
BAN VARCHAR(100),
CustomerSegment VARCHAR(100),
OrderType VARCHAR(100),
OrderStatus VARCHAR(100),
OrigBusUnit VARCHAR(100),
OrigChannel VARCHAR(100),
OrigDepartment VARCHAR(100),
ReportBusUnit VARCHAR(100),
ReportChannel VARCHAR(100),
Device VARCHAR(100),
Device_Quantity INT,
PricePlan VARCHAR(100),
Contract_Length INT)

TRUNCATE TABLE tblStormReporting

INSERT INTO tblStormReporting (OrderDate, CTN, BAN, CustomerSegment, OrderType, OrderStatus, OrigBusUnit, OrigChannel, OrigDepartment,
Device, Device_Quantity)
SELECT Order_Date, CTN, BAN, ISNULL(Dl_AccountType,'Other'),Dl_ActivityType, 
CASE
	WHEN Txn_Despatch_Date IS NULL AND Txn_Cancelled_Date IS NULL THEN 'On Order'
	WHEN Txn_Despatch_Date IS NOT NULL Then 'Despatched'
	WHEN Txn_Cancelled_Date IS NOT NULL Then 'Cancelled'
	ELSE 'On Order' END,
 Dl_BusinessUnit, Dl_Channel, Dl_Department,
Txn_ProductDescription, Txn_Quantity
FROM tbl_Transaction_History
WHERE Txn_ProductDescription LIKE '%Storm%'
AND Txn_ProductType = 'Handset'
AND Order_Date > '10-31-2008'
GROUP BY Order_Date, CTN, BAN, ISNULL(Dl_AccountType,'Other'),Dl_ActivityType, 
CASE
	WHEN Txn_Despatch_Date IS NULL AND Txn_Cancelled_Date IS NULL THEN 'On Order'
	WHEN Txn_Despatch_Date IS NOT NULL Then 'Despatched'
	WHEN Txn_Cancelled_Date IS NOT NULL Then 'Cancelled'
	ELSE 'On Order' END,
 Dl_BusinessUnit, Dl_Channel, Dl_Department,
Txn_ProductDescription, Txn_Quantity


UPDATE tblStormReporting
SET PricePlan = B.Txn_ProductDescription
FROM tblStormReporting A LEFT OUTER JOIN tbl_Transaction_History B
ON A.CTN = B.CTN AND A.OrderDate = B.Order_Date
WHERE B.Txn_ProductType = 'Price Plan'
AND Order_Date > '10-31-2008'

UPDATE tblStormReporting
SET PricePlan = 'Maintenence/Bulk Order' 
WHERE PricePlan IS NULL


UPDATE tblStormReporting
SET Contract_Length = B.Txn_Gross_Period
FROM tblStormReporting A LEFT OUTER JOIN tbl_Transaction_History B
ON A.CTN = B.CTN AND A.OrderDate = B.Order_Date
WHERE B.Txn_ProductType LIKE 'Contract%'
AND Order_Date > '10-31-2008'

UPDATE tblStormReporting
SET Contract_Length = 0 
WHERE Contract_Length IS NULL

UPDATE tblStormReporting
SET OrderWeek = B.WeekText, OrderMonth = B.MonthText
FROM tblStormReporting A JOIN MIreferenceTables.dbo.tbl_Ref_Dates B
ON A.OrderDate = B.NewDate


UPDATE tblStormReporting
SET ReportBusUnit = B.ReportBU,
ReportChannel = B.ReportChann
FROM tblStormReporting A JOIN MIReferenceTables.dbo.tblExecReportGroupings B
ON A.OrigBusUnit = B.OrigBusUnit AND A.OrigChannel = B.OrigChannel

UPDATE tblStormReporting 
SET ReportChannel = 'Indirect - P4U'
WHERE OrigDepartment LIKE '%P4U%' OR OrigDepartment LIKE '%phones4u%' OR OrigDepartment LIKE '%phones 4u%' 

UPDATE tblStormReporting
SET ReportBusUnit = 'Other',
ReportChannel = 'Wholesale/Distribution'
WHERE BAN IN (SELECT BAN FROM MIReferenceTables.dbo.Tbl_ThirdParty_Accounts)

UPDATE tblStormReporting
SET ReportBusUnit = 'Other',
ReportChannel = 'Wholesale/Distribution'
WHERE OrigDepartment IN ('Handset Distributor','Device Management')

UPDATE tblStormReporting
SET ReportBusUnit = 'CBU',
ReportChannel = 'Online'
WHERE OrigDepartment = 'Quickstop Vod'

UPDATE tblStormReporting
SET ReportBusUnit = 'Other',
ReportChannel = 'Call Centre - Other'
WHERE ReportBusUnit IS NULL AND ReportChannel IS NULL

UPDATE tblStormReporting
SET CustomerSegment = 'Business'
WHERE CustomerSegment NOT LIKE '%Consumer%'


SELECT OrderDate, OrderWeek, OrderMonth, CustomerSegment, OrderType,
OrderStatus, ReportBusUnit, ReportChannel, SUM(Device_Quantity), PricePlan, 
CASE
	WHEN Contract_Length < 12 THEN 0
	WHEN Contract_Length < 18 THEN 12
	WHEN Contract_Length < 24 THEN 18
	ELSE 24 END
FROM tblStormReporting 
GROUP BY OrderDate, OrderWeek, OrderMonth, CustomerSegment, OrderType,
OrderStatus, ReportBusUnit, ReportChannel, PricePlan, 
CASE
	WHEN Contract_Length < 12 THEN 0
	WHEN Contract_Length < 18 THEN 12
	WHEN Contract_Length < 24 THEN 18
	ELSE 24 END
