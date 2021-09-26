# ----------------------------------------------------------------
# DeVato-DM_DDL_STTM_Comparison_Process.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
. initrc_DeVato
 
log_file="$log_dir/DDL_Comparision_Process.log"
>$log_file
##Log Header
 
        echo "************************************************************************************" >> $log_file
        START_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "Start of DDL Comparision Process: - "$START_TIME_STAMP >> $log_file
        echo "************************************************************************************" >> $log_file
 
##############################################################################
#
#    Subroutine     : Log_Entry
#    Purpose        : Logging file execution progress through the subroutine
#    Parameters     : Log message
#    Return Values  : None
#
##############################################################################
Log_Entry()
{
        Message="$1" 
        echo "$Message" >> $log_file
        echo "" >> $log_file
} # End of Log_Entry()
 
 
##############################################################################
#
#    Subroutine     : log_footer
#    Purpose        : Writing footer notes end of the log file.
#    Parameters     : None
#    Return Values  : None
#
##############################################################################
log_footer()
{
        echo -e "\n" >> $log_file
        echo "************************************************************************************" >> $log_file
        END_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "End of DDL Comparision Process: - "$END_TIME_STAMP >> $log_file
        echo "************************************************************************************" >> $log_file
} # End of log_footer
 
procfile="$temp_dir/Start_Process_1"
procInd=`cat $procfile|awk '{ print $0 }'`
 
if [[ $procInd == "Manual" ]];
then
     Log_Entry "Manuval Process Flow is Defined in OUTPUT_Configuration tab . DDL Comparsion Not Applicable for Mauval Process"
        log_footer
        exit 0
fi
 
##############################################################################
#
#    Subroutine     : dm_prd_metadata_load
#    Purpose        : Creating ddl's and preparing Metadata list
#    Parameters     : None
#    Return Values  : None
##############################################################################
dm_prd_metadata_load()
{
Log_Entry "--------------------------------------------------"
Log_Entry "DM PRD DDLs Creation and Generating Metatdata Started "
Log_Entry "--------------------------------------------------"
ddlconfigfile="$temp_dir/DDL_Configuration.csv"
Log_Entry "          1. Combining all list of DM DDls - Started"
ComDDLFile="$temp_dir/Complete_DDL_File.ddl"
>$ComDDLFile
while read line
do
 
fileName=`echo $line|awk -F "|" '{ print $1 }'`
fileType=`echo $line|awk -F "|" '{ print $2 }'`
 
if [[ $fileType == "DDL" ]];
then
filebase="$source_dir/$fileName"
cat $filebase >> $ComDDLFile
fi
done <$ddlconfigfile
 
dos2unix $ComDDLFile
 
grep -w "CREATE" $ComDDLFile|sed 's/(/ /g'|awk -v qt="'" '{ print qt $3 qt "," }' > $temp_dir/Temp_01_DM_table_list.txt
grep -w "CREATE" $ComDDLFile|sed 's/(/ /g'|awk  '{ print $3 }' > $temp_dir/Temp_DM_table_list.txt
grep -w "CREATE" $ComDDLFile|sed 's/(/ /g'|awk  '{ print "DROP TABLE " $3 " IF EXISTS;" }' > $temp_dir/Temp_Drop_DM_table_list.txt
lastRecord=`awk 'END{ print NR }' $temp_dir/Temp_01_DM_table_list.txt`
awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub(",","",$0); print $0 }' $temp_dir/Temp_01_DM_table_list.txt>$temp_dir/Temp_02_DM_table_list.txt
echo "(" > $temp_dir/DM_tables.list
cat $temp_dir/Temp_02_DM_table_list.txt >> $temp_dir/DM_tables.list
echo ")" >> $temp_dir/DM_tables.list
 
CmdDMTableList=`cat $temp_dir/DM_tables.list`
 
Log_Entry "          1. Combining all list of DM DDls - Completed"
Log_Entry "          2. DM DDL Execution in Tempdb - Starting"
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} -f $ComDDLFile -O $log_dir/DDL_Execution_Results.out
 
 
erCnt=`grep "ERROR:" $log_dir/DDL_Execution_Results.out|grep -E "CREATE|ALTER"|wc -l`
 
if [ $erCnt -eq 0 ];
then
    Log_Entry "          3. DM DDL Execution in Tempdb - Completed"
else
    Log_Entry "          3. DM DDL Execution in Tempdb - Failed, due to NZSQL Error"
        Log_Entry "                  so Dropping Created Tables"
cmdDropDM=`cat $temp_dir/Temp_Drop_DM_table_list.txt`
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF >> $log_file
        ${cmdDropDM}
;
EOF
    log_footer
    exit 1;
fi;
 
Log_Entry "          3. Preparing Metadata list for DM - Started"
 
nzsql -r -A -t -F '|' -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/DM_System_Tables_Columns.csv
 
        SELECT
      NAME
     ,ATTNAME
     ,FORMAT_TYPE
     ,CAST(ATTNOTNULL AS VARCHAR(50)) ATT_NOT_NULL
     ,COLDEFAULT AS DEFAULT_VALUE
FROM _v_relation_column WHERE name IN
${CmdDMTableList}
;
EOF
 
if [ $? -eq 0 ];
then
    Log_Entry "          3. Preparing Metadata list for DM - Completed"
else
    Log_Entry "          3. Preparing Metadata list for DM - Failed, due to NZSQL Error"
    log_footer
    exit 1;
fi;
 
Log_Entry "          4. Prod Medata DDL to CSV Generation - Started"
 
python3 $script_dir/DeVato-PRD-PYTHON-Excel_CSV.py $source_dir/ "PRD_METADATA_DDL.xlsx"  $temp_dir/ "PRD_System_Tables_Columns.csv"
 
if [ $? -eq 0 ];
then
    Log_Entry "          4. Prod Medata DDL to CSV Generation - Completed"
else
   Log_Entry "          4. Prod Medata DDL to CSV Generation - Failed, dut to Python Error"
    log_footer
    exit 1;
fi;
 
Log_Entry "--------------------------------------------------"
Log_Entry "DM PRD DDLs Creation and Generating Metatdata Completed"
Log_Entry "--------------------------------------------------"
}
 
##############################################################################
#
#    Subroutine     : dm_prd_stg_ddl_creation
#    Purpose        : Creating Stage Tables for Metadata List
#    Parameters     : None
#    Return Values  : None
##############################################################################
dm_prd_stg_ddl_creation()
{
Log_Entry "-----------------------------------------"
Log_Entry "   DM PRD STG DDL Creation - Started     "
Log_Entry "-----------------------------------------"
Log_Entry "          1. Creating Stage DDL for DM - Started"
 
cmdStgDmDDL=`cat $config_dir/STG_DM.ddl`
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF
 
${cmdStgDmDDL}
 
EOF
 
if [ $? -eq 0 ];
then
    Log_Entry "          1. Creating Stage DDL for DM - Completed"
else
    Log_Entry "          1. Creating Stage DDL for DM - Failed due to NZSQL Error"
    log_footer
    exit 1;
fi;
 
Log_Entry "          2. Creating Stage DDL for PRD - Started"
 
cmdStgPrdDDL=`cat $config_dir/STG_PRD.ddl`
 
nzsql -r -A -t  -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF
 
${cmdStgPrdDDL}
 
EOF
 
if [ $? -eq 0 ];
then
    Log_Entry "          2. Creating Stage DDL for PRD - Completed"
else
    Log_Entry "          2. Creating Stage DDL for PRD - Failed due to NZSQL Error"
    log_footer
    exit 1;
fi;
 
Log_Entry "-----------------------------------------"
Log_Entry "   DM PRD STG DDL Creation - Completed   "
Log_Entry "-----------------------------------------"
}
 
##############################################################################
#
#    Subroutine     : dm_prd_metadata_stg_load
#    Purpose        : dm pro medata loading to stage
#    Parameters     : none
#    Return Values  : None
##############################################################################
dm_prd_metadata_stg_load()
{
Log_Entry "-------------------------------------------------------"
Log_Entry "   Loading DM PRD Metadata DDL to STG Table -Started "
Log_Entry "-------------------------------------------------------"
 
dmSouceFile="$temp_dir/DM_System_Tables_Columns.csv"
prdSouceFile="$temp_dir/PRD_System_Tables_Columns.csv"
dmStageTable="STG_DEV_AUTO_DM_DDL"
prdStageTable="STG_DEV_AUTO_PRD_DDL"
 
Log_Entry "              1. $dmStageTable Load - Started "
 
nzload -db ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} -t ${dmStageTable} -delim '|' -df ${dmSouceFile} -outputDir ${log_dir}
 
if [ $? -eq 0 ];
then
    Log_Entry "              1. $dmStageTable Load - Completed "
else
    Log_Entry "              1. $dmStageTable Load - Failed, Please verify the Log "
    log_footer
    exit 1;
fi;
 
Log_Entry "              2. $prdStageTable Load - Started "
nzload -db ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} -t ${prdStageTable} -delim '|' -df ${prdSouceFile} -outputDir ${log_dir}
 
if [ $? -eq 0 ];
then
    Log_Entry "              2. $prdStageTable Load - Completed "
else
    Log_Entry "              2. $prdStageTable Load - Failed, Please verify the Log "
    log_footer
    exit 1;
fi;
 
Log_Entry "-------------------------------------------------------"
Log_Entry "   Loading DM PRD Metadata DDL to STG Table -Completed "
Log_Entry "-------------------------------------------------------"
}
 
##############################################################################
#
#    Subroutine     : sttm_metadata_load
#    Purpose        : STTM excel to Medata CSV
#    Parameters     : none
#    Return Values  : None
##############################################################################
sttm_metadata_load()
{
Log_Entry "-----------------------------------------"
Log_Entry "   STTM Metadata Creation - Started "
Log_Entry "-----------------------------------------"
 
while read line
do
fileName=`echo $line|awk -F "|" '{ print $1}'`
sheetName=`echo $line|awk -F "|" '{ print $2}'`
columnsList=`echo $line|awk -F "|" '{ print $3}'`
HeaderStart=`echo $line|awk -F "|" '{ print $4}'`
 
Log_Entry "              $fileName Metadata Creation - Started "
 
python3 $script_dir/DeVato-STTM-PYTHON-Excel_CSV.py $source_dir/ $fileName $sheetName $columnsList $HeaderStart $temp_dir/ "STTM_System_Tables_Columns.csv"
 
if [ $? -eq 0 ];
then
    Log_Entry "              $fileName Metadata Creation - Completed "
else
    Log_Entry "              $fileName Metadata Creation - Failed, due to Python Error "
    log_footer
    exit 1;
fi;
 
done < $temp_dir/STTM_Configuration.csv
 
Log_Entry "-----------------------------------------"
Log_Entry "   STTM Metadata Creation - Completed "
Log_Entry "-----------------------------------------"
}
 
 
##############################################################################
#
#    Subroutine     : sttm_stg_ddl_creation
#    Purpose        : Creating Stage Tables for Metadata List
#    Parameters     : None
#    Return Values  : None
##############################################################################
sttm_stg_ddl_creation()
{
Log_Entry "-----------------------------------------"
Log_Entry "   STTM STG DDL Creation - Started       "
Log_Entry "-----------------------------------------"
 
Log_Entry "          1. STTM STG DDL Creation - Started"
 
cmdStgSttmDDL=`cat $config_dir/STG_STTM.ddl`
 
nzsql -r -A -t -F ',' -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF
 
${cmdStgSttmDDL}
 
EOF
 
if [ $? -eq 0 ];
then
    Log_Entry "          2. STTM STG DDL Creation - Completed"
else
    Log_Entry "          2. STTM STG DDL Creation - Failed , due to NZSQL Error"
    log_footer
    exit 1;
fi;
 
Log_Entry "-----------------------------------------"
Log_Entry "   STTM STG DDL Creation - Completed     "
Log_Entry "-----------------------------------------"
}
 
##############################################################################
#
#    Subroutine     : sttm_metadata_stg_load
#    Purpose        : sttm medata loading to stage
#    Parameters     : none
#    Return Values  : None
##############################################################################
sttm_metadata_stg_load()
{
Log_Entry "-------------------------------------------------------"
Log_Entry "   Loading STTM Metadata DDL to STG Table -Started "
Log_Entry "-------------------------------------------------------"
 
sttmSouceFile="$temp_dir/STTM_System_Tables_Columns.csv"
sttmStageTable="STG_DEV_AUTO_STTM_DDL"
 
Log_Entry "              1. $sttmStageTable Load - Started "
nzload -db ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} -t ${sttmStageTable} -delim '|' -df ${sttmSouceFile} -outputDir ${log_dir}
 
if [ $? -eq 0 ];
then
    Log_Entry "              1. $sttmStageTable Load - Completed "
else
    Log_Entry "              1. $sttmStageTable Load - Failed, Please verify the Log "
    log_footer
    exit 1;
fi;
 
Log_Entry "-------------------------------------------------------"
Log_Entry "   Loading STTM Metadata DDL to STG Table -Completed "
Log_Entry "-------------------------------------------------------"
}
 
##############################################################################
#
#    Subroutine     : dm_prod_ddl_comp_report
#    Purpose        : DM PROD DDL Comparision Report Generation
#    Parameters     : none
#    Return Values  : None
##############################################################################
dm_prod_ddl_comp_report()
{
Log_Entry "-------------------------------------------------------"
Log_Entry "   DM PROD DDL Comparision Report Generation -Started  "
Log_Entry "-------------------------------------------------------"
 
ddlCompareQuery=`cat $config_dir/ddl_compare.sql`
 
Log_Entry "          1. DM DDL Comparision Report Generation - Started"
 
nzsql -r -A -F '|' -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $report_dir/DM_PRD_DDL_Comparision.csv
 
${ddlCompareQuery}
 
EOF
 
if [ $? -eq 0 ];
then
    Log_Entry "          1. DM DDL Comparision Report Generation - Completed"
else
    Log_Entry "          1. DM DDL Comparision Report Generation - Failed, due to NZSQL Error"
    log_footer
    exit 1;
fi;
Log_Entry "-------------------------------------------------------"
Log_Entry "   DM PROD DDL Comparision Report Generation -Completed "
Log_Entry "-------------------------------------------------------"
}
 
##############################################################################
#
#    Subroutine     : dm_prod_sstm_ddl_comp_report
#    Purpose        : DM PROD STTM DDL Comparision Report Generation
#    Parameters     : none
#    Return Values  : None
##############################################################################
dm_prod_sstm_ddl_comp_report()
{
Log_Entry "-------------------------------------------------------"
Log_Entry "   DM PROD STTM DDL Comparision Report Generation -Started  "
Log_Entry "-------------------------------------------------------"
 
ddlSttmCompareQuery=`cat $config_dir/ddl_sttm_compare.sql`
 
Log_Entry "          1. DM PROD STTM DDL Comparision Report Generation - Started"
 
nzsql -r -A -F '|' -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $report_dir/DM_PRD_STTM_DDL_Comparision.csv
 
${ddlSttmCompareQuery}
 
EOF
 
if [ $? -eq 0 ];
then
    Log_Entry "          1. DM PROD STTM DDL Comparision Report Generation - Completed"
else
    Log_Entry "          1. DDM PROD STTM DDL Comparision Report Generation - Failed, due to NZSQL Error"
    log_footer
    exit 1;
fi;
Log_Entry "-------------------------------------------------------"
Log_Entry "   DM PROD STTM DDL Comparision Report Generation -Completed  "
Log_Entry "-------------------------------------------------------"
}
 
flowfile="$temp_dir/Process.Flow"
 
process_ind=`awk -F "|" '{ print $4 }' $flowfile |uniq`
 
if [[ $process_ind ==  "Automatic" ]];
then
      dm_prd_metadata_load
fi
 
while read line
do
projName=`echo $line |awk -F "|" '{ print $1 }'`
ruleType=`echo $line |awk -F "|" '{ print $2 }'`
ruleInd=`echo $line |awk -F "|" '{ print $3 }'`
procInd=`echo $line |awk -F "|" '{ print $4 }'`
 
if [[ $procInd == "Automatic" ]];
then
 
       if [[ $ruleType == "DM_PROD_DDL_COMPARISON" ]];
           then
                 dm_prd_stg_ddl_creation
                 dm_prd_metadata_stg_load
                 dm_prod_ddl_comp_report
       fi         
       if [[ $ruleType == "DM_PROD_DDL_STTM_COMPARISON" ]];
           then
                 sttm_metadata_load
                 sttm_stg_ddl_creation
                 sttm_metadata_stg_load
                 dm_prod_sstm_ddl_comp_report
       fi
fi        
  
done < $flowfile
log_footer
