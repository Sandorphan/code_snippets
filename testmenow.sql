TRUNCATE TABLE tbl_Transaction_Current_Dev

INSERT INTO tbl_Transaction_Current_Dev
SELECT * FROM tbl_Transaction_History
WHERE Order_Date > '01-31-2009'