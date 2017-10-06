SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


ALTER   VIEW vwInspireSummary AS
SELECT OrderDate AS [OrderDate], Department, 
SUM(RetentionContracts) AS [RetentionContracts],
SUM(Retention_SIMONLY) As [RetentionSIMO],
SUM(Retention_NotionalProfit) AS RetentionGrossProfit ,
SUM(RetentionHWCosts) AS RetentionCashCost,
SUM(RetentionAirCosts) AS RetentionAirCost,
SUM(Acquisition_Contracts) AS AcquisitionContracts,
SUM(Acquisition_SIMONLY) As AcquisitionSIMO,
SUM(Acquisition_NotionalProfit) AS AcquisitionGrossProfit,
SUM(AcquisitionHWCosts) AS AcquisitionCashCost,
SUM(AcquisitionAirCosts) AS AcquisitionAirCost,
SUM(Inbound_Calls) + SUM(Outbound_Calls) AS TotCalls,
SUM(Mandays) AS TotMandays,
CASE
	WHEN OrderDate > GetDate()-7 THEN 'Wk1'
	WHEN OrderDate <= GetDate()-7 AND OrderDate > Getdate()-15 THEN 'Wk2'
	WHEN OrderDate <= GetDate()-14 AND OrderDate > Getdate()-22 THEN 'Wk3'
	WHEN OrderDate <= GetDate()-21 AND OrderDate > Getdate()-29 THEN 'Wk4'
	WHEN OrderDate <= GetDate()-28 AND OrderDate > Getdate()-36 THEN 'Wk5'
	WHEN OrderDate <= GetDate()-35 AND OrderDate > Getdate()-43 THEN 'Wk6'
	WHEN OrderDate <= GetDate()-42 AND OrderDate > Getdate()-50 THEN 'Wk7'
	WHEN OrderDate <= GetDate()-49 AND OrderDate > Getdate()-57 THEN 'Wk8'
	ELSE 'Wk9' END AS WeekFilter

FROM dbo.tblInspireMarginDataSummary_History
WHERE Department IN ('Customer Retention','Outbound Retention','High Value Retention','Direct Sales Inbound','Outbound Telesales')
AND OrderDate > Getdate()-57
GROUP BY OrderDate, Department,
CASE
	WHEN OrderDate < GetDate()-7 THEN 'Wk1'
	WHEN OrderDate >= GetDate()-7 AND OrderDate < Getdate()-15 THEN 'Wk2'
	WHEN OrderDate >= GetDate()-14 AND OrderDate < Getdate()-22 THEN 'Wk3'
	WHEN OrderDate >= GetDate()-21 AND OrderDate < Getdate()-29 THEN 'Wk4'
	WHEN OrderDate >= GetDate()-28 AND OrderDate < Getdate()-36 THEN 'Wk5'
	WHEN OrderDate >= GetDate()-35 AND OrderDate < Getdate()-43 THEN 'Wk6'
	WHEN OrderDate >= GetDate()-42 AND OrderDate < Getdate()-50 THEN 'Wk7'
	WHEN OrderDate >= GetDate()-49 AND OrderDate < Getdate()-57 THEN 'Wk8'
	ELSE 'Wk9' END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



INSERT INTO SPSVRMI01.MIOutputs.dbo.tblInSpireManagementSummary
SELECT * FROM vwInspireSummary