SELECT * FROm vwOneLinerAgentActivitiesRetentions

SELECT A.Agent, A.TM, A.CCM, A.Department, A.Site, A.RptFunction, A.Channel, A.BusinessUnit,
SUM(B.MinsInAdherence), SUM(B.SchedMins), SUM(B.ACDTime), SUM(B.AvailTime), SUM(B.StaffedTime),
SUM(B.ACWTime), SUM(B.ActMins), SUM(B.Acd_Other_Time), SUM(B.ACW_Out_Time), SUM(B.Aux_Out_Time)
FROM tblYieldData A JOIN vwOneLinerAgentActivitiesRetentions B
ON A.Agent = B.Agent_Name
WHERE A.Order_Date = B.NewDate
GROUP BY A.Agent, A.TM, A.CCM, A.Department, A.Site, A.RptFunction, A.Channel, A.BusinessUnit