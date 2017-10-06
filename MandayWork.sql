CREATE VIEW vwIEXEfficiencyGroups AS
SELECT     A.ATTR_ID, A.ATTR_VALUE_ID, B.ATTR_VALUE_NAME, A.EXC_ID, C.EXC_NAME
FROM         dbo.Localattrmap AS A LEFT OUTER JOIN
                      dbo.Localattrval AS B ON A.ATTR_ID = B.ATTR_ID AND A.ATTR_VALUE_ID = B.ATTR_VALUE_ID LEFT OUTER JOIN
                      dbo.LocalExcept AS C ON A.EXC_ID = C.EXC_ID
WHERE     (A.ATTR_ID = 22) AND (C.CUSTOMER_ID = 1)


SELECT A.Exc_ID AS ExecCode, 
CASE WHEN A.Attr_ID = 17 THEN B.Attr_Value_Name ELSE NULL END AS ShrinkageGroup
FROM Localattrmap A JOIN Localattrval B
ON A.ATTR_ID = B.ATTR_ID AND A.ATTR_VALUE_ID = B.ATTR_VALUE_ID
WHERE A.ATTR_ID = 17

SELECT A.Exc_ID AS ExecCode, 
CASE WHEN A.Attr_ID = 21 THEN B.Attr_Value_Name ELSE NULL END AS EfficiencyGroup
FROM Localattrmap A JOIN Localattrval B
ON A.ATTR_ID = B.ATTR_ID AND A.ATTR_VALUE_ID = B.ATTR_VALUE_ID
WHERE A.ATTR_ID = 21


SELECT * FROM dbo.Localattrval ORDER BY Attr_ID

DROP TABLE tblMandayReferenceData

CREATE TABLE tblMandayReferenceData (
ExecCode smallint,
ExecDescription VARCHAR(100),
ShrinkageGroup VARCHAR(100),
MandayInclude VARCHAR(100),
EfficiencyType VARCHAR(100))

INSERT INTO tblMandayReferenceData
SELECT A.Exc_ID, C.Exc_Name, NULL, NULL, NULL
FROM dbo.Localattrmap A LEFT OUTER JOIN dbo.LocalExcept C
ON A.EXC_ID = C.EXC_ID
WHERE C.Customer_ID = 1
GROUP BY A.Exc_ID, C.Exc_Name
ORDER BY A.Exc_ID

UPDATE tblMandayReferenceData
SET ShrinkageGroup = B.Attr_Value_Name
FROM tblMandayReferenceData A JOIN dbo.vwIEXShrinkageGroups B
ON A.ExecCode = B.Exc_ID

UPDATE tblMandayReferenceData
SET MandayInclude = B.Attr_Value_Name
FROM tblMandayReferenceData A JOIN dbo.vwIEXMandayGroups B
ON A.ExecCode = B.Exc_ID

UPDATE tblMandayReferenceData
SET MandayInclude = 'No'
WHERE MandayInclude IS NULL



UPDATE tblMandayReferenceData
SET EfficiencyType = B.Attr_Value_Name
FROM tblMandayReferenceData A JOIN dbo.vwIEXEfficiencyGroups B
ON A.ExecCode = B.Exc_ID

UPDATE tblMandayReferenceData
SET EfficiencyType = 'Sign Off'
WHERE EfficiencyType IS NULL

SELECT * FROM tblMandayReferenceData
