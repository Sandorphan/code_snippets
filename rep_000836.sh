#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  User information 
#  Description  :  One record per user
#  Originator   :  Singlepoint
#  Author       :  Aiysha Armstrong
#  Date         :  16 July 2004 
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
# AA    | 16/07/2004| 2.1     | Initial version
# AA    | 29/07/2004| 2.2     | zip output file 
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
   set lin 1000   
   set colsep' '; 
   col f1 format 999999990.00
   spool $OUTPUT_FILE
   

   /****
   *  Query header
   ****/
   set colsep'|';
   SELECT ' User ID ',
          ' User name ',
	  ' Job function',
          ' Department '
   FROM   dual;

   /****
   *  Query
   ****/
   SELECT UNIQUE a.user_id,
          a.user_full_name,
          d.func_function_description,
          e.dprt_department_description
   FROM users a,
        work_position_assignment b,
        work_position c,
        function d,
        department e
   WHERE b.wpasn_user_id = a.user_id
   AND c.wp_work_position_code = b.wpasn_work_position_code
   AND d.func_function_code = c.wp_function_code
   AND e.dprt_department_code = d.func_department_code
   AND a.user_expiration_date IS NULL
   AND b.wpasn_expiration_date IS NULL
   AND c.wp_expiration_date IS NULL;


   spool off;

exit;" > $SQL_FILE

#****
#  Time and run query
#****
REPORT_START_DATE=`date +%d-%m-%y\ %T`
echo "\n <Report Description / Header>"
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
