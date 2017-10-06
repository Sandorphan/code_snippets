select Business_Unit,Channel,Rpt_Function,Department, Site, Booked_Date, Order_Status,
COUNT(Worksheet) AS Volume_Sales
from handset_returns where handset_description like '%storm%'
GROUP BY Business_Unit,Channel,Rpt_Function,Department, Site, Booked_Date, Order_Status