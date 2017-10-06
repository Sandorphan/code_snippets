CREATE PROCEDURE spSOCTables AS


/*---------------------SOC REFERENCE TABLES----------------------
Downloaded SOC information from Gemini and support information gathered 
using logic and group information

Initially this uses an existing table created as part of an old routine called tblSOCReference, which
was the previous incarnation of this project. Tables are being normalised for ease of maintenence

Main Table is tblSOC, which is a basic download of all active SOC codes and descriptions
tblSOC_Attributes is a list of SOCs and included attributes (eg meal deals, where a CTR price plan also includes VMI and MusicStation)
tblSOC_Costs is a list of SOCs and associated Commercial and Benchmark Costs 
tblSOC_Groupings is a list of SOCs and their associated groupings (eg Anytime, Business)
tblSOC_Details is a list of SOCs and any other relevent information (wholesale rates, network tariff) where available

Data structure and code implementation by Simon Robinson February 2008

REVISION HISTORY:
============
* 

RELEASE NOTES:
==========
*                                                            
*
*

*/
TRUNCATE TABLE tblSOC
INSERT INTO tblSOC (SOC_Code, SOC_Description, SOC_Type)
SELECT SOC_Code, SOC_Description, SOC_Type FROM tblSOCReference

SELECT * FROM tblSOC WHERE SOC_Description LIKE 'CTR2%'

-- Routine to create attributes table for each SOC code
TRUNCATE TABLE tblSOC_Attributes

INSERT INTO tblSOC_Attributes (SOC_Code, SOC_Description, SOC_Type)
SELECT SOC_Code, SOC_Description, SOC_Type FROM tblSOCReference

--Attribute 1 - CTR
UPDATE tblSOC_Attributes
SET SOC_Attr_1 = 'Y'
WHERE SOC_Description LIKE '%CTRA%'

UPDATE tblSOC_Attributes
SET SOC_Attr_1 = 'N'
WHERE SOC_Attr_1 IS NULL

--Attribute 2 - CTR2
UPDATE tblSOC_Attributes
SET SOC_Attr_2 = 'Y'
WHERE SOC_Description LIKE '%CTR2%'

UPDATE tblSOC_Attributes
SET SOC_Attr_2 = 'N'
WHERE SOC_Attr_2 IS NULL



--Attribute 4 - Business
UPDATE tblSOC_Attributes
SET SOC_Attr_4 = 'Y'
WHERE SOC_Description LIKE '%Business%'

UPDATE tblSOC_Attributes
SET SOC_Attr_4 = 'N'
WHERE SOC_Attr_4 IS NULL

--Attribute 5 - MultiSIM
UPDATE tblSOC_Attributes
SET SOC_Attr_5 = 'Y'
WHERE SOC_Description LIKE '%Share%'
OR SOC_Description LIKE '%Multi%'
OR SOC_Description LIKE '%Dual%'

UPDATE tblSOC_Attributes
SET SOC_Attr_5 = 'N'
WHERE SOC_Attr_5 IS NULL

--Attribute 3 - Legacy
UPDATE tblSOC_Attributes
SET SOC_Attr_3 = 'Y'
WHERE SOC_Attr_1 = 'N' AND SOC_Attr_2 = 'N' AND SOC_Attr_4 = 'N' AND SOC_Attr_5 = 'N'
AND SOC_Type = 'Price Plan'

UPDATE tblSOC_Attributes
SET SOC_Attr_3 = 'N'
WHERE SOC_Attr_3 IS NULL

--Attribute 6 - Text Packs
UPDATE tblSOC_Attributes
SET SOC_Attr_6 = 'Y'
FROM tblSOC_Attributes A JOIN tblSOCReference B
ON A.SOC_Code = B.SOC_Code
WHERE B.Inclusive_Text > 0

UPDATE tblSOC_Attributes
SET SOC_Attr_6 = 'N'
WHERE SOC_Attr_6 IS NULL

--Attribute 7 - Stop The Clock
UPDATE tblSOC_Attributes
SET SOC_Attr_7 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%Stop%'
OR SOC_Description LIKE '%STC%'

UPDATE tblSOC_Attributes
SET SOC_Attr_7 = 'N'
WHERE SOC_Attr_7 IS NULL

--Attribute 8 - Passport
UPDATE tblSOC_Attributes
SET SOC_Attr_8 = 'Y'
FROM tblSOC_Attributes 
WHERE (SOC_Description NOT LIKE '%VP2%' 
OR SOC_Description NOT LIKE '%VPN%')
AND
(SOC_Description LIKE '%VP%'
OR SOC_Description LIKE '%Passport%')

UPDATE tblSOC_Attributes
SET SOC_Attr_8 = 'N'
WHERE SOC_Attr_8 IS NULL

--Attribute 9 - Passport2
UPDATE tblSOC_Attributes
SET SOC_Attr_9 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%VP2%' 

UPDATE tblSOC_Attributes
SET SOC_Attr_9 = 'N'
WHERE SOC_Attr_9 IS NULL

--Attribute 10 - MusicStation
UPDATE tblSOC_Attributes
SET SOC_Attr_10 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%MusicStation%' 

UPDATE tblSOC_Attributes
SET SOC_Attr_10 = 'N'
WHERE SOC_Attr_10 IS NULL

--Attribute 11 - Mobile Internet
UPDATE tblSOC_Attributes
SET SOC_Attr_11 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Code LIKE 'MOBINT%' 
OR SOC_Code LIKE 'VMI%'

UPDATE tblSOC_Attributes
SET SOC_Attr_11 = 'N'
WHERE SOC_Attr_11 IS NULL

--Attribute 12 - Mobile TV
UPDATE tblSOC_Attributes
SET SOC_Attr_12 = 'Y'
FROM tblSOC_Attributes 
WHERE Substring(SOC_Description,1,5) = 'MobTV' 
	OR Substring(SOC_Description,1,6) = 'Mob TV' 	
	OR SOC_Description LIKE '%Radio DJ%' 
	OR SOC_Code Like 'BonusTV%' 
	OR SOC_Description LIKE '%Football%'

UPDATE tblSOC_Attributes
SET SOC_Attr_12 = 'N'
WHERE SOC_Attr_12 IS NULL

--Attribute 13 - Insurance
UPDATE tblSOC_Attributes
SET SOC_Attr_13 = 'Y'
FROM tblSOC_Attributes 
WHERE 	SUBSTRING(SOC_Code,1,6) = 'INSMAR' 
	OR SUBSTRING(SOC_Code,1,6) = 'FOCMMS' 
	OR SUBSTRING(SOC_Code,1,6) = 'MMSINS' 
	OR SUBSTRING(SOC_Description,1,14) = 'Vodafone Cover' 
	OR SUBSTRING(SOC_Description,1,9) = 'Five Star' 
	OR SUBSTRING(SOC_Description,1,8) = 'Cover Me' 
	OR SUBSTRING(SOC_Description,1,6) = '5 Star' 
	OR SUBSTRING(SOC_Description,1,7) = '**Cover' 
	OR SUBSTRING(SOC_Code,1,3) = 'SWI' 
	OR SOC_Description LIKE '%Insurance%' 
	OR SOC_Description LIKE '%Cover me%' 

UPDATE tblSOC_Attributes
SET SOC_Attr_13 = 'N'
WHERE SOC_Attr_13 IS NULL


--Attribute 14 - Instant Messenger
UPDATE tblSOC_Attributes
SET SOC_Attr_14 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE  '%instant%'

UPDATE tblSOC_Attributes
SET SOC_Attr_14 = 'N'
WHERE SOC_Attr_14 IS NULL


--Attribute 15 - Mobile Broadband
UPDATE tblSOC_Attributes
SET SOC_Attr_15 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Code LIKE '%ESIM%' OR SOC_Description LIKE '%Mobile bb%' 

UPDATE tblSOC_Attributes
SET SOC_Attr_15 = 'N'
WHERE SOC_Attr_15 IS NULL

--Attribute 16 - Unlimited Land Line
UPDATE tblSOC_Attributes
SET SOC_Attr_16 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%+ULL%' OR SOC_Description LIKE '% ULL%'

UPDATE tblSOC_Attributes
SET SOC_Attr_16 = 'N'
WHERE SOC_Attr_16 IS NULL

--Attribute 17 - Full Track Music
UPDATE tblSOC_Attributes
SET SOC_Attr_17 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_code  IN ('MOZART001','MOZART002','THEMEDB1')

UPDATE tblSOC_Attributes
SET SOC_Attr_17 = 'N'
WHERE SOC_Attr_17 IS NULL

--Attribute 18 - SIM Only
UPDATE tblSOC_Attributes
SET SOC_Attr_18 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%SIMO%'

UPDATE tblSOC_Attributes
SET SOC_Attr_18 = 'N'
WHERE SOC_Attr_18 IS NULL

--Attribute 19 - Data Tariffs
UPDATE tblSOC_Attributes
SET SOC_Attr_19 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%Data%'

UPDATE tblSOC_Attributes
SET SOC_Attr_19 = 'N'
WHERE SOC_Attr_19 IS NULL

--Attribute 20 - Extra Minutes
UPDATE tblSOC_Attributes
SET SOC_Attr_20 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%Double%' OR SOC_Description LIKE '% DMin%' 
OR SOC_Description LIKE '%50[%]EM%'

UPDATE tblSOC_Attributes
SET SOC_Attr_20 = 'N'
WHERE SOC_Attr_20 IS NULL

--Attribute 21 - Family
UPDATE tblSOC_Attributes
SET SOC_Attr_21 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Description LIKE '%Family%'

UPDATE tblSOC_Attributes
SET SOC_Attr_21 = 'N'
WHERE SOC_Attr_21 IS NULL

--Attribute 22 - MMS
UPDATE tblSOC_Attributes
SET SOC_Attr_22 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Code LIKE 'MMS%' AND SOC_Description LIKE '%MMS%'

UPDATE tblSOC_Attributes
SET SOC_Attr_22 = 'N'
WHERE SOC_Attr_22 IS NULL

--Attribute 23 - Video
UPDATE tblSOC_Attributes
SET SOC_Attr_23 = 'Y'
FROM tblSOC_Attributes 
WHERE SOC_Code LIKE 'VIDEO%' 

UPDATE tblSOC_Attributes
SET SOC_Attr_23 = 'N'
WHERE SOC_Attr_23 IS NULL







