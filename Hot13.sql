CREATE TABLE tblinSpireHandsetIncentives (
OrderDate DATETIME,
OrderWeek VARCHAR(100),
OrderMonth VARCHAR(100),
Agent VARCHAR(100),
Team VARCHAR(100),
CCM VARCHAR(100),
Site VARCHAR(100),
Department VARCHAR(100),
RepFunction VARCHAR(100),
Channel VARCHAR(100),
BusinessUnit VARCHAR(100),
HandsetSales INT,
HandsetPreOrders INT,
Device1Sales INT,
Device1PreOrder INT,
Device2Sales INT,
Device2PreOrder INT,
Device3Sales INT,
Device3PreOrder INT,
Device4Sales INT,
Device4PreOrder INT,
Device5Sales INT,
Device5PreOrder INT,
Device6Sales INT,
Device6PreOrder INT,
Device7Sales INT,
Device7PreOrder INT,
Device8Sales INT,
Device8PreOrder INT,
Device9Sales INT,
Device9PreOrder INT,
Device10Sales INT,
Device10PreOrder INT,
Device11Sales INT,
Device11PreOrder INT,
Device12Sales INT,
Device12PreOrder INT,
Device13Sales INT,
Device13PreOrder INT,
Device14Sales INT,
Device14PreOrder INT,
Device15Sales INT,
Device15PreOrder INT )

TRUNCATE TABLE tblinSpireHandsetIncentives
INSERT INTO tblinSpireHandsetIncentives
SELECT OrderDate, OrderWeek, OrderMonth, Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit,
--Handset
SUM(Volume), 0,
--IPhone4 16Gb
SUM(CASE WHEN ProductCode IN ('069776', '069777') THEN Volume ELSE 0 END), 0,
--IPhone3GS 8Gb
SUM(CASE WHEN ProductCode IN ('069775') THEN Volume ELSE 0 END), 0,
--BBTorch 9800
SUM(CASE WHEN ProductCode IN ('070074', '071236') THEN Volume ELSE 0 END), 0,
--HTC Sensation
SUM(CASE WHEN ProductCode IN ('070921') THEN Volume ELSE 0 END), 0,
--SE Xperia Arc
SUM(CASE WHEN ProductCode IN ('070582') THEN Volume ELSE 0 END), 0,
--HTC Cha Cha
SUM(CASE WHEN ProductCode IN ('070898', '072636') THEN Volume ELSE 0 END), 0,
--BB Bold 9780
SUM(CASE WHEN ProductCode IN ('070071', '070350') THEN Volume ELSE 0 END), 0,
--SGH Galaxy Ace
SUM(CASE WHEN ProductCode IN ('072037') THEN Volume ELSE 0 END), 0,
--HTC Wildfire S
SUM(CASE WHEN ProductCode IN ('071636', '071642', '070924') THEN Volume ELSE 0 END), 0,
--BB Cure 9300
SUM(CASE WHEN ProductCode IN ('069921', '069924') THEN Volume ELSE 0 END), 0,
--BB Curve 8520
SUM(CASE WHEN ProductCode IN ('067308', '067319', '070199', '070051', '070054') THEN Volume ELSE 0 END), 0,
--Nokia 6303i
SUM(CASE WHEN ProductCode IN ('068710') THEN Volume ELSE 0 END), 0,
--Nokia C3
SUM(CASE WHEN ProductCode IN ('069722', '069724') THEN Volume ELSE 0 END), 0,
--Device 14
0,0,
--Device 15
0,0
FROM dbo.tblInspireHandsetsHistory
WHERE Department IN ('Customer Retention','Outbound Retention')
AND OrderDate > '06-30-2011'
AND OrderType = 'Retention'
GROUP BY OrderDate, OrderWeek, OrderMonth, Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit


UPDATE tblinSpireHandsetIncentives
SET HandsetPreOrders = B.DeviceSales,
Device1PreOrder = B.Device1Sales,
Device2PreOrder = B.Device2Sales,
Device3PreOrder = B.Device3Sales,
Device4PreOrder = B.Device4Sales,
Device5PreOrder = B.Device5Sales,
Device6PreOrder = B.Device6Sales,
Device7PreOrder = B.Device7Sales,
Device8PreOrder = B.Device8Sales,
Device9PreOrder = B.Device9Sales,
Device10PreOrder = B.Device10Sales,
Device11PreOrder = B.Device11Sales,
Device12PreOrder = B.Device12Sales,
Device13PreOrder = B.Device13Sales
FROM tblinSpireHandsetIncentives A JOIN MIReporting.dbo.vwPreOrderSummary B
ON A.Agent = B.Name AND A.Team = B.TM AND A.OrderDate = B.DateCreated

SELECT * FROm tblinSpireHandsetIncentives

SELECT * FROM MIReporting.dbo.NEW_Handset_Table WHERE Product_Type = 'Contract handsets'
ORDER BY Handset_Generic

iPhone 4 16GB - 69776, 69777
iPhone 3GS 8Gb - 69775
BB Torch 9800 - 70074, 71236
HTC Sensation - 70921
SE Xperia Arc - 70582
HTC Cha Cha - 70898, 72636
BB Bold 9780 - 70071, 70350
SGH Galaxy Ace - 72037
HTC Wildfire S - 71636, 71642, 70924
BB Cure 9300 - 69921, 69924
BB Curve 8520 - 67308, 67319, 70199, 70051, 70054 Nokia 6303i - 68710 Nokia C3 - 69722, 69724 

