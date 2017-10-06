USE [MIStandardMetrics]
GO
/****** Object:  StoredProcedure [dbo].[spHot13Incentive]    Script Date: 10/31/2011 10:58:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spHot13Incentive] AS

-- Septembers Incentive

TRUNCATE TABLE tblinSpireHandsetIncentives

INSERT INTO tblinSpireHandsetIncentives
SELECT OrderDate, OrderWeek, OrderMonth, Agent, Team, CCM, Site, Department, RFunction, Channel, BusinessUnit,
--Handset
SUM(Volume), 0,
--Samsung Eisen
SUM(CASE WHEN ProductCode IN ('072708') THEN Volume ELSE 0 END), 0,
--Nokia 6303i
SUM(CASE WHEN ProductCode IN ('068710') THEN Volume ELSE 0 END), 0,
--Voda Smart
SUM(CASE WHEN ProductCode IN ('072894') THEN Volume ELSE 0 END), 0,
--Blackberry 8520
SUM(CASE WHEN ProductCode IN ('067308','070199') THEN Volume ELSE 0 END), 0,
--HTC Explorer
SUM(CASE WHEN ProductCode IN ('072716') THEN Volume ELSE 0 END), 0,
--HTC WILDFIRE
SUM(CASE WHEN ProductCode IN ('070924','071636','071642') THEN Volume ELSE 0 END), 0,
--BB CURVE 9300
SUM(CASE WHEN ProductCode IN ('069921','069924') THEN Volume ELSE 0 END), 0,
--SS GALAXY ACE
SUM(CASE WHEN ProductCode IN ('070660') THEN Volume ELSE 0 END), 0,
--SONY ERICSSON RAY
SUM(CASE WHEN ProductCode IN ('072077') THEN Volume ELSE 0 END), 0,
--BLACKBERRY 9360
SUM(CASE WHEN ProductCode IN ('071721') THEN Volume ELSE 0 END), 0,
--GALAXY SII
SUM(CASE WHEN ProductCode IN ('070652','073030') THEN Volume ELSE 0 END), 0,
--NOKIA 800
SUM(CASE WHEN ProductCode IN ('072727') THEN Volume ELSE 0 END), 0,
--DEVICE 13
0, 0,
--DEVICE 14
0, 0,
--Device 15
0,0
FROM dbo.tblInspireHandsetsHistory
WHERE Department IN ('Customer Retention','Outbound Retention')
AND OrderDate > '07-31-2011'
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
Device13PreOrder = B.Device13Sales,
Device14PreOrder = B.Device14Sales
FROM tblinSpireHandsetIncentives A JOIN MIReporting.dbo.vwPreOrderSummary B
ON A.Agent = B.Name AND A.Team = B.TM AND A.OrderDate = B.DateCreated

TRUNCATE TABLE MIOutputs.dbo.tblinSpireHandsetIncentives

INSERT INTO  MIOutputs.dbo.tblinSpireHandsetIncentives
SELECT * FROM  MIStandardMetrics.dbo.tblinSpireHandsetIncentives



/*
-- Julys Incentive 
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

TRUNCATE TABLE MIOutputs.dbo.tblinSpireHandsetIncentives

INSERT INTO  MIOutputs.dbo.tblinSpireHandsetIncentives
SELECT * FROM  MIStandardMetrics.dbo.tblinSpireHandsetIncentives
*/

