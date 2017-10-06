SELECT * FROM tbl_PricePlan_Changes_History
WHERE memo_Date =CAST(
CAST(Datepart(YEAR,Getdate()-1) AS VARCHAR(4)) + '-' + 
CAST(Datepart(MONTH,Getdate()-1) AS VARCHAR(2)) + '-' + 
CAST(Datepart(DAY,Getdate()-1) AS VARCHAR(2)) + ' 00:00:00.000' 
AS VARCHAR(25))