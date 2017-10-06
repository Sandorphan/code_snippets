#!/bin/ksh 
#********************************************************************#
#  Organisation :  VODAFONE Ltd
#  Name         :  rep_000993
#  Description  :  Bill credit amounts driven from inherent price plans
#  Originator   :  IMO 542
#  Author       :  Saurabh Goyal
#  Date         :  
#
#  Parameters   :  
#
#  Runtime      :  <eg. 10 Minutes>
#  Notes        :  <Any relevant notes>
#********************************************************************#
#********************************************************************#
#  File Modification History
#********************************************************************#
# Inits | Date      | Version | Description
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
#DATE=$1

DATE=`date +%Y%m%d`

if [[ $# -eq 1 ]]
then
   DATE=$1
fi


SCRIPT_NAME=`basename $0`
REPORT_NAME=`get_report_name ${SCRIPT_NAME}`
#REPORT_NAME="${REPORT_NAME}_Daily_Bill_Credit_Extract"

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
DDL_FILE1="$TMP/ddl_${REPORT_NAME}_1.sql"
DDL_FILE2="$TMP/ddl_${REPORT_NAME}_2.sql"
PLSQL_FILE="$TMP/plsql_${REPORT_NAME}.sql"
INPUT_FILE="${INPUT_FILE:-$INPUT/${REPORT_NAME}.txt}"
OUTPUT_FILE="$OUTPUT/${REPORT_NAME}_${DATE}.csv"
#OUTPUT_FILE="$OUTPUT/Daily_Bill_Credit_Extract_${DATE}.csv"
TEMP_FILE="$OUTPUT/${REPORT_NAME}.csv"
ERROR_FILE="$TMP/${REPORT_NAME}.err"

#****
#  Data definition section
#****
echo "
   SET TIMING ON
   SPOOL ${ERROR_FILE}
   CREATE TABLE dummy_${REPORT_NAME} (
                  <Column 1>,
                  <Column 2>,
                  <Column 3>
                )
   STORAGE (INITIAL 1M NEXT 1M);
   SPOOL OFF
                                           
EXIT" > $DDL_FILE1

echo "
   DROP TABLE dummy_${REPORT_NAME};
EXIT" > $DDL_FILE2

#****
#  PL/SQL script
#****
echo "
   SET TIMING ON
   SET SERVEROUTPUT ON

   SPOOL ${ERROR_FILE}
   DECLARE 

      -- <Declaration Block>
      NULL;

   BEGIN
      DBMS_OUTPUT.ENABLE(20000);
      -- <Main Block>
      NULL;

   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SUBSTR('Error on ${PLSQL_FILE}: error code ',1,245)||SQLCODE);

   END;
/
SPOOL OFF
exit;" > $PLSQL_FILE

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
   *  Report header
   ****/
   
   /****
   *  Query header
   ****/
   set colsep'|';

   Select 'BAN','Sys_Creation_Date','Operator_ID','DL_Service_Code','ACTV_Reason_Code','ACTV_Date','ACTV_Amt','ACTV_Bill_Seq_No','Credit_Note_No','Memo_ID','Subscriber_No','SOC','Feature_Code','Source_Bill_Seq_No','Tax_Total_Amt' 
  From Dual;
   /****
   *  Query
   ****/
   
Select
	BAN,Sys_Creation_Date,Operator_ID,DL_Service_Code,ACTV_Reason_Code,
	ACTV_Date,ACTV_Amt,ACTV_Bill_Seq_No,Credit_Note_No,Memo_ID,
	Subscriber_No,SOC,Feature_Code,Source_Bill_Seq_No,Tax_Total_Amt		
FROM Adjustment
WHERE ACTV_Date = (trunc(to_date('$DATE','YYYYMMDD')) - 1);

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
#  Create result table
#****
#echo "\nrunning DDL. . ."
#SQLRun ${DDL_FILE2}
#SQLRun ${DDL_FILE1}
if [[ $? -gt 0 ]] then
   echo "Failure in "${DDL_FILE1}
   exit 1
fi
#****
#  Execute PL/SQL
#****
#echo "running PL/SQL. . ."
#SQLRun ${PLSQL_FILE}
if [[ $? -gt 0 ]] then
   echo "Failure in "${PLSQL_FILE}
   exit 1
fi

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
#  Drop result table
#****
#echo "tidying. . ."
#SQLRun ${DDL_FILE2}

#****
#  Remove Commas from the output file and then change colseps to comma
#****

echo "Removing Commas and Swapping Delimiter"
#sed 's/,/ /g' < $OUTPUT_FILE > $TEMP_FILE
#sed 's/|/,/g' < $TEMP_FILE > $OUTPUT_FILE

#echo "Zipping..."
#gzip -f $OUTPUT_FILE
#OUTPUT_FILE="${OUTPUT}/${REPORT_NAME}_$DATE.csv.gz"

today=`date +%d%m%y`
#mv $OUTPUT_FILE ${OUTPUT}/Weekly_Libra_BB_VBE_SOCs_${today}.csv

REPORT_FINISH_DATE=`date +%d-%m-%y\ %T`
echo "Report finished: $REPORT_FINISH_DATE"
echo 

echo ${REPORT_NAME}\|${REPORT_START_DATE}\|${REPORT_FINISH_DATE} >> ${REPORT_RUNTIMES}

#****
#  Tidy up
#****
/usr/bin/rm -f $SQL_FILE
/usr/bin/rm -f $DDL_FILE1
/usr/bin/rm -f $DDL_FILE2
/usr/bin/rm -f $PLSQL_FILE
/usr/bin/rm -f $TEMP_FILE
/usr/bin/rm -f $ERROR_FILE
