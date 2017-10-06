#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  All subscriber commitments
#  Description  :  Snapshot of all current commitment for all active
#                  subscribers and those terminated within the last 60 days.
#  Originator   :  SINGLEPOINT
#  Author       :  Aiysha Armstrong
#  Date         :  24 June 2004
#
#  Parameters   :  Date
#
#  Runtime      :  20 minutes
#  Notes        :  <Any relevant notes>
#********************************************************************#
#********************************************************************#
#  File Modification History
#********************************************************************#
# Inits | Date      | Version | Description
# AA    | 24/06/2004|  2.1    | initial version 
# AA    | 08/07/2004|  2.2    | Change date format and make files pipe delimited  
# AA    | 19/07/2004|  2.3    | remove header 
# AA    | 29/07/2004|  2.4    | zip output file 
# PT    | 01/10/2004|  2.5    | changed to look at active + 60 day terms
# JL    | 18/06/2009|  2.6    | Add BILLING_ENTITY.PAPER_REQ_IND
#********************************************************************#

. ${LIB}/seq_ndx_lib.sh || exit 2
. ${LIB}/lib_parameters.sh || exit 2
. ${LIB}/itclib.sh || exit 2

##########
# Document parameters held in parameter file here
#
# Parameter Name, Table Name, Column Name, List of values
#
##########

##########
# Initialise variables and read parameters from parameter (.in) file
##########
DATE=$1

SCRIPT_NAME=`basename $0`
REPORT_NAME=`get_report_name ${SCRIPT_NAME}`

ERROR_CODE=`expr 0`

# Use the following TWO lines for each unique parameter
# PARAMETER_1=`get_report_parameters ${REPORT_NAME} PARAMETER_1`
# ERROR_CODE=`expr $ERROR_CODE + $?`

if [[ $ERROR_CODE -gt 0 ]]
then
    echo "Errors in parameter file: code ${ERROR_CODE}"
    exit 3
fi

#****
#  Filenames
#****
SQL_FILE="$TMP/${REPORT_NAME}.sql"
INPUT_FILE="${INPUT_FILE:-$INPUT/${REPORT_NAME}.txt}"
OUTPUT_FILE="${OUTPUT_FILE:-$OUTPUT/${REPORT_NAME}_$DATE.csv}"
TEMP_FILE="$OUTPUT/${REPORT_NAME}.csv"
ERROR_FILE="$TMP/${REPORT_NAME}.err"

#****
#  SQL script
#****
echo "
   set head on     
   set feedback off
   set pages 0    
   set termout off
   set verify off
   set trimspool on
   set colsep'|';
   set lin 1500   
   col f1 format 999999990.00

   DROP TABLE sub_commit_temp1;
   DROP TABLE sub_commit_temp2;

   spool $OUTPUT_FILE
   
   /****
   *  Query header
   ****/

   SELECT 'Subscriber CTN',
          'Subscriber Status',
          'Commitment Start Date',
          'Commitment End Date',
          'Dealer Code',
          'BAN',
          'Account Type',
          'Customer Value',
          'Bank Sort Code',
          'Bank Account Number',
          'Delinq Status',
          'Multi Handset Indicator',
          'Team ID',
          'Connection Date',
          'Connection Channel',
          'Disconnection Date',
          'SP Account Number',
          'Cycle Code',
          'DD Mandate Satus',
          'DD Mandate Ref',
          'Payment Type',
          'Network',
          'HVC Symbol',
          'Ar Balance',
          'Paper Billing'
     FROM dual;

   /****
   *  Query
   ****/
--set timing on

   CREATE TABLE sub_commit_temp1
   AS
   SELECT a.subscriber_no,
          a.sub_status,
          TO_CHAR(a.commit_start_date, 'DD/MM/YYYY') commit_start_date,
          TO_CHAR(a.commit_end_date, 'DD/MM/YYYY') commit_end_date,
          a.dealer_code,
          a.customer_id,
          TO_CHAR(a.init_activation_date, 'DD/MM/YYYY') init_activation_date,
          a.initial_dealer_code,
          DECODE(a.sub_status, 'C', TO_CHAR(a.sub_status_date, 'DD/MM/YYYY'), '') discon_date,
          b.service_level,
	  a.car_registration sp_account_number,
	  decode(a.np_code,'V','VF','C','O2','Other') network,
	  hvc.hvc_symbol 
     FROM subscriber a, 
		customer_relationship b,
		high_value_cust hvc
    WHERE SYSDATE - DECODE(a.sub_status, 'C', a.sub_status_date, SYSDATE) < 60
      AND b.customer_id (+) = a.customer_id
	AND b.SERVICE_LEVEL = hvc.HVC_SRV_LEVEL_CD(+)
	;

   CREATE INDEX sub_commit_idx ON sub_commit_temp1(customer_id);

   CREATE TABLE sub_commit_temp2
   AS
   SELECT a.subscriber_no,
          a.sub_status,
          a.commit_start_date,
          a.commit_end_date,
          a.dealer_code,
          a.customer_id,
          b.account_type,
          a.service_level,
          d.bank_code,
          d.bank_acct_no,
          b.col_delinq_status,
          c.cntrct_num_of_ctns,
          b.team_id,
          a.init_activation_date,
          a.initial_dealer_code,
          a.discon_date ,
	  a.sp_account_number ,
	  d.bill_cycle ,
	  d.dd_mandate_status ,
	  d.dd_mandate_number ,
	  d.payment_method ,
	  a.network  ,
	  a.hvc_symbol  , 
	  b.ar_balance ,
          d.paper_req_ind
     FROM sub_commit_temp1 a,
          billing_account b,
          customer c,
          billing_entity d
    WHERE b.ban = a.customer_id
      AND c.customer_id = a.customer_id
      AND d.ban = a.customer_id
      AND d.ben = 1
      ;

   DROP TABLE sub_commit_temp1;


   SELECT a.subscriber_no||'|'||
          a.sub_status||'|'||
          a.commit_start_date||'|'||
          a.commit_end_date||'|'||
          a.dealer_code||'|'||
          a.customer_id||'|'||
          a.account_type||'|'||
          a.service_level||'|'||
          a.bank_code||'|'||
          a.bank_acct_no||'|'||
          a.col_delinq_status||'|'||
          a.cntrct_num_of_ctns||'|'||
          a.team_id||'|'||
          a.init_activation_date||'|'||
          a.initial_dealer_code||'|'||
          a.discon_date ||'|'||
	  a.sp_account_number ||'|'||
	  a.bill_cycle ||'|'||
	  a.dd_mandate_status ||'|'||
	  a.dd_mandate_number ||'|'||
	  a.payment_method ||'|'||
	  a.network  ||'|'||
	  a.hvc_symbol  ||'|'|| 
	  a.ar_balance ||'|'||
          a.paper_req_ind
     FROM sub_commit_temp2 a
      ;

   DROP TABLE sub_commit_temp2;

   spool off;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\nAll subscriber commitments"
echo "--------------------------"
echo "Report started : $REPORT_START_DATE"

#****
#  Execute query
#****
echo "running query. . ."
SQLRun ${SQL_FILE}
if [[ $? -gt 0 ]] then
   echo "Failure in "${SQL_FILE}
   exit 1
fi

echo "Zip output file"
/usr/contrib/bin/gzip $OUTPUT_FILE

REPORT_FINISH_DATE=`date +%d-%m-%y\ %T`
echo "Report finished: $REPORT_FINISH_DATE"
echo 

echo ${REPORT_NAME}\|${REPORT_START_DATE}\|${REPORT_FINISH_DATE} >> ${REPORT_RUNTIMES}

#****
#  Tidy up
#****
/usr/bin/rm -f $SQL_FILE
/usr/bin/rm -f $TEMP_FILE
/usr/bin/rm -f $ERROR_FILE
