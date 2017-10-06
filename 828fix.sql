insert into mireporting.dbo.rep_000828_current
select BAN, Operator_ID,
MIReporting.dbo.ConvBillDate(Sys_Creation_Date), '00:00:00',
'Temp', Subscriber_No,
'Gemini Fail Fix','Gemini Fail Fix',
'A', 'N', 'Unknown','01-01-2011','05-25-2012',
0, SOC, A.Effective_Date, Expiration_Date,
B.Rate, NULL, GetDate()
 from dbo.tbl_Service_Agreement_TempFormat A JOIN MIReferenceTables.dbo.tblSOCReference B
ON A.SOC = B.SOC_Code where A.service_type = 'p'
AND A.Subscriber_No IN (SELECT Subscriber_No FROM MIReporting.dbo.rep_000805_Current WHERE Connection_Date < '05-25-2012')
AND Sys_Creation_Date = '25-MAY-12'

INSERT INTO rep_000828_History
SELECT * FROM rep_000828_Current

SELECT * FROM mireporting.dbo.rep_000828_current