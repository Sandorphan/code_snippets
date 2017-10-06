#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  All New Subscribers 
#  Description  :  Snapshot of all new subscribers for yesterday
#  Originator   :  Singlepoint  
#  Author       :  Phil Taylor
#  Date         :  28 September 2004 
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
# PT    | 28/09/2004| 2.1     | Initial version
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
          'Memo System Text',
          'Name Title',
          'First Name',
          'Middle Initial',
          'Last Name',
          'House Name',
          'House No',
          'Primary Ln',
          'Secondary Ln',
          'District',
          'City',
          'County Name',
          'Country',
          'Post Code',
          'Customer DOB',
          'Subscriber Status',
          'Account Type',
          'Delinq Status',
          'Home Tel No',
          'Customer Value',
          'Bank Sort Code',
          'Bank Account Number',
          'Commitment Start Date',
          'Commitment End Date',
          'Price Plan',
          'Price Plan Service Type',
          'Price Plan Description',
          'Price Plan Start Date',
          'Price Plan End Date',
          'Price Plan Rate',
          'Connection Channel'
     FROM dual;

   /****
   *  Query
   ****/
   CREATE TABLE new_subs1
   AS
   SELECT a.*,
          nd.name_title,
          nd.first_name,
          nd.middle_initial,
          nd.last_business_name,
          ad.adr_house_name,
          ad.adr_house_no,
          ad.adr_primary_ln,
          ad.adr_secondary_ln,
          ad.adr_district,
          ad.adr_city,
          ad.adr_county_name,
          ad.adr_country,
          ad.adr_post_code,
          c.home_telno,
          s.sub_status,
          TO_CHAR(s.commit_start_date, 'DD/MM/YYYY') commit_start_date,
          TO_CHAR(s.commit_end_date, 'DD/MM/YYYY') commit_end_date,
          ba.account_type,
          TO_CHAR(c.birth_date, 'DD/MM/YYYY') birth_date,
          ba.col_delinq_status,
          c.cntrct_num_of_ctns,
          ba.team_id,
          TO_CHAR(s.init_activation_date, 'DD/MM/YYYY') init_activation_date,
          NVL(s.initial_dealer_code, s.dealer_code) initial_dealer_code,
          be.bank_code,
          be.bank_acct_no,
          be.ben,
          be.dd_mandate_status,
          be.payment_method
     FROM short_memo a,
          subscriber s,
          name_data nd,
          address_data ad,
          address_name_link anl,
          customer c,
          billing_account ba,
          billing_entity be
    WHERE a.memo_subscriber = s.subscriber_no
      AND a.memo_ban = s.customer_id
      AND a.memo_type = '0002'
      AND s.subscriber_no = anl.subscriber_no
      AND s.customer_id = anl.ban
      AND nd.name_id = anl.name_id
      AND ad.address_id = anl.address_id
      AND c.customer_id = anl.customer_id
      AND anl.link_type = 'U'
      AND anl.sys_creation_date = (SELECT MAX (anl2.sys_creation_date)
                                     FROM address_name_link anl2
                                    WHERE anl.ban = anl2.ban
                                      AND anl.subscriber_no = anl2.subscriber_no
                                      AND anl2.link_type = 'U')
      AND (anl.expiration_date IS NULL OR anl.expiration_date > TRUNC(SYSDATE - 1))
      AND ba.ban = s.customer_id
      AND be.ban = s.customer_id
      AND be.ben = 1;

   CREATE TABLE new_subs2
   AS
   SELECT a.*,
          b.service_level
     FROM new_subs1 a,
          customer_relationship b
    WHERE b.customer_id (+) = a.memo_ban ;

   SELECT a.memo_ban||'|'||
          a.operator_id||'|'||
          a.memo_date||'|'||
          a.memo_time||'|'||
          a.memo_type||'|'||
          a.memo_subscriber||'|'||
          a.memo_system_txt||'|'||
          a.name_title||'|'||
          a.first_name||'|'||
          a.middle_initial||'|'||
          a.last_business_name||'|'||
          a.adr_house_name||'|'||
          TRIM(a.adr_house_no)||'|'||
          a.adr_primary_ln||'|'||
          a.adr_secondary_ln||'|'||
          a.adr_district||'|'||
          a.adr_city||'|'||
          a.adr_county_name||'|'||
          a.adr_country||'|'||
          a.adr_post_code||'|'||
          a.birth_date||'|'||
          a.sub_status||'|'||
          a.account_type||'|'||
          a.col_delinq_status||'|'||
          a.home_telno||'|'||
          a.service_level||'|'||
          a.bank_code||'|'||
          TRIM(a.bank_acct_no)||'|'||
          a.commit_start_date||'|'||
          a.commit_end_date||'|'||
          TRIM(b.soc)||'|'||
          b.service_type||'|'||
          TRIM(d.soc_description)||'|'||
          TO_CHAR(b.effective_date, 'DD/MM/YYYY')||'|'||
          TO_CHAR(b.expiration_date, 'DD/MM/YYYY')||'|'||
          f.rate||'|'||
          a.initial_dealer_code
     FROM new_subs2 a,
          service_agreement b,
          soc d,
          pp_rc_rate f
    WHERE b.subscriber_no = a.memo_subscriber 
      AND b.ban = a.memo_ban
      AND b.service_type <> 'B'
      AND b.service_type <> 'M'
      AND b.service_type <> 'S'
      AND (b.expiration_date IS NULL OR b.expiration_date > TRUNC(SYSDATE - 1))
      AND d.soc = b.soc
      AND(d.expiration_date IS NULL OR d.expiration_date > TRUNC(SYSDATE - 1))
      AND f.soc = b.soc
      AND f.tier_level_code IN (0, 1)
      AND(f.expiration_date IS NULL OR f.expiration_date > TRUNC(SYSDATE - 1));

   spool off;

   DROP TABLE new_subs1;
   DROP TABLE new_subs2;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\nAll New Subscribers"
echo "-------------------"
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
