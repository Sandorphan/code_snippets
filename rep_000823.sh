#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  Subscriber and Ban Discounts (T2)
#  Description  :  All subscriber and BAN discounts applied for a given day.
#  Originator   :  Singlepoint
#  Author       :  Aiysha Armstrong 
#  Date         :  01 July 2004
#
#  Parameters   :  Date
#
#  Runtime      :  1 minute
#  Notes        :  <Any relevant notes>
#********************************************************************#
#********************************************************************#
#  File Modification History
#********************************************************************#
# Inits | Date      | Version | Description
# AA    | 01/07/2004| 2.1     | Initial Version
# AA    | 19/07/2004| 2.2     | remove header 
# PT    | 10/09/2004| 2.4     | extract based on short_memo table
#********************************************************************#

. ${LIB}/seq_ndx_lib.sh || exit 2
. ${LIB}/lib_parameters.sh || exit 2
. ${LIB}/itclib.sh || exit 2

##########
# Document parameters held in parameter file here
#
# Parameter Name, Table Name, Column Name, List of values
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
   set lin 1500   
   set colsep' '; 
   col f1 format 999999990.00
   spool $OUTPUT_FILE

   /****
   *  Query header
   ****/
   set colsep'|';

   SELECT 'Memo BAN',
          'Memo Agent ID',
          'Memo Date',
          'Memo Time',
          'Memo Type',
          'Memo CTN',
          'Memo Description',
          'Memo Category',
          'Manual Indicator',
          'SOC Code',
          'Revenue Code',
          'Discount Percent',
          'Discount Amount',
          'Start Date',
          'End Date',
          'Adjustment Reason',
          'Dealer Code'
     FROM dual;

   /****
   *  Query
   ****/

   SELECT memo_ban||'|'||
          a.operator_id||'|'||
          memo_date||'|'||
          memo_time||'|'||
          memo_type||'|'||
          memo_subscriber||'|'||
          memtp_memo_description||'|'||
          memtp_memo_category||'|'||
          memtp_manual_ind||'|'||
          b.soc||'|'||
          b.revenue_code||'|'||
          b.discount_percent||'|'||
          b.discount_fix_amt||'|'||
          TO_CHAR(b.effective_date, 'DD/MM/YYYY')||'|'||
          TO_CHAR(b.expiration_date, 'DD/MM/YYYY')||'|'||
          b.discount_adj_reason||'|'||
          c.dealer_code
     FROM short_memo a,
          ban_discount b,
          subscriber c
    WHERE a.memo_type = '0527'
      AND b.ban = memo_ban
      AND b.corporate = '0'
      AND c.subscriber_no (+) = b.ctn
      AND c.customer_id (+) = b.ban
      AND (TO_CHAR(b.sys_creation_date, 'DD/MM/YYYY') = memo_date OR
           TO_CHAR(b.sys_update_date, 'DD/MM/YYYY') = memo_date)
      AND (TO_CHAR(b.sys_creation_date, 'HH24:MI:SS') = memo_time OR
           TO_CHAR(b.sys_update_date, 'HH24:MI:SS') = memo_time);

   spool off;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\nSubscriber and Ban Discounts (T2)"
echo "---------------------------------"
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
