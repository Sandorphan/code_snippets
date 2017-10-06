select dl_department, txn_productcode, txn_productdescription, sum(txn_quantity)
from tbl_transaction_current
where dl_department like '%phones%'
and txn_producttype = 'Price Plan'
group by dl_department, txn_productcode, txn_productdescription