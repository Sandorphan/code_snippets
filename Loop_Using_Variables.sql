DECLARE @MyVal1 INT
DECLARE @MyVal2 INT
DECLARE @MyDate DATETIME


SET @MyVal1 = 1
SET @MyVal2 = 5
SET @MyDate = CAST(Datepart(yyyy,Getdate()) AS char(4)) + '-' +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(m,Getdate()) AS varchar(2)) END + '-' + 
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Getdate()) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Getdate()) AS varchar(2))
	ELSE CAST(Datepart(d,Getdate()) AS varchar(2)) END + ' 00:00:00'


WHILE @MyVal1 < @MyVal2
BEGIN
SELECT * FROM rep_000794_History WHERE Memo_Date =  @MyDate - @MyVal1
SET @MyVal1 = @MyVal1 + 1
END
--CONTINUE


