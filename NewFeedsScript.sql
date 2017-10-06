--New code to cope with the multiday Gemini Feeds

DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
SET @StartDate = (SELECT Min(Memo_Date) FROM rep_000802_id_Current)
SET @EndDate = (SELECT Max(Memo_Date) FROM rep_000802_id_Current)
--PRINT @StartDate
--PRINT @EndDate

--Turn the current table into a two day extract
--so the partial day is completed, 
-- then removing all rows and reinserting
IF (DATEDIFF(d,@StartDate,@EndDate)) > 0
BEGIN

UPDATE rep_000802_id_Current
SET ManualIndicator = 'Z'
WHERE Memo_Date = @StartDate

INSERT INTO rep_000802_id_Current
SELECT * FROM rep_000802_History 
WHERE Memo_Date >= @StartDate AND Memo_Date < @EndDate


DELETE FROM rep_000802_History
WHERE Memo_Date BETWEEN @StartDate AND @EndDate

INSERT INTO rep_000802_History
SELECT * FROM rep_000802_id_Current


TRUNCATE TABLE rep_000802_Current
INSERT INTO rep_000802_Current
SELECT BAN, CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time, Memo_Description, Memo_Category, ManualIndicator, Date_Loaded
FROM rep_000802_id_Current WHERE Memo_Date = @EndDate

DELETE FROM rep_00802_id_Current WHERE Memo_Date < @EndDate

END

--Process the information based on yesterdays data only
IF (DATEDIFF(d,@StartDate,@EndDate)) = 0
BEGIN

DELETE FROM rep_000802_History
WHERE Memo_Date = @EndDate

INSERT INTO rep_000802_History
SELECT * FROM rep_000802_id_Current

TRUNCATE TABLE rep_000802_Current
INSERT INTO rep_000802_Current
SELECT BAN, CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time, Memo_Description, Memo_Category, ManualIndicator, Date_Loaded
FROM rep_000802_id_Current WHERE Memo_Date = @EndDate

DELETE FROM rep_00802_id_Current WHERE Memo_Date < @EndDate

END


INSERT INTO rep_000802_History
SELECT BAN, CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time, Memo_Description, Memo_Category, ManualIndicator, NULL, Date_Loaded
FROM rep_000802_History_OldFormat WHERE Memo_Date > '04-30-2009'


DELETE FROM rep_000802_History
WHERE Memo_Date IN (SELECT Memo_Date FROM rep_000802_Current)

INSERT INTO dbo.rep_000802_History
SELECT BAN, CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time, Memo_Description, Memo_Category, ManualIndicator, NULL, Date_Loaded
 FROM dbo.rep_000802_Current