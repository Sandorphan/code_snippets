#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  Termination Retractions
#  Description  :  All subscribers that have retracted their termination in the current month to date
#  Originator   :  Singlepoint
#  Author       :  Aiysha Armstrong
#  Date         :  07/09/2004
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
# AA    | 25/06/2004| 2.1     | Initial version
# AA    | 08/07/2004| 2.2     | Modify SQl and change date format and make files pipe delimited 
# AA    | 08/07/2004| 2.3     | Modify text in report header
# AA    | 19/07/2004| 2.4     | remove header 
# AA    | 29/07/2004| 2.5     | zip output file 
# AW    | 04/08/2004| 2.6     | change to utilise memo table for creation of term_retract_temp1 table
# PT    | 06/09/2004| 2.9     | change to extract all subscribers (not just active as previous)
# PT    | 07/09/2004| 2.10    | change to utilise short_memo table created by report 863
# JL    | 04/05/2009| 2.11    | Add memo_id to the extract
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
	  'Memo ID'
   FROM   dual;

   /****
   *  Query
   ****/

   SELECT memo_ban||'|'||
          memo_subscriber||'|'||
          memo_type||'|'||
          operator_id||'|'||
          memo_system_txt||'|'||
          memo_date||'|'||
          memo_time||'|'||
          memtp_memo_description||'|'||
          memtp_memo_category||'|'||
          memtp_manual_ind||'|'||
          memo_id
     FROM short_memo;

   spool off;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\nTermination Retractions"
echo "-----------------------"
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
