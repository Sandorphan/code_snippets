DROP TABLE tblInsireProductsDaily


CREATE TABLE tblInspireProductsDaily (
OrderDate DATETIME,
OrderWeek VARCHAR(100),
OrderMonth VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RFunction VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
ProductType VARCHAR(100),
ProductGroup VARCHAR(100),
ProductDescription VARCHAR(100),
ProductCode VARCHAR(100),
ProductCost MONEY,
ProductRevenue MONEY,
Volume INT)

--Handsets

INSERT INTO tblInspireProductsDaily
SELECT Order_Date, NULL, NULL, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
'Handset', NULL, Txn_ProductDescription, Txn_ProductCode, SUM(Txn_OneOff_Cost), SUM(Txn_OneOff_Revenue), COUNT(Txn_ProductCode)
FROM tbl_Transaction_Current WHERE Txn_ProductType = 'Handset'
GROUP BY Order_Date, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
 Txn_ProductDescription, Txn_ProductCode

UPDATE tblInspireProductsDaily
SET OrderWeek = B.WeekText, OrderMonth = B.MonthText
FROM tblInspireProductsDaily JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON OrderDate = B.NewDate

UPDATE tblInspireProductsDaily
SET ProductGroup = B.Manufacturer,
ProductDescription = B.handset_Description
FROM tblInspireProductsDaily A JOIN MIReporting.dbo.New_Handset_Table B
ON ProductCode = B.Oracle_Code

UPDATE tblInspireProductsDaily
SET ProductGroup = B.Manufacturer,
ProductDescription = B.handset_Description
FROM tblInspireProductsDaily A JOIN MIReporting.dbo.New_Handset_Table B
ON ProductCode = B.HermesCode


--Tariffs

INSERT INTO tblInspireProductsDaily
SELECT Order_Date, NULL, NULL, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
'Price Plan', NULL, Txn_ProductDescription, Txn_ProductCode, SUM(Txn_Recurring_Revenue), 0, COUNT(Txn_ProductCode)
FROM tbl_Transaction_Current WHERE Txn_ProductType = 'Price Plan'
GROUP BY Order_Date, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_BusinessUnit,
 Txn_ProductDescription, Txn_ProductCode

UPDATE tblInspireProductsDaily
SET OrderWeek = B.WeekText, OrderMonth = B.MonthText
FROM tblInspireProductsDaily JOIN MIReferenceTables.dbo.tbl_Ref_Dates B
ON OrderDate = B.NewDate











UPDATE tblInspireProductsDaily
SET Agent = ISNULL(Agent,'Unknown User'),
Team =  ISNULL(Team,'Unknown User'),
CCM =  ISNULL(CCM,'Unknown User'),
Site =  ISNULL(Site,'Unknown User'),
Department =  ISNULL(Department,'Unknown User'),
RFunction =  ISNULL(RFunction,'Unknown User'),
Channel =  ISNULL(Channel,'Unknown User'),
BusinessUnit =  ISNULL(BusinessUnit,'Unknown User')

SELECT * FROM tblInspireProductsDaily

