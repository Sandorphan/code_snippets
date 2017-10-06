SELECT 	A.sched_date,	A.Agent_ID,	A.Exec_Code, A.Exec_Description, 
Sum(CASE WHEN D.MandayInclude = 'Include' THEN A.exec_duration
		ELSE 0		END),
Sum(CASE WHEN D.MandayInclude = 'Pro Rata' THEN A.exec_duration
		ELSE 0		END),
Sum(CASE WHEN D.MandayInclude = 'Exclude'   THEN	A.exec_duration
		ELSE 0	END),
Sum(CASE WHEN D.EfficiencyType = 'Sign On' THEN	A.exec_duration
		ELSE 0	END)
FROM dbo.Local_Reporting_Detail A
			JOIN
				tblMandayreferenceData D
ON A.exec_code = D.Execcode
WHERE A.Agent_Name LIKE '%Hackney%'
AND A.Sched_date BETWEEN  '08-10-2011' AND '08-16-2011'
GROUP BY 	A.sched_date
	,	A.Agent_ID, A.Exec_Code, A.Exec_Description