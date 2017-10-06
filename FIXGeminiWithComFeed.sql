DECLARE @OrderDate AS DATETIME
SET @OrderDate = '12-22-2008'

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
-- WHERE OrderDate = @OrderDate
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
AND Memo_Date = @OrderDate


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
AND Memo_Date = @OrderDate

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
AND Memo_Date = @OrderDate

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
AND Memo_Date = @OrderDate


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
WHERE A.Memo_Date = @OrderDate
GROUP BY A.memo_BAN, A.Memo_CTN, Memo_Type, Memo_Agent_ID, Memo_System_Text, Memo_Date, Memo_Time,
Memo_Description, Memo_Category, Manual_Indicator, Commitment_Start_Date, Commitment_End_Date,
Commitment_Reason, Dealer_Code, Date_Loaded


--SECTION TWO - Create Daily Contract Table

TRUNCATE TABLE tbl_Contract_Upgrades_Test


INSERT INTO tbl_Contract_Upgrades_Test (BAN, CTN, Dealer_Code, Agent_ID, Order_Date, New_Contract_Start_Date, New_Contract_End_Date)
SELECT Memo_BAN, Memo_CTN, Dealer_Code, Memo_Agent_ID, Memo_Date, Commitment_Start_Date, Commitment_End_Date
FROM #Rep_000838_Final
WHERE Memo_CTN NOT IN (SELECT CTN FROM tbl_Contract_Upgrades_Test WHERE CTN IS NOT NULL)
AND Memo_Type = 'COM'

INSERT INTO tbl_Contract_Upgrades_Test (BAN, CTN, Dealer_Code, Agent_ID, Order_Date, New_Contract_Start_Date, New_Contract_End_Date)
SELECT Memo_BAN, Memo_CTN, Dealer_Code, Memo_Agent_ID, Memo_Date, Commitment_Start_Date, Commitment_End_Date
FROM #Rep_000936_Final
WHERE Memo_CTN NOT IN (SELECT CTN FROM tbl_Contract_Upgrades_Test WHERE CTN IS NOT NULL)

INSERT INTO tbl_Contract_Upgrades_Test (BAN, CTN, Dealer_Code, Agent_ID, Order_Date, New_Contract_Start_Date, New_Contract_End_Date)
SELECT Memo_BAN, Memo_CTN, Dealer_Code, Memo_Agent_ID, Memo_Date, Commitment_Start_Date, Commitment_End_Date
FROM #Rep_000838_Final
WHERE Memo_CTN NOT IN (SELECT CTN FROM tbl_Contract_Upgrades_Test WHERE CTN IS NOT NULL)

UPDATE tbl_Contract_Upgrades_Test
SET Dealer_Code = B.Dealer_Code
FROM tbl_Contract_Upgrades_Test A JOIN #Rep_000838_Final B
ON A.CTN = B.Memo_CTN AND A.Agent_ID = B.Memo_Agent_ID


UPDATE tbl_Contract_Upgrades_Test
SET Old_Contract_Start_Date = B.Commitment_Start_Date,
Old_Contract_End_Date = B.Commitment_End_Date,
Connection_Date = B.Connection_Date
FROM tbl_Contract_Upgrades_Test A JOIN spsvrsql01.mireporting.dbo.rep_000805_previous B
ON A.CTN = B.Subscriber_CTN AND A.BAN = B.BAN


--Gross Period - Straight calc on the new dates where the new start date is today or in the future
UPDATE tbl_Contract_Upgrades_Test
SET Gross_Contract_Length = DateDiff(m,New_Contract_Start_Date, dateadd(day,5,New_Contract_End_Date))
WHERE New_Contract_Start_Date >= Order_Date


--Gross Period - Straight calc on the new dates where the new start date is historical
UPDATE tbl_Contract_Upgrades_Test
SET Gross_Contract_Length = DateDiff(m,Order_Date, dateadd(day,5,New_Contract_End_Date))
WHERE New_Contract_Start_Date < Order_Date

-- 
--Gross Period - Disallow reset of contract period where start date is historical


UPDATE tbl_Contract_Upgrades_Test
SET Gross_Contract_Length = 0
WHERE (New_Contract_Start_Date <> Old_Contract_Start_Date
AND New_Contract_Start_Date < dateadd(day,-7,Order_Date))
OR Gross_Contract_Length IS NULL
OR Gross_Contract_Length < 0






--Net Period - Criteria 1 - Based where the ORDER DATE and START date are the same and the NEW START is >= OLD END
UPDATE tbl_Contract_Upgrades_Test
SET Net_Contract_Length = DateDiff(m,New_Contract_Start_Date, DateAdd(day,5,New_Contract_End_Date))
--WHERE Order_Date = New_Contract_Start_Date **Amended 29/1 Rob H to handle SUI fails
WHERE New_Contract_Start_Date between dateadd(day,-7,order_date) and order_date

--Net Period - Criteria 2 - Based on the difference between the OLD END date where it is greater than the NEW START
UPDATE tbl_Contract_Upgrades_Test
SET Net_Contract_Length = Datediff(m,Old_Contract_End_Date,Dateadd(day,5,New_Contract_End_Date))
WHERE Old_Contract_End_Date > New_Contract_Start_Date
--AND New_Contract_Start_Date = Old_Contract_Start_Date

--Net Period - Criteria 2a - Based on the difference between the OLD END date where it is greater than the NEW START
--For Contract Resets
UPDATE tbl_Contract_Upgrades_Test
SET Net_Contract_Length = Datediff(m,Old_Contract_End_Date,Dateadd(day,5,New_Contract_End_Date))
WHERE Old_Contract_End_Date > New_Contract_Start_Date
AND New_Contract_Start_Date = Old_Contract_Start_Date

--Net Period - Criteria 3 - Based on the difference between the ORDER DATE where it is less than the NEW START
UPDATE tbl_Contract_Upgrades_Test
SET Net_Contract_Length = Datediff(m,New_Contract_Start_Date,Dateadd(day,5,New_Contract_End_Date))
WHERE Order_Date < New_Contract_Start_Date


--Net Period - Criteria 4 - Based on the difference between the OLD END and NEW END where a future START (SIM Change fixes)
UPDATE tbl_Contract_Upgrades_Test
SET Net_Contract_Length = Datediff(m,New_Contract_End_Date,Old_Contract_End_Date)
WHERE New_Contract_End_Date = Old_Contract_End_Date

--Net Period - Disallow contracts that have been reset
UPDATE tbl_Contract_Upgrades_Test
SET Net_Contract_Length = 0
WHERE  (New_Contract_Start_Date <> Old_Contract_Start_Date
AND New_Contract_Start_Date < dateadd(day,-7,Order_Date))
OR Net_Contract_Length IS NULL
or net_contract_length < 0

--Final Update to Fix RESETS and other commitment activity that doesn't change any dates
UPDATE tbl_Contract_Upgrades_Test
SET Gross_Contract_Length = 0,
Net_Contract_Length = 0
WHERE New_Contract_Start_Date = Old_Contract_Start_Date
AND New_Contract_End_Date = Old_Contract_End_Date



UPDATE tbl_Contract_Upgrades_Test
SET Contract_Type = 'Retention'


--SECTION B - New Connection Contracts

CREATE TABLE #RecentAcquisitions (
	[BAN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[CTN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Order_Date] [datetime] NULL ,
	[Order_Serial] varchar (50) NULL,
	[New_Contract_Start_Date] [datetime] NULL ,
	[New_Contract_End_Date] [datetime] NULL ,
	[Old_Contract_Start_Date] [datetime] NULL ,
	[Old_Contract_End_Date] [datetime] NULL ,
	[Connection_Date] [datetime] NULL ,
	[Gross_Contract_Length] [int] NULL ,
	[Net_Contract_Length] [int] NULL ,
	[Contract_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL 
) 



--SR AMENDMENT 16/10/08
--PUT IN SCM DATA FIRST
-- INSERT INTO #RecentAcquisitions
-- SELECT BAN, CTN, DealerCode, OrderUser, OrderDate,
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
-- ISNULL(New_Contract_Start_Date,OrderDate), ISNULL(New_Contract_End_Date,DATEADD(m,Gross_Contract_Period,OrderDate)), NULL, NULL, Connection_Date, Datediff(m,ISNULL(New_Contract_Start_Date,OrderDate),Dateadd(d,5,ISNULL(New_Contract_End_Date,DATEADD(m,Gross_Contract_Period,OrderDate)))), Datediff(m,ISNULL(New_Contract_Start_Date,OrderDate),Dateadd(d,5,ISNULL(New_Contract_End_Date,DATEADD(m,Gross_Contract_Period,OrderDate)))), 'Acquisition'
-- FROM dbo.tblSCMContractsHistory
-- WHERE OrderDate > DateAdd(d,-30,@OrderDate)
-- AND OrderType = 'Contract'





INSERT INTO #RecentAcquisitions
SELECT Memo_Ban, Memo_CTN, Connection_Channel, memo_Agent_ID, Memo_Date,
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
Commitment_Start_Date, Commitment_End_Date, NULL, NULL, Commitment_Start_Date,
DateDiff(m,Commitment_Start_date, Dateadd(day,5,Commitment_End_Date)), DateDiff(m,Commitment_Start_Date, Dateadd(day,5,Commitment_End_Date)),
'Acquisition'
FROM spsvrsql01.mireporting.dbo.rep_000870_History
WHERE Memo_Date > DateAdd(d,-30,@OrderDate)--@OrderDate
AND Memo_CTN NOT IN (SELECT CTN FROM #RecentAcquisitions WHERE CTN IS NOT NULL)
GROUP BY Memo_Ban, Memo_CTN, Connection_Channel, memo_Agent_ID, Memo_Date,
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
Commitment_Start_Date, Commitment_End_Date, Commitment_Start_Date,
DateDiff(m,Commitment_Start_date, Dateadd(day,5,Commitment_End_Date)), DateDiff(m,Commitment_Start_Date, Dateadd(day,5,Commitment_End_Date))


INSERT INTO #RecentAcquisitions
SELECT Memo_Ban, Memo_CTN, Connection_Channel, memo_Agent_ID, Memo_Date,
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
Commitment_Start_Date, Commitment_End_Date, NULL, NULL, Commitment_Start_Date,
DateDiff(m,Commitment_Start_date, Dateadd(day,5,Commitment_End_Date)), DateDiff(m,Commitment_Start_Date,Dateadd(day,5,Commitment_End_Date)),
'Acquisition'
FROM spsvrsql01.mireporting.dbo.rep_000888_TempImport
WHERE Memo_CTN NOT IN (SELECT CTN FROM #RecentAcquisitions WHERE CTN IS NOT NULL)
AND Memo_Date > DateAdd(d,-30,@OrderDate)--@OrderDate
AND Memo_Agent_ID is not null

CREATE TABLE #LastAcq (
	[Memo_BAN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Serial] [bigint] NULL 
) 

INSERT INTO #LastAcq
SELECT BAN, CTN, MAX(Order_Serial)
FROM #RecentAcquisitions
GROUP BY BAN, CTN

/*
SELECT * from #recentacquisitions
Where Order_serial like '%:%'
*/


DELETE FROM #RecentAcquisitions
WHERE Order_Serial NOT IN (SELECT Memo_Serial FROM #LastAcq)

DELETE FROM tbl_Contract_Upgrades_Test
WHERE CTN IN (SELECT CTN FROM #RecentAcquisitions)

INSERT INTO tbl_Contract_Upgrades_Test
SELECT 
[BAN] ,
[CTN],
[Dealer_Code],
[Agent_ID] ,
[Order_Date] ,
[New_Contract_Start_Date],
[New_Contract_End_Date],
[Old_Contract_Start_Date],
[Old_Contract_End_Date],
[Connection_Date],
[Gross_Contract_Length],
[Net_Contract_Length],
[Contract_Type]
 FROM #RecentAcquisitions
WHERE Order_Date = @OrderDate
GROUP BY BAN,CTN,Dealer_Code,Agent_ID,Order_Date,New_Contract_Start_Date,
New_Contract_End_Date,Old_Contract_Start_Date,Old_Contract_End_Date,
Connection_Date,Gross_Contract_Length,Net_Contract_Length,Contract_Type




--GROUP BY BAN,CTN,Dealer_Code,Agent_ID,Order_Date,New_Contract_Start_Date,
--New_Contract_End_Date,Old_Contract_Start_Date,Old_Contract_End_Date,
--Connection_Date,Gross_Contract_Length,Net_Contract_Length,Contract_Type

--Fix to update the records that were generated from COM to update the system login to the COM user
CREATE TABLE #TempCOMFix (
BAN VARCHAR(100),
CTN VARCHAR(100),
Dealer_Code VARCHAR (100),
Agent_ID VARCHAR(100),
OrderCreator VARCHAR(100),
OrderDealer VARCHAR(100),
OrderStatus VARCHAR(100),
OrderRef VARCHAR(100) )

INSERT INTO #TempCOMFix
SELECT A.BAN, A.CTN, Dealer_Code, Agent_ID, OrderCreator, DealerCode, OrderStatus, OrderNumber
FROM tbl_Contract_Upgrades_Test A JOIN tblSCMOrderHeaderAllHistory B
ON A.CTN = B.CTN AND A.BAN = B.BAN
AND A.Order_Date = B.DateLastModified
WHERE OrderStatus IN (SELECT OrderStatus FROM dbo.tblSCMOrderStatus WHERE ValidOrder = 'True')

INSERT INTO #TempCOMFix
SELECT A.BAN, A.CTN, Dealer_Code, Agent_ID, OrderCreator, DealerCode, OrderStatus, OrderNumber
FROM tbl_Contract_Upgrades_Test A JOIN tblSCMOrderHeaderAllHistory B
ON A.CTN = B.CTN AND A.BAN = B.BAN
AND A.Order_Date = B.DateLastModified
WHERE OrderStatus IN (SELECT OrderStatus FROM dbo.tblSCMOrderStatus WHERE ValidOrder = 'False')
AND A.CTN NOT IN (SELECT CTN FROM #TempCOMFix)


CREATE TABLE #TempCOMFixFinal(
BAN VARCHAR(100),
CTN VARCHAR(100),
Dealer_Code VARCHAR (100),
Agent_ID VARCHAR(100),
OrderCreator VARCHAR(100),
OrderDealer VARCHAR(100),
OrderStatus VARCHAR(100),
OrderRef VARCHAR(100) )

INSERT INTO #TempCOMFixFinal
SELECT A.BAN, A.CTN, A.Dealer_Code, A.Agent_ID, A.OrderCreator, A.OrderDealer, A.OrderStatus, A.OrderRef
FROM #TempCOMFix A JOIN (SELECT BAN, CTN, Min(OrderRef) AS FirstOrder FROM #TempCOMFix GROUP BY BAN, CTN) B
ON A.OrderRef = B.FirstOrder

SELECT * FROm #TempCOMFixFinal

UPDATE tbl_Contract_Upgrades_Test
SET Agent_ID = OrderCreator,
Dealer_Code = OrderDealer
FROM tbl_Contract_Upgrades_Test A JOIN #TempCOMFixFinal B
ON A.CTN = B.CTN AND A.BAN = B.BAN

SELECT * FROM tbl_Contract_Upgrades_Test A 
LEFT OUTER JOIN tblSCMHandsetsNewFeed B ON A.CTN = B.CTN AND A.Order_Date = B.OrderDate
WHERE Contract_Type = 'Acquisition'

