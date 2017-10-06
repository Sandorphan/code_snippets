DECLARE @MyVal1 INT
DECLARE @MyVal2 INT
DECLARE @MyDate DATETIME
DECLARE @MyProcessDate DATETIME


SET @MyVal1 = 0 
SET @MyVal2 = 8
SET @MyDate = '07-08-2006'


WHILE @MyVal1 < @MyVal2
BEGIN
SET @MyProcessDate = (@MyDate - @MyVal1) 
EXEC dbo.SP_Txn_Table_History   @MyProcessDate
--Print @MyProcessDate
SET @MyVal1 = @MyVal1 + 1
END
