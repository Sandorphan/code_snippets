SELECT DISTINCT A.Site
FROM MIReferenceTables.dbo.tbl_Agents A JOIN 
MIReferenceTables.dbo.tbl_AgentSiteReference B ON
A.Site = B.Site
WHERE B.Restrictions =
(SELECT
	CASE 
		WHEN (SELECT Site FROM MIReferenceTables.dbo.tbl_Agents WHERE (NT_User = REPLACE(SYSTEM_USER,'VF-UK\','') OR NT_User = REPLACE(SYSTEM_USER,'VFTCINT\',''))) IN ('Warrington','TSC') THEN 'TSC'
		WHEN (SELECT Site FROM MIReferenceTables.dbo.tbl_Agents WHERE (NT_User = REPLACE(SYSTEM_USER,'VF-UK\','') OR NT_User = REPLACE(SYSTEM_USER,'VFTCINT\',''))) IN ('LBM Belfast','LBM MIddleton','LBM Bredbury') THEN 'LBM'
		WHEN (SELECT Site FROM MIReferenceTables.dbo.tbl_Agents WHERE (NT_User = REPLACE(SYSTEM_USER,'VF-UK\','') OR NT_User = REPLACE(SYSTEM_USER,'VFTCINT\',''))) IN ('Conduit') THEN 'Conduit'
		WHEN (SELECT Site FROM MIReferenceTables.dbo.tbl_Agents WHERE (NT_User = REPLACE(SYSTEM_USER,'VF-UK\','') OR NT_User = REPLACE(SYSTEM_USER,'VFTCINT\',''))) IN ('Garlands') THEN 'Garlands'
		ELSE 'All' END)


