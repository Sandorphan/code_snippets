SELECT A.ProfileID ,B.ProfileDescription,
CAST(Datepart(d,surveytimestamp) AS VARCHAR(2)) +'-'+ CAST(DateName(month,surveytimestamp) AS VARCHAR(20)), COUNT(CTN), SUM(CASE WHEN Q1 IS NOT NULL THEN 1 ELSE 0 END)
FROM tblSurvey A LEFT OUTER JOIN dbo.tblProfile B
ON A.ProfileID = B.ProfileID
WHERE surveytimestamp > GetDate()-45
GROUP BY A.profileID, B.ProfileDescription,CAST(Datepart(d,surveytimestamp) AS VARCHAR(2)) +'-'+ CAST(DateName(month,surveytimestamp) AS VARCHAR(20))
ORDER BY A.profileID