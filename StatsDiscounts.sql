select MonthText, Agent, TM, Department,
SUM(Gross_Contract_Length), SUM(Gross_Revenue), SUM(Handset_Cost) - SUM(Handset_Revenue),
SUM(Discount_Cost)
from tblnotionalprofitdata JOIN MIReferenceTables.dbo.tbl_ref_dates ON Order_Date = NewDate
WHERE Department IN ('Customer Saves','Inbound Retention','Outbound Retention','High Value Retention','Direct Sales Inbound', 'Ultra High Value','Outbound Telesales','Customer Returns Management','Customer Retention','NES')
GROUP BY MonthText, Agent, TM, Department