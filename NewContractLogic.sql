
CREATE TABLE #Rep_000838_Temp (
	[Memo_BAN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Type] [char] (15) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_System_Text] [varchar] (300) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date] [datetime] NULL ,
	[Memo_Time] [varchar] (25) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Serial] [bigint] NULL ,
	[Memo_Description] [varchar] (20) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Category] [char] (255) COLLATE Latin1_General_CI_AS NULL ,
	[Manual_Indicator] [char] (1) COLLATE Latin1_General_CI_AS NULL ,
	[Commitment_Start_Date] [datetime] NULL ,
	[Commitment_End_Date] [datetime] NULL ,
	[Commitment_Reason] [char] (3) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (12) COLLATE Latin1_General_CI_AS NULL,
	[Date_Loaded] [datetime] NOT NULL 
) 

--SR AMENDMENT 16/10/08
--PUT IN SCM DATA FIRST
-- INSERT INTO #Rep_000838_Temp
-- SELECT BAN, CTN, 'COM', OrderUser, 'COM Order', OrderDate, OrderTime, 
-- --The year part
-- CAST(Datepart(yyyy,OrderDate) AS char(4)) +
-- --The month part
-- 	CASE
-- 	WHEN LEN(CAST(Datepart(m,OrderDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,OrderDate) AS varchar(2))
-- 	ELSE CAST(Datepart(m,OrderDate) AS varchar(2)) END +
-- --The day part	
-- CASE
-- 	WHEN LEN(CAST(Datepart(d,OrderDate) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,OrderDate) AS varchar(2))
-- 	ELSE CAST(Datepart(d,OrderDate) AS varchar(2)) END +
-- --The hour part
-- SUBSTRING(OrderTime,1,2) + SUBSTRING(OrderTime,4,2) + SUBSTRING(OrderTime,7,2),
-- 'SVAP','SVAP','N',New_Contract_Start_Date, New_Contract_End_Date, 'COM', DealerCode, Getdate()
-- FROM dbo.tblSCMContractsCurrent
-- WHERE OrderDate = '03-04-2009'
-- AND OrderType = 'Contract Upgrade'


--Put in memos of type 1026, generating a serial number from the date and time.
INSERT INTO #Rep_000838_Temp
SELECT Memo_BAN, Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, memo_Date, Memo_Time,
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END +
--The hour part
SUBSTRING(Memo_Time,1,2) + SUBSTRING(Memo_Time,4,2) + SUBSTRING(Memo_Time,7,2),

Memo_Description, Memo_Category,
Manual_Indicator, 
Commitment_Start_Date, Commitment_End_Date,Commitment_Reason,
Dealer_Code, Date_Loaded
FROM spsvrsql01.mireporting.dbo.rep_000838_current
WHERE Memo_Type = '1026'
AND Memo_CTN NOT IN (SELECT Memo_CTN FROM #Rep_000838_Temp WHERE Memo_CTN IS NOT NULL)
AND Memo_Date = '03-04-2009'


exec dbo.Stp_838_Sys_Text


--Same for the memo type 0011
INSERT INTO #Rep_000838_Temp
SELECT Memo_BAN, Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, memo_Date, Memo_Time,
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END +
--The hour part
SUBSTRING(Memo_Time,1,2) + SUBSTRING(Memo_Time,4,2) + SUBSTRING(Memo_Time,7,2),

Memo_Description, Memo_Category,
Manual_Indicator, 
Commitment_Start_Date, Commitment_End_Date,Commitment_Reason,
Dealer_Code, Date_Loaded
FROM spsvrsql01.mireporting.dbo.rep_000838_current
WHERE Memo_Type = '0011'
AND Memo_CTN NOT IN (SELECT Memo_CTN FROM #Rep_000838_Temp WHERE Memo_CTN IS NOT NULL)
AND Memo_Date = '03-04-2009'

INSERT INTO #Rep_000838_Temp
SELECT Memo_BAN, Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, memo_Date, Memo_Time,
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END +
--The hour part
SUBSTRING(Memo_Time,1,2) + SUBSTRING(Memo_Time,4,2) + SUBSTRING(Memo_Time,7,2),

Memo_Description, Memo_Category,
Manual_Indicator, 
Commitment_Start_Date, Commitment_End_Date,Commitment_Reason,
Dealer_Code, Date_Loaded
FROM spsvrsql01.mireporting.dbo.rep_000838_current
WHERE Memo_Type = '1026'
AND Memo_CTN NOT IN (SELECT Memo_CTN FROM #Rep_000838_Temp WHERE Memo_CTN IS NOT NULL)
AND Memo_Date = '03-04-2009'

--Same for Spice upgrades
INSERT INTO #Rep_000838_Temp
SELECT Memo_BAN, Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, memo_Date, Memo_Time,
--The year part
CAST(Datepart(yyyy,Memo_Date) AS char(4)) +
--The month part
	CASE
	WHEN LEN(CAST(Datepart(m,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(m,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(m,Memo_Date) AS varchar(2)) END +
--The day part	
CASE
	WHEN LEN(CAST(Datepart(d,Memo_Date) AS varchar(2))) = 1 THEN '0' + CAST(Datepart(d,Memo_Date) AS varchar(2))
	ELSE CAST(Datepart(d,Memo_Date) AS varchar(2)) END +
--The hour part
SUBSTRING(Memo_Time,1,2) + SUBSTRING(Memo_Time,4,2) + SUBSTRING(Memo_Time,7,2),

Memo_Description, Memo_Category,
Manual_Indicator, 
Commitment_Start_Date, Commitment_End_Date,Commitment_Reason,
Dealer_Code, Date_Loaded
FROM spsvrsql01.mireporting.dbo.rep_000838_current
WHERE Memo_Type = 'SCUG'
AND Memo_CTN NOT IN (SELECT Memo_CTN FROM #Rep_000838_Temp WHERE Memo_CTN IS NOT NULL)
AND Memo_Date = '03-04-2009'


--Create a table to contain the last record

CREATE TABLE #Rep_000838_Last (
	[Memo_BAN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Serial] [bigint] NULL 
) 


INSERT INTO #Rep_000838_Last
SELECT Memo_BAN, Memo_CTN, MAX(Memo_Serial)
FROM #Rep_000838_Temp
GROUP BY Memo_BAN, Memo_CTN

--Create a final table of unique CTNs from the 838 extract, based on the FINAL activity of the day.

CREATE TABLE #Rep_000838_Final (
	[Memo_BAN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_System_Text] [varchar] (300) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date] [datetime] NULL ,
	[Memo_Time] [varchar] (25) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Description] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Category] [char] (255) COLLATE Latin1_General_CI_AS NULL ,
	[Manual_Indicator] [char] (1) COLLATE Latin1_General_CI_AS NULL ,
	[Commitment_Start_Date] [datetime] NULL ,
	[Commitment_End_Date] [datetime] NULL ,
	[Commitment_Reason] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
	[Date_Loaded] [datetime] NOT NULL,
	[Contract_Type] varchar(50) COLLATE Latin1_General_CI_AS NULL
) 


INSERT INTO #Rep_000838_Final
SELECT A.memo_BAN, A.Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time,
Memo_Description, Memo_Category, Manual_Indicator, Commitment_Start_Date, Commitment_End_Date,
Commitment_Reason, Dealer_Code, Date_Loaded, 'Retention'
FROM   #Rep_000838_Temp A JOIN #Rep_000838_Last B
ON A.Memo_Serial = B.Memo_Serial
AND A.Memo_CTN = B.Memo_CTN
GROUP BY A.memo_BAN, A.Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time,
Memo_Description, Memo_Category, Manual_Indicator, Commitment_Start_Date, Commitment_End_Date,
Commitment_Reason, Dealer_Code, Date_Loaded

----------------------------------------------------------------------------------------------------------------------------------------
--B-Rep_000936 (Contract Table - For SUI Contracts)


CREATE TABLE #Rep_000936_Temp (
	[Memo_BAN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Type] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_System_Text] [varchar] (300) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date] [datetime] NULL ,
	[Memo_Time] [varchar] (25) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Serial] [bigint] NULL ,
	[Memo_Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Category] [char] (255) COLLATE Latin1_General_CI_AS NULL ,
	[Manual_Indicator] [char] (1) COLLATE Latin1_General_CI_AS NULL ,
	[Commitment_Start_Date] [datetime] NULL ,
	[Commitment_End_Date] [datetime] NULL ,
	[Commitment_Reason] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (12) COLLATE Latin1_General_CI_AS NULL,
	[Date_Loaded] [datetime] NOT NULL 
) 

CREATE TABLE #Rep_000936_TempFormat (
	[Memo_BAN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_System_Text] [varchar] (300) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date][varchar] (100) COLLATE Latin1_General_CI_AS NULL , 
	[Memo_Time] [varchar] (25) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Serial] [bigint] NULL ,
	[Memo_Description] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Category] [char] (255) COLLATE Latin1_General_CI_AS NULL ,
	[Manual_Indicator] [char] (1) COLLATE Latin1_General_CI_AS NULL ,
	[Commitment_Start_Date][varchar] (100) COLLATE Latin1_General_CI_AS NULL , 
	[Commitment_End_Date] [varchar] (100) COLLATE Latin1_General_CI_AS NULL , 
	[Commitment_Reason] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (12) COLLATE Latin1_General_CI_AS NULL,
	[Date_Loaded] [datetime] NOT NULL 
) 

INSERT INTO #Rep_000936_TempFormat
SELECT LTrim(RTrim(BAN)), Subscriber_no, Upg_Act, LTrim(RTrim(Operator_ID)), 'SUI Commitment Change', Upg_Date, 
'00:00:00', LTrim(RTrim(Seq_No)), 'SUI Commitment', 'SUI', 'N', New_Com_Start_Date, New_Com_End_Date,
Upg_Rsn, NULL, GetDate()
FROM spsvrsql01.mireporting.dbo.rep_000936_current
WHERE Application_ID NOT IN ('CMMars','Futrx')
AND New_Com_Start_Date IS NOT NULL
AND New_Com_End_Date IS NOT NULL
AND New_Com_Start_Date NOT LIKE ''



INSERT INTO #Rep_000936_Temp
SELECT memo_BAN, memo_CTN, memo_Type, Memo_Agent_ID, Memo_System_Text, 
CAST(CAST(SUBSTRING(Memo_Date,5,2) AS CHAR(2)) + '-' + CAST(SUBSTRING(Memo_Date,7,2) AS CHAR(2)) + '-' + CAST(SUBSTRING(Memo_Date,1,4) AS CHAR(4)) + ' 00:00:00' AS Datetime),
Memo_Time,memo_Serial,Memo_Description, Memo_Category, Manual_Indicator, 
CAST(CAST(SUBSTRING(Commitment_Start_Date,5,2) AS CHAR(2)) + '-' + CAST(SUBSTRING(Commitment_Start_Date,7,2) AS CHAR(2)) + '-' + CAST(SUBSTRING(Commitment_Start_Date,1,4) AS CHAR(4)) + ' 00:00:00' AS Datetime),
CAST(CAST(SUBSTRING(Commitment_End_Date,5,2) AS CHAR(2)) + '-' + CAST(SUBSTRING(Commitment_End_Date,7,2) AS CHAR(2)) + '-' + CAST(SUBSTRING(Commitment_End_Date,1,4) AS CHAR(4)) + ' 00:00:00' AS Datetime),
Commitment_Reason, Dealer_Code, Date_Loaded
FROM #Rep_000936_TempFormat


--Create a table to contain the last record
CREATE TABLE #Rep_000936_Last (
	[Memo_BAN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Serial] [bigint] NULL 
) 


INSERT INTO #Rep_000936_Last
SELECT Memo_BAN, Memo_CTN, MAX(Memo_Serial)
FROM #Rep_000936_Temp
GROUP BY Memo_BAN, Memo_CTN

--Create a final table of unique CTNs from the 936 extract, based on the FINAL activity of the day.
CREATE TABLE #Rep_000936_Final (
	[Memo_BAN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_System_Text] [varchar] (300) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date] [datetime] NULL ,
	[Memo_Time] [varchar] (25) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Description] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Category] [char] (255) COLLATE Latin1_General_CI_AS NULL ,
	[Manual_Indicator] [char] (1) COLLATE Latin1_General_CI_AS NULL ,
	[Commitment_Start_Date] [datetime] NULL ,
	[Commitment_End_Date] [datetime] NULL ,
	[Commitment_Reason] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
	[Date_Loaded] [datetime] NOT NULL,
	[Contract_Type] varchar(50) COLLATE Latin1_General_CI_AS NULL
) 

INSERT INTO #Rep_000936_Final
SELECT A.Memo_BAN, A.Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text,
Memo_Date, Memo_Time, Memo_Description, Memo_Category, Manual_Indicator,
Commitment_Start_Date, Commitment_End_Date, Commitment_Reason,
Dealer_Code, Date_Loaded, 'Retention'
FROM #Rep_000936_Temp A JOIN #Rep_000936_Last B
ON A.Memo_Serial = B.Memo_Serial
AND A.Memo_CTN = B.Memo_CTN
WHERE A.Memo_Date = '03-04-2009'
GROUP BY A.memo_BAN, A.Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time,
Memo_Description, Memo_Category, Manual_Indicator, Commitment_Start_Date, Commitment_End_Date,
Commitment_Reason, Dealer_Code, Date_Loaded


--SECTION TWO - Create Daily Contract Table

TRUNCATE TABLE tbl_Contract_Upgrades_Dev


INSERT INTO tbl_Contract_Upgrades_Dev (BAN, CTN, Dealer_Code, Agent_ID, Order_Date, New_Contract_Start_Date, New_Contract_End_Date)
SELECT Memo_BAN, Memo_CTN, Dealer_Code, Memo_Agent_ID, Memo_Date, Commitment_Start_Date, Commitment_End_Date
FROM #Rep_000838_Final
WHERE Memo_CTN NOT IN (SELECT CTN FROM tbl_Contract_Upgrades_Dev WHERE CTN IS NOT NULL)
AND Memo_Type = 'COM'

INSERT INTO tbl_Contract_Upgrades_Dev (BAN, CTN, Dealer_Code, Agent_ID, Order_Date, New_Contract_Start_Date, New_Contract_End_Date)
SELECT Memo_BAN, Memo_CTN, Dealer_Code, Memo_Agent_ID, Memo_Date, Commitment_Start_Date, Commitment_End_Date
FROM #Rep_000936_Final
WHERE Memo_CTN NOT IN (SELECT CTN FROM tbl_Contract_Upgrades_Dev WHERE CTN IS NOT NULL)

INSERT INTO tbl_Contract_Upgrades_Dev (BAN, CTN, Dealer_Code, Agent_ID, Order_Date, New_Contract_Start_Date, New_Contract_End_Date)
SELECT Memo_BAN, Memo_CTN, Dealer_Code, Memo_Agent_ID, Memo_Date, Commitment_Start_Date, Commitment_End_Date
FROM #Rep_000838_Final
WHERE Memo_CTN NOT IN (SELECT CTN FROM tbl_Contract_Upgrades_Dev WHERE CTN IS NOT NULL)

UPDATE tbl_Contract_Upgrades_Dev
SET Dealer_Code = B.Dealer_Code
FROM tbl_Contract_Upgrades_Dev A JOIN #Rep_000838_Final B
ON A.CTN = B.Memo_CTN AND A.Agent_ID = B.Memo_Agent_ID


UPDATE tbl_Contract_Upgrades_Dev
SET Old_Contract_Start_Date = B.Commitment_Start_Date,
Old_Contract_End_Date = B.Commitment_End_Date,
Connection_Date = B.Connection_Date
FROM tbl_Contract_Upgrades_Dev A JOIN spsvrsql01.mireporting.dbo.rep_000805_previous B
ON A.CTN = B.Subscriber_CTN AND A.BAN = B.BAN


--GROSS CONTRACT PERIOD
UPDATE tbl_Contract_Upgrades_Dev
SET Gross_Contract_Length = DateDiff(m,Order_Date, Dateadd(d,7,New_Contract_End_Date))

UPDATE tbl_Contract_Upgrades_Dev
SET Gross_Contract_Length = 0 WHERE Gross_Contract_Length IS NULL OR Gross_Contract_Length < 0

--NET CONTRACT PERIOD
UPDATE tbl_Contract_Upgrades_Dev
SET Net_Contract_Length = DateDiff(m,Order_Date, Dateadd(d,7,New_Contract_End_Date))
WHERE Order_Date >= Old_Contract_End_Date

UPDATE tbl_Contract_Upgrades_Dev
SET Net_Contract_Length = DateDiff(m,Old_Contract_End_Date, Dateadd(d,7,New_Contract_End_Date))
WHERE Old_Contract_End_Date > Order_Date

UPDATE tbl_Contract_Upgrades_Dev
SET Net_Contract_Length = 0
WHERE Net_Contract_Length IS NULL

--STORE THE LOST MONTHS BEFORE RESETTING NEGATIVE NET PERIODS TO 0

UPDATE tbl_Contract_Upgrades_Dev
SET Lost_Months = Net_Contract_Length
WHERE Net_Contract_Length < 1

UPDATE tbl_Contract_Upgrades_Dev
SET Lost_Months = 0
WHERE Lost_Months =0 OR Lost_Months IS NULL

UPDATE tbl_Contract_Upgrades_Dev
SET Net_Contract_Length = 0
WHERE Net_Contract_Length < 0

UPDATE tbl_Contract_Upgrades_Dev
SET ResetType = 'None' WHERE Net_Contract_Length > 0

UPDATE tbl_Contract_Upgrades_Dev
SET ResetType = '14Day' WHERE Old_Contract_Start_Date BETWEEN Dateadd(d,-14, Order_Date)AND Order_Date
AND ResetType IS NULL

UPDATE tbl_Contract_Upgrades_Dev
SET ResetType = 'MidTerm' WHERE Old_Contract_Start_Date < Dateadd(d,-14, Order_Date)
AND ResetType IS NULL

UPDATE tbl_Contract_Upgrades_Dev
SET ResetType = 'Future' WHERE ResetType IS NULL
