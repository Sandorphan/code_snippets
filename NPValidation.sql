SELECT * FROM tblNotionalProfitData
WHERE Order_Date = '12-09-2008'
AND Department = 'Customer Saves'
AND Site = 'Stoke'

SELECT Order_Date, Agent_Name, CTN, BAN, Contract_Gross_Period, Contract_Net_Period, 
Handset_Volume, Handset_Revenue, Handset_Cost, Handset_subsidy, Accessory_Revenue, Accessory_Cost,
SIM_Card_Revenue, SIM_Card_Cost, PAYT_SIM_Card_Revenue, PAYT_SIM_Card_Cost, 
Delivery_Charge_Revenue, Delivery_Charge_Cost, Credits_Cost_Total, 
Price_Plan_Commercial_LT_Cost, Price_Plan_Commercial_ST_Cost, 
Extras_Commercial_LT_Cost, Extras_Commercial_ST_Cost, Discounts_Cost
SUI_Contracts, SUI_RIV
FROM dbo.tblOneLinerData
WHERE Order_Date = '12-09-2008'
AND Department = 'Customer Saves'
AND Site = 'Stoke'
AND Order_Type = 'Retention'
