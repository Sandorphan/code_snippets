CREATE TABLE #temp (
            spid int,
            status varchar(256),
            loginname varchar(256),
            hostname varchar(256),
            blkby varchar(256),
            dbname varchar(256),
            command varchar(256),
			cputime int,
			diskio int,
			lastbatch varchar(20),
			programName varchar(256),
			spid2 int,
			requestid int) 

INSERT INTO #temp
EXECUTE sp_who2 

ALTER TABLE #temp
ADD lastbatchtime varchar(50)

UPDATE #temp
SET lastbatchtime =
SUBSTRING(lastbatch,1,2) + '-' +
SUBSTRING(lastbatch,4,2) + '-' +
CAST(Datepart(YEAR,GetDate()) AS VARCHAR(4)) + ' ' +
SUBSTRING(lastbatch,7,8)

ALTER TABLE #temp
ALTER COLUMN lastbatchtime datetime

DELETE FROM #Temp WHERE spid < 49
DELETE FROM #Temp WHERE loginname IN ('VF-UK\SQLDBAAdminStoke')

SELECT * FROM #temp


DECLARE kill_spids CURSOR FOR
--Add a WHERE clause here to indicate which processes to kill.
SELECT spid
FROM #temp
WHERE lastbatchtime < DateAdd(minute, -180,GetDate())


DECLARE @spid SMALLINT

OPEN kill_spids

FETCH NEXT FROM kill_spids INTO @spid

WHILE @@FETCH_STATUS = 0

BEGIN 

            DECLARE @dynamicsql NVARCHAR(4000)
            SET @dynamicsql = 'KILL '+CAST(@spid AS CHAR)
            PRINT @dynamicsql
            --When you are sure you know what you're doing, un-comment this line
            --EXECUTE sp_executesql @dynamicsql
            FETCH NEXT FROM kill_spids INTO @spid

END

CLOSE kill_spids
DEALLOCATE kill_spids
DROP TABLE #temp

EXEC stats_sp