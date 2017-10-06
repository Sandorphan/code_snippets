select top 2500 * from tblcreditnotes_history where channel in ('call centre - customer','retail')
and department not in ('customer relations','staff accounts')
and reason_code in ('BKE','IKE')
and activity_date between '11-01-2011' and '11-30-2011' 