SELECT Worksheet, CTN, BAN, IMEI, Despatch_Date, Hermes_User, Department, Channel FROM Handset_Returns 
WHERE (Despatch_Date between '04-01-2009' and '07-31-2009') and Return_Date is null AND CTN IS NOT NULL AND LEN(CTN) > 5 
AND Department IN (SELECT Department FROM MIReferenceTables.dbo.tbl_agents WHERE Business_Unit = 'CBU')
AND Hermes_User NOT LIKE 'Marsh'
