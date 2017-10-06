DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
DECLARE @TDate DATETIME

SET @TDate = 
CAST(CAST(CAST(DATEPART(d,GetDate()) AS VARCHAR(2)) + '/' 
+ CAST(DATEPART(m,GetDate()) AS VARCHAR(2)) + '/' 
+ CAST(DATEPART(yyyy,GetDate()) AS VARCHAR(4)) + ' 00:00:00' AS VARCHAR(19)) AS DATETIME)

SELECT A.ProfileID,B.ProfileDescription, 
Datepart(hh,surveytimestamp), 
--Volume of Surveys
COUNT(CTN) AS VolumeSurveys,
--Volume of Replies
SUM(CASE WHEN Q1 IS NOT NULL THEN 1 ELSE 0 END) AS VolumeResponses,
--Sum of Q1 Replies
SUM(CASE WHEN Q1 IS NOT NULL THEN Q1 ELSE 0 END) AS TotalQ1Score,
--Sum of Q2 Replies
SUM(CASE WHEN Q2 IS NOT NULL THEN Q2 ELSE 0 END) AS TotalQ2Score,
--Sum of Q3 Replies
SUM(CASE WHEN Q3 IS NOT NULL THEN Q3 ELSE 0 END) AS TotalQ3Score,
--Sum of Q4 Replies
SUM(CASE WHEN Q4 IS NOT NULL THEN Q4 ELSE 0 END) AS TotalQ4Score,
--Sum of Q5 Replies
SUM(CASE WHEN Q5 IS NOT NULL THEN Q5 ELSE 0 END) AS TotalQ5Score,
--Sum of Q6 Replies
SUM(CASE WHEN Q6 IS NOT NULL THEN Q6 ELSE 0 END) AS TotalQ6Score,
--Sum of Q7 Replies
SUM(CASE WHEN Q7 IS NOT NULL THEN Q7 ELSE 0 END) AS TotalQ7Score,
--Sum of Q8 Replies
SUM(CASE WHEN Q8 IS NOT NULL THEN Q8 ELSE 0 END) AS TotalQ8Score,
--Sum of Q9 Replies
SUM(CASE WHEN Q9 IS NOT NULL THEN Q9 ELSE 0 END) AS TotalQ9Score,
--Sum of Q10 Replies
SUM(CASE WHEN Q10 IS NOT NULL THEN Q10 ELSE 0 END) AS TotalQ10Score

FROM tblSurvey A LEFT OUTER JOIN dbo.tblProfile B
ON A.ProfileID = B.ProfileID
WHERE surveytimestamp > @TDate
GROUP BY A.profileID, B.ProfileDescription,Datepart(hh,surveytimestamp)
ORDER BY A.profileID,Datepart(hh,surveytimestamp)

