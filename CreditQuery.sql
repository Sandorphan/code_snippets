SELECT TOP 1000 * FROM dbo.tblCreditNotes_History
WHERE Reason_Code = 'C-TERM'
AND Site IN ('Warrington','Egypt','TSC')
AND Channel = 'Call Centre - Customer'
AND Activity_Date BETWEEN '12-01-2011' AND '12-31-2011'