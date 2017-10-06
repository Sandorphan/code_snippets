SELECT CTN, Order_Date FROM tbl_Transaction_Summary
WHERE (Exception_A_Flag = 1 OR Exception_B_Flag = 1 OR Exception_C_Flag = 1
OR Exception_D_Flag = 1 OR Exception_E_Flag = 1 OR Exception_F_Flag = 1)
AND Order_Date = '07-21-2008'