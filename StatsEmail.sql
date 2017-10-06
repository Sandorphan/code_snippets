TRUNCATE TABLE tblDailyStatsSummary

INSERT INTO tblDailyStatsSummary
SELECT Order_Date, Department, 
SUM(Contract_NET_Volume),
SUM(Handset_Volume),
--SUM(Handset_Cost) - SUM(Handset_Revenue),
SUM(Accessory_Volume),
--SUM(Accessory_Cost) - SUM(Accessory_Revenue),
SUM(Price_Plan_Volume),
--SUM(ISNULL(Price_Plan_Commercial_ST_Cost,0)) + (SUM(ISNULL(Price_Plan_Commercial_LT_Cost,0)) * SUM(ISNULL(Contract_Gross_Period_Total,0))),
SUM(Extras_Volume),
--SUM(ISNULL(Extras_Commercial_ST_Cost,0)) + (SUM(ISNULL(Extras_Commercial_LT_Cost,0)) * SUM(ISNULL(Contract_Gross_Period_Total,0))),
SUM(Discounts_Recurring_Volume),
--SUM(Discounts_Cost),
SUM(Credits_Volume)
--SUM(Credits_Cost_Total)
FROM tbl_Transaction_Summary
WHERE Order_Date > Getdate()-7 AND
Department IN ('Outbound Retention','Inbound Retention','Customer Saves','High Value Retention')
GROUP BY Order_Date, Department
ORDER BY Order_Date,Department



EXEC master.dbo.xp_startmail
EXEC master.dbo.xp_sendmail 
	@recipients = 'simon.robinson@vodafone.co.uk', --;wayne.fraser@vodafone.co.uk',
	@subject = 'Testing Data Stats',
	@Query = 'SELECT Order_Date, LTrim(RTrim(Department)), Contracts , Handsets , Accessories, PricePlans, AddServices, Discounts, Credits FROM tblDailyStatsSummary',
	@attach_results = false,
	@width = 150,
	@separator = ','