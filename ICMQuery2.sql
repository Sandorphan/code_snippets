a.options,					
sum(a.CallOffered)As OFFERED,					
Sum(a.CallAbnd) as ABND,					
Sum(a.calloffered - a.callabnd) as CallHandled					
					
from					
					
(					
SELECT					
Convert(varchar(11), TerminationTimestamp,103)	 as Date,				
B.Dialled_No as Telesales_No,					
(Case C.ENTERPRISE_NAME when 'Teles_New_Route_Sales.CT' then 'Option 1'					
					    when 'Teles_New_Route_Cust.CT'  then 'Option 2'
					    when 'Teles_New_Route_OOH.CT'   then 'Out of Hours'
else 'Others' End) as Options,					
Sum(case when a.TimeToAband >0 then '1' else 0 end) as CallAbnd ,					
COUNT(*) as CallOffered					
					
					
  FROM [DataWarehouse].[dbo].[tblSaveICM] A 					
inner join dbo.Telesales_RefData B on [DigitsDialed]=[ICM_No]					
inner join dbo.LKP_ICM_CALL_TYPE C ON A.CALLTYPEID=C.LKP_ICM_CALL_TYPE_ID					
where					
[TerminationTimestamp] BETWEEN '20110901' AND '20111120'					
GROUP BY					
Convert(varchar(11), TerminationTimestamp,103)	,				
B.Dialled_No,					
A.TimeToAband,					
(Case C.ENTERPRISE_NAME when 'Teles_New_Route_Sales.CT' then 'Option 1'					
					    when 'Teles_New_Route_Cust.CT'  then 'Option 2'
					    when 'Teles_New_Route_OOH.CT'   then 'Out of Hours'
else 'Others' End) )as A					
					
where					
a.options <> 'Others'					
group by					
A.Date,					
a.Telesales_No,					
a.options					



SELECT * FROM tblSaveICM A
JOIN Telesales_RefData B ON A.DigitsDialed = B.ICM_No
LEFT OUTER JOIN LKP_ICM_CALL_TYPE C ON A.CALLTYPEID=C.LKP_ICM_CALL_TYPE_ID
WHERE DigitsDialed IN
('5000002000043',
'5000002000046',
'5000002022053',
'5000002044454')
 AND DateTime BETWEEN '11-11-2011 00:00:00' AND '11-11-2011 23:59:59'
AND ICRCallKeyParent IS NULL



SELECT * FROM Telesales_RefData
WHERE Dialled_No IN
('08080000046',
'08080022053',
'08080044454',
'08080000043')
 

SELECT * FROM LKP_ICM_CALL_TYPE WHERE LKP_ICM_CALL_TYPE_ID IN ('23576','23578')