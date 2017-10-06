#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  Commitment Change Report
#  Description  :  Report on previous day's upgrades
#  Originator   :  Wayne Fraser
#  Author       :  Keith Brown
#  Date         :  03 October 2005
#
#  Parameters   :  Date
#
#  Runtime      :  <eg. 10 Minutes>
#  Notes        :  <Any relevant notes>
#********************************************************************#
#********************************************************************#
#  File Modification History
#********************************************************************#
# Inits | Date      | Version | Description
#********************************************************************#
#  KB   | 04/10/05  |  1.0    | Initial version
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
   set lin 1000   
   col f1 format 999999990.00
   spool $OUTPUT_FILE
  
   /****
   *  Query header
   ****/
   set colsep'|';
   SELECT ' Seq_no ',
          ' Sys_creation_date ',
          ' Sys_update_date ',
          ' Operator_id ',
          ' Application_id ',
          ' Dl_service_code ',
          ' Dl_update_stamp ',
          ' Ban ',
          ' Subscriber_no ',
          ' Upg_date ',
          ' Upg_act ',
          ' Upg_rsn ',
          ' New_com_start_date ',
          ' New_com_end_date '
   FROM   dual;
 
   /****
   *  Query
   ****/
   SELECT seq_no,
          TO_CHAR(sys_creation_date,'YYYYMMDD'),
          TO_CHAR(sys_update_date,'YYYYMMDD'),
          operator_id,
          application_id,
          dl_service_code,
          dl_update_stamp,
          ban,
          subscriber_no,
          TO_CHAR(upg_date,'YYYYMMDD'),
          upg_act,
          upg_rsn,
          TO_CHAR(new_com_start_date,'YYYYMMDD'),
          TO_CHAR(new_com_end_date,'YYYYMMDD')
     FROM upgrade_history
    WHERE TO_CHAR(sys_creation_date,'YYYYMMDD') = ${DATE};

   spool off;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\n Commitment Change Report"
echo "-------------------------------"
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

#****
#  Remove Commas from the output file and then change colseps to comma
#****

echo "Removing Commas and Swapping Delimiter"
sed 's/,/ /g' < $OUTPUT_FILE > $TEMP_FILE
sed 's/|/,/g' < $TEMP_FILE > $OUTPUT_FILE

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
