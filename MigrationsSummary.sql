DROP TABLE #TmpSOCChanges

CREATE TABLE #TmpSOCChanges (
CTN VARCHAR(50) NULL,
Order_Date DATETIME NULL,
Prev_SOC_Code VARCHAR(50) NULL,
Prev_SOC_LR MONEY NULL, 
Prev_SOC_LRGroup VARCHAR(50) NULL,
New_SOC_Code VARCHAR(50) NULL,
New_SOC_LR MONEY NULL,
New_SOC_LRGroup VARCHAR(50) NULL,
Activity_Type VARCHAR(50) NULL,
Activity_Group VARCHAR(50) NULL)

INSERT INTO #TmpSOCChanges 
SELECT Memo_CTN, Memo_Date, Prev_SOC_Code, NULL, NULL, New_SOC_Code, NULL, NULL, 
CASE WHEN Order_Type = 'PP_Change' THEN 'Migration' ELSE Order_Type END, NULL
FROM tbl_PricePlan_Changes_History
WHERE Memo_Date > '04-30-2008'
AND Memo_Agent_ID IN (SELECT Gemini_ID FROM MIReferenceTables.dbo.tbl_Agents WHERE Department LIKE 'Customer Saves')

UPDATE #TmpSOCChanges
SET Prev_SOC_LR = B.Rate,
Prev_SOC_LRGroup = CASE 
WHEN B.Rate < 10 THEN '£0 - £10'
WHEN B.Rate < 15 THEN '£10 - £15'
WHEN B.Rate < 20 THEN '£15 - £20'
WHEN B.Rate < 25 THEN '£20 - £25'
WHEN B.Rate < 30 THEN '£25 - £30'
WHEN B.Rate < 35 THEN '£30 - £35'
WHEN B.Rate < 40 THEN '£35 - £40'
WHEN B.Rate < 45 THEN '£40 - £45'
WHEN B.Rate < 50 THEN '£45 - £50'
WHEN B.Rate < 55 THEN '£50 - £55'
WHEN B.Rate < 60 THEN '£55 - £60'
WHEN B.Rate < 65 THEN '£60 - £65'
WHEN B.Rate < 70 THEN '£65 - £70'
WHEN B.Rate < 75 THEN '£70 - £80'
WHEN B.Rate < 80 THEN '£75 - £85'
WHEN B.Rate < 85 THEN '£80 - £90'
WHEN B.Rate < 90 THEN '£85 - £90'
WHEN B.Rate < 95 THEN '£90 - £95'
WHEN B.Rate < 100 THEN '£95 - £10'
ELSE '£100+'
END
FROM #TmpSOCChanges A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.Prev_SOC_Code = B.SOC_Code

UPDATE #TmpSOCChanges
SET New_SOC_LR = B.Rate,
New_SOC_LRGroup = CASE 
WHEN B.Rate < 10 THEN '£0 - £10'
WHEN B.Rate < 15 THEN '£10 - £15'
WHEN B.Rate < 20 THEN '£15 - £20'
WHEN B.Rate < 25 THEN '£20 - £25'
WHEN B.Rate < 30 THEN '£25 - £30'
WHEN B.Rate < 35 THEN '£30 - £35'
WHEN B.Rate < 40 THEN '£35 - £40'
WHEN B.Rate < 45 THEN '£40 - £45'
WHEN B.Rate < 50 THEN '£45 - £50'
WHEN B.Rate < 55 THEN '£50 - £55'
WHEN B.Rate < 60 THEN '£55 - £60'
WHEN B.Rate < 65 THEN '£60 - £65'
WHEN B.Rate < 70 THEN '£65 - £70'
WHEN B.Rate < 75 THEN '£70 - £80'
WHEN B.Rate < 80 THEN '£75 - £85'
WHEN B.Rate < 85 THEN '£80 - £90'
WHEN B.Rate < 90 THEN '£85 - £90'
WHEN B.Rate < 95 THEN '£90 - £95'
WHEN B.Rate < 100 THEN '£95 - £10'
ELSE '£100+'
END
FROM #TmpSOCChanges A JOIN MIReferenceTables.dbo.tblsocreference B
ON A.New_SOC_Code = B.SOC_Code

SELECT * FROM #TmpSOCChanges