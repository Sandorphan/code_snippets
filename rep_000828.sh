#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  Price Plan Changes
#  Description  :  All the price plan changes for a given day 
#  Originator   :  Singlepoint  
#  Author       :  Aiysha Armstrong 
#  Date         :  08 July 2004
#
#  Parameters   :  Date
#
#  Runtime      :  2 minutes
#  Notes        :  <Any relevant notes>
#********************************************************************#
#********************************************************************#
#  File Modification History
#********************************************************************#
# Inits | Date      | Version | Description
# AA    | 08/07/2004| 2.1     | Initial Version
# AA    | 12/07/2004| 2.2     | changes to date format
# AA    | 19/07/2004| 2.3     | remove header 
# AA    | 29/07/2004| 2.4     | zip output file 
# PT    | 07/10/2004| 2.5     | Use short_memo table
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
   set lin 1500   
   col f1 format 999999990.00
   spool $OUTPUT_FILE
   
   /****
   *  Query header
   ****/
   set colsep'|';

   SELECT 'BAN',
          'Agent Login',
          'Memo Date',
          'Memo Time',
          'Memo Code',
          'CTN',
          'Memo System Text',
          'Memo Description',
          'Memo Category',
          'Manual Memo',
          'Previous - SOC Code',
          'Previous - Start Date',
          'Previous - End Date',
          'Previous Rate',
          'New - SOC Code',
          'New - Start Date',
          'New - End Date',
          'New Rate',
          'Dealer Code'
     FROM dual;

   /****
   *  Query
   ****/

   SELECT a.memo_ban||'|'||
          a.operator_id||'|'||
          a.memo_date||'|'||
          a.memo_time||'|'||
          a.memo_type||'|'||
          a.memo_subscriber||'|'||
          a.memo_system_txt||'|'||
          a.memtp_memo_description||'|'||
          a.memtp_memo_category||'|'||
          a.memtp_manual_ind||'|'||
          b.prev_pp||'|'||
          TO_CHAR(c.effective_date, 'DD/MM/YYYY')||'|'||
          TO_CHAR(c.expiration_date, 'DD/MM/YYYY')||'|'||
          d.rate||'|'||
          b.pp||'|'||
          TO_CHAR(e.effective_date, 'DD/MM/YYYY')||'|'||
          TO_CHAR(e.expiration_date, 'DD/MM/YYYY')||'|'||
          f.rate||'|'||
          b.dealer
     FROM short_memo a,
          srv_trx_repos_temp b,
          service_agreement c,
          pp_rc_rate d,
          service_agreement e,
          pp_rc_rate f
    WHERE memo_type IN ('0015', '0013')
      AND b.ctn = a.memo_subscriber
      AND b.ban = a.memo_ban
      AND TRUNC(b.sys_creation_date) = TO_DATE(a.memo_date, 'DD/MM/YYYY')
      AND b.sys_eff_date - TO_DATE(a.memo_date||' '||a.memo_time, 'DD/MM/YYYY HH24:MI:SS') < 0.00006
      AND b.sys_eff_date - TO_DATE(a.memo_date||' '||a.memo_time, 'DD/MM/YYYY HH24:MI:SS') > -0.00006
      AND b.prev_pp <> b.pp
      AND c.ban = a.memo_ban
      AND c.subscriber_no = a.memo_subscriber
      AND c.soc = b.prev_pp
      AND TRUNC(c.expiration_date) = TO_DATE(a.memo_date, 'DD/MM/YYYY')
      AND c.sys_update_date - TO_DATE(a.memo_date||' '||a.memo_time, 'DD/MM/YYYY HH24:MI:SS') < 0.00006
      AND c.sys_update_date - TO_DATE(a.memo_date||' '||a.memo_time, 'DD/MM/YYYY HH24:MI:SS') > -0.00006
      AND c.service_type = 'P'
      AND d.soc = c.soc
      AND (d.expiration_date IS NULL OR d.expiration_date > TO_DATE(a.memo_date, 'DD/MM/YYYY'))
      AND d.effective_date <= TO_DATE(a.memo_date, 'DD/MM/YYYY')
      AND d.tier_level_code IN (0, 1)
      AND e.ban = a.memo_ban
      AND e.subscriber_no = a.memo_subscriber
      AND e.soc = b.pp
      AND TRUNC(e.effective_date) = TO_DATE(a.memo_date, 'DD/MM/YYYY')
      AND e.sys_creation_date - TO_DATE(a.memo_date||' '||a.memo_time, 'DD/MM/YYYY HH24:MI:SS') < 0.00006
      AND e.sys_creation_date - TO_DATE(a.memo_date||' '||a.memo_time, 'DD/MM/YYYY HH24:MI:SS') > -0.00006
      AND e.service_type = 'P'
      AND f.soc = e.soc
      AND (f.expiration_date IS NULL OR f.expiration_date > TO_DATE(a.memo_date, 'DD/MM/YYYY'))
      AND f.effective_date <= TO_DATE(a.memo_date, 'DD/MM/YYYY')
      AND f.tier_level_code IN (0, 1)
      AND NOT (c.effective_date = TO_DATE(a.memo_date, 'DD/MM/YYYY') AND
               c.expiration_date = TO_DATE(a.memo_date, 'DD/MM/YYYY') AND
               e.effective_date = TO_DATE(a.memo_date, 'DD/MM/YYYY') AND
               NVL(e.expiration_date, TO_DATE('01/01/1901', 'DD/MM/YYYY')) = TO_DATE(a.memo_date, 'DD/MM/YYYY'))
      AND (c.effective_date <> e.expiration_date or e.expiration_date IS NULL);

   spool off;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\nPrice Plan Changes"
echo "------------------"
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
