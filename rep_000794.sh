#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  All Terminating Subscribers 
#  Description  :  Snapshot of all subscribers who are in termination status
#  Originator   :  Singlepoint  
#  Author       :  Aiysha Armstrong 
#  Date         :  22 June 2004 
#
#  Parameters   :  Date
#
#  Runtime      :  5 minutes
#  Notes        :  <Any relevant notes>
#********************************************************************#
#********************************************************************#
#  File Modification History
#********************************************************************#
# Inits | Date      | Version | Description
# AA    | 22/06/2004| 2.1     | Initial version
# AA    | 01/07/2004| 2.2     | Move the drop table commands above the spool command
# AA    | 08/07/2004| 2.3     | Change date format and make files pipe delimited
# AA    | 19/07/2004| 2.4     | remover header from report
# AA    | 29/07/2004| 2.5     | zip output file 
# PT    | 09/09/2004| 2.6     | Run against short_memo table
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
          'Memo CTN',
          'Memo Type',
          'Memo Agent ID',
          'Memo System Text',
          'Memo Date',
          'Memo Time',
          'Memo Description',
          'Memo Category',
          'Manual Indicator',
          'Name Title',
          'First Name',
          'Middle Initial',
          'Last Business Name',
          'Adr House Name',
          'Adr House No',
          'Adr Primary Ln',
          'Adr Secondary Ln',
          'Adr District',
          'Adr City',
          'Adr County Name',
          'Adr Country',
          'Adr Post Code',
          'Sub Status',
          'Account Type',
          'Col Delinq Status',
          'Home Telno',
          'Service Level',
          'Bank Code',
          'Bank Account No',
          'Penalty Charged',
          'Penalty Waived'
     FROM dual;

   /****
   *  Query
   ****/

   CREATE TABLE all_terms1
   AS
   SELECT a.*,
          b.cfr_p1,
          b.cfr_p5,
          NVL(c.sub_status,'*') sub_status
     FROM short_memo a,
          csm_future_request b,
          subscriber c
    WHERE b.cfr_ban (+) = a.memo_ban
      AND b.cfr_subscriber_no (+) = a.memo_subscriber
      AND c.customer_ban (+) = a.memo_ban
      AND c.subscriber_no (+) = a.memo_subscriber
      AND a.memo_type = '0005'
      AND b.operator_id (+) = a.operator_id
      AND b.cfr_activity_cd (+) = 'CAN'
      AND b.cfr_status (+) = 'R'
   UNION
   SELECT a.*,
          b.cfr_p1,
          b.cfr_p5,
          NVL(c.sub_status,'*') sub_status
     FROM short_memo a,
          csm_future_request b,
          subscriber c
    WHERE b.cfr_ban = a.memo_ban
      AND b.cfr_subscriber_no = a.memo_subscriber
      AND c.customer_ban = a.memo_ban
      AND c.subscriber_no = a.memo_subscriber
      AND a.memo_type = '0005'
      AND b.operator_id = a.operator_id
      AND b.cfr_activity_cd = 'CAN'
      AND (TO_CHAR(b.sys_creation_date, 'HH24:MI:SS')) = memo_time
      AND b.cfr_status = 'R';

   CREATE TABLE all_terms2
   AS
   SELECT a.*,
          name_title,
          first_name,
          middle_initial,
          last_business_name,
          adr_house_name,
          adr_house_no,
          adr_primary_ln,
          adr_secondary_ln,
          adr_district,
          adr_city,
          adr_county_name,
          adr_country,
          d.adr_post_code,
          e.bank_code,
          e.bank_acct_no
     FROM all_terms1 a,
          address_name_link b,
          name_data c,
          address_data d,
          billing_entity e
    WHERE b.ban = a.memo_ban
      AND b.link_type = 'T'
      AND b.expiration_date IS NULL
      AND c.name_id = b.name_id
      AND d.address_id = b.address_id
      AND e.ban = a.memo_ban
      AND e.ben = 1;

   CREATE TABLE all_terms3
   AS
   SELECT a.*,
          service_level
     FROM all_terms2 a,
          customer_relationship b
    WHERE b.customer_id (+) = a.memo_ban;

   SELECT memo_ban||'|'||
          memo_subscriber||'|'||
          memo_type||'|'||
          a.operator_id||'|'||
          memo_system_txt||'|'||
          memo_date||'|'||
          memo_time||'|'||
          memtp_memo_description||'|'||
          memtp_memo_category||'|'||
          memtp_manual_ind||'|'||
          name_title||'|'||
          first_name||'|'||
          middle_initial||'|'||
          last_business_name||'|'||
          adr_house_name||'|'||
          TRIM(adr_house_no)||'|'||
          adr_primary_ln||'|'||
          adr_secondary_ln||'|'||
          adr_district||'|'||
          adr_city||'|'||
          adr_county_name||'|'||
          adr_country||'|'||
          adr_post_code||'|'||
          sub_status||'|'||
          account_type||'|'||
          col_delinq_status||'|'||
          home_telno||'|'||
          service_level||'|'||
          bank_code||'|'||
          TRIM(bank_acct_no)||'|'||
          TRIM(cfr_p1)||'|'||
          cfr_p5
     FROM all_terms3 a,
          billing_account b,
          customer c
    WHERE b.ban = a.memo_ban
      AND c.customer_id = b.ban;

   spool off;

   DROP TABLE all_terms1;
   DROP TABLE all_terms2;
   DROP TABLE all_terms3;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\nAll Terminating Subscribers"
echo "---------------------------"
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
