SELECT * FROM New_Handset_Table WHERE Product_Type = 'Handset'
AND (Handset_Description NOT LIKE '%Modem%'  AND Handset_Description NOT LIKE '%USB%' 
AND Handset_Description NOT LIKE '%Datacard%' AND Handset_Description NOT LIKE '%Mobile Connect%'
AND Handset_Description NOT LIKE '%Data Card%' AND Handset_Description NOT LIKE '%Option%')
order by handset_description