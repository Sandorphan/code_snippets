

SELECT  Team, Agent, CTN, BAN, Order_Date, Order_Type, Subscriber_Status, Primary_Price_Plan, Primary_Handset, 
CASE WHEN Handset_Exchanges > 0 THEN 'Y' ELSE 'N' END AS ExcFlag, Contract_Gross_Volume, Contract_Gross_Period_Total, 
Contract_Net_Period_Total, Contract_SIMOnly, Handset_Cost, Handset_Revenue, 
(IsNull(SIM_Card_Cost,0) + IsNull(PAYT_SIM_Card_Cost,0) + IsNull(Delivery_Charge_Cost,0) + IsNull(Accessory_Cost,0)) - (IsNull(SIM_Card_Revenue,0) + IsNull(PAYT_SIM_Card_Revenue,0) + IsNull(Delivery_Charge_Revenue,0) + IsNull(Accessory_Revenue,0)) AS Other_Hardware_Loss, 
Credits_Volume, Credits_Cost_Total, ((IsNull(Price_Plan_Commercial_ST_Cost,0) + IsNull(Extras_Commercial_ST_Cost,0)) + ((IsNull(Price_Plan_Commercial_LT_Cost,0) + IsNull(Extras_Commercial_LT_Cost,0)) * IsNull(Contract_Gross_Period_Total,0))) AS Commercial_Cost, 
(Isnull(Discounts_Volume,0)), (IsNull(Discounts_Cost,0)),  IsNull(CTR_Bonus_Available,0), IsNull(CTR_Bonus_Used,0), 
CASE WHEN Extras_Text_Bundle > 0 THEN 'Text Pack' ELSE 'N' END AS TxtBundle, 
CASE WHEN Extras_MobileInternet_Volume > 0 AND Primary_SOC LIKE 'VMI%' THEN 'VMI (Inc)' WHEN Extras_MobileInternet_Volume > 0 AND Primary_SOC NOT LIKE 'VMI%' THEN 'VMI (Add)' ELSE 'N' END AS VMIFlag, 
CASE WHEN Extras_Insurance_Volume > 0 THEN 'Insurance' ELSE 'N' END AS InsSOC, IsNull(SUI_RIV,0) FROM tbl_Transaction_Summary 
WHERE 
Business_Unit LIKE 'CBU' 
AND Channel LIKE 'Call Centre - Sales' 
AND Reporting_Function LIKE 'Commercial Operations' 
AND Department LIKE 'Inbound Retention' 
AND Site LIKE 'Stoke' 
AND CCManager LIKE 'Joanne Casswell' 
AND Team LIKE 'Bruce Jones' 
AND Agent LIKE '%' 
AND Order_Date BETWEEN '03-01-2009' AND '03-24-2009' 
ORDER BY Team ASC, Agent ASC, Order_type ASC, Contract_Gross_Volume DESC, Contract_SIMOnly DESC, Order_Date ASC
