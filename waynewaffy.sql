SELECT Order_date, Order_Type, Department, Channel, Business_Unit, 
CASE
	WHEN Primary_Handset LIKE '%N96%' THEN 'Nokia N96'
	WHEN Primary_Handset LIKE '%8GB%' THEN 'Nokia N95 8GB'
	WHEN Primary_Handset LIKE '%N95%' THEN 'Nokia N95' END, Primary_Price_Plan,
Handset_Volume, Contract_Gross_Volume, 
CASE
	WHEN Contract_Gross_Period_Total < 12 THEn 0
	WHEN Contract_Gross_Period_Total < 18 THEn 12
	WHEN Contract_Gross_Period_Total < 24 THEn 18
	ELSE 24 END
FROM tbl_Transaction_Summary
WHERE Primary_Handset LIKE '%N96%' OR Primary_Handset LIKE '%N95%'