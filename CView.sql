SELECT 
CAST(Datepart(yyyy,SurveyTimestamp) AS char(4)) + '-' +
--The month part
	CASE
 	WHEN LEN(CAST(Datepart(m,SurveyTimestamp) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,SurveyTimestamp) AS varchar(2))
 	ELSE CAST(Datepart(m,SurveyTimestamp) AS varchar(2)) END + '-' +
 --The day part	
 CASE
 	WHEN LEN(CAST(Datepart(d,SurveyTimestamp) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,SurveyTimestamp) AS varchar(2))
 	ELSE CAST(Datepart(d,SurveyTimestamp) AS varchar(2)) END,
B.Name, B.TM, B.CCM, B.Site, B.Department, B.Reporting_Function, B.Channel, B.Business_Unit,
SUM(CASE WHEN Q3 IS NULL THEN 0 ELSE 1 END) AS TotSurveys,
SUM(CASE WHEN Q3 =1 THEN 1 ELSE 0 END) AS SurvAns1,
SUM(CASE WHEN Q3 =2 THEN 1 ELSE 0 END) AS SurvAns2,
SUM(CASE WHEN Q3 =3 THEN 1 ELSE 0 END) AS SurvAns3,
SUM(CASE WHEN Q3 =4 THEN 1 ELSE 0 END) AS SurvAns4,
SUM(CASE WHEN Q3 =5 THEN 1 ELSE 0 END) AS SurvAns5,
SUM(CASE WHEN Q3 =6 THEN 1 ELSE 0 END) AS SurvAns6,
SUM(CASE WHEN Q3 =7 THEN 1 ELSE 0 END) AS SurvAns7,
SUM(CASE WHEN Q3 =8 THEN 1 ELSE 0 END) AS SurvAns8,
SUM(CASE WHEN Q3 =9 THEN 1 ELSE 0 END) AS SurvAns9,
SUM(CASE WHEN Q3 =10 THEN 1 ELSE 0 END) AS SurvAns10
  FROM dbo.tblSurvey A
JOIN [Regapp053\UKRC_Prod].MIReferenceTables.dbo.tbl_Agents B
ON A.PersonID = B.Switch_ID
WHERE B.Channel = 'Call Centre - Sales'
AND Q3 IS NOT NULL
GROUP BY 
CAST(Datepart(yyyy,SurveyTimestamp) AS char(4)) + '-' +
--The month part
	CASE
 	WHEN LEN(CAST(Datepart(m,SurveyTimestamp) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,SurveyTimestamp) AS varchar(2))
 	ELSE CAST(Datepart(m,SurveyTimestamp) AS varchar(2)) END + '-' +
 --The day part	
 CASE
 	WHEN LEN(CAST(Datepart(d,SurveyTimestamp) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,SurveyTimestamp) AS varchar(2))
 	ELSE CAST(Datepart(d,SurveyTimestamp) AS varchar(2)) END,
B.Name, B.TM, B.CCM, B.Site, B.Department, B.Reporting_Function, B.Channel, B.Business_Unit