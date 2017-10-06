CREATE PROC spTSARSummary AS

DECLARE YDate AS DATETIME
DECLARE MDate AS VARCHAR(100)



CREATE TABLE #TSAREmailSummary_Yest  (
Department VARCHAR(100),
Site VARCHAR(100),
YRetCont INT,
YRetSIMO INT,
YAcqCont INT,
YAcqSIMO INT,
YIBCalls INT,
YOBCalls INT,
YMandays DECIMAL(18,2),
YRetProfit MONEY,
YRetCash MONEY,
YRetAir MONEY,
YAcqProfit MONEY,
YAcqCash MONEY,
YAcqAir MONEY)

CREATE TABLE #TSAREmailSummary_MTD  (
Department VARCHAR(100),
Site VARCHAR(100),
MRetCont INT,
MRetSIMO INT,
MAcqCont INT,
MAcqSIMO INT,
MIBCalls INT,
MOBCalls INT,
MMandays DECIMAL(18,2),
MRetProfit MONEY,
MRetCash MONEY,
MRetAir MONEY,
MAcqProfit MONEY,
MAcqCash MONEY,
MAcqAir MONEY)

INSERT INTO #TSAREmailSummary_Yest
SELECT Department, Site, SUM(RetentionContracts), SUM(Retention_SIMOnly),
SUM(Acquisition_Contracts), SUM(Acquisition_SIMOnly), SUM(Inbound_Calls),
SUM(Outbound_Calls), SUM(Mandays), SUM(Retention_NotionalProfit)+SUM(RetentionHWCosts)+SUM(RetentionAirCosts),
SUM(RetentionHWCosts), SUM(RetentionAirCosts),SUM(Acquisition_NotionalProfit)+SUM(AcquisitionHWCosts)+SUM(AcquisitionAirCosts),
SUM(AcquisitionHWCosts), SUM(AcquisitionAirCosts)
FROM dbo.tblInspireMarginDataSummaryACCORD_History
WHERE OrderDate = '01-26-2011'
AND BusinessUnit = 'CBU'
AND Channel = 'Call Centre - Sales'
AND Department IN ('Customer Retention','Direct Sales Inbound','One Outbound')
GROUP BY Department, Site


INSERT INTO #TSAREmailSummary_MTD
SELECT Department, Site, SUM(RetentionContracts), SUM(Retention_SIMOnly),
SUM(Acquisition_Contracts), SUM(Acquisition_SIMOnly), SUM(Inbound_Calls),
SUM(Outbound_Calls), SUM(Mandays), SUM(Retention_NotionalProfit)+SUM(RetentionHWCosts)+SUM(RetentionAirCosts),
SUM(RetentionHWCosts), SUM(RetentionAirCosts),SUM(Acquisition_NotionalProfit)+SUM(AcquisitionHWCosts)+SUM(AcquisitionAirCosts),
SUM(AcquisitionHWCosts), SUM(AcquisitionAirCosts)
FROM dbo.tblInspireMarginDataSummaryACCORD_History
WHERE OrderMonth = '201101 - January'
AND BusinessUnit = 'CBU'
AND Channel = 'Call Centre - Sales'
AND Department IN ('Customer Retention','Direct Sales Inbound','One Outbound')
GROUP BY Department, Site


INSERT INTO tblTSAREmailSummary
SELECT * FROM #TSAREmailSummary_Yest A JOIN #TSAREmailSummary_MTD B
ON A.Department = B.Department AND A.Site = B.Site
