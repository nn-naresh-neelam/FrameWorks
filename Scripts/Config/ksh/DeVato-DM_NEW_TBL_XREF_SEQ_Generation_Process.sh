# ----------------------------------------------------------------
# DeVato-DM_NEW_TBL_XREF_SEQ_Generation_Process.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. initrc_DeVato
 
log_file="$log_dir/DM_NEW_TBL_XREF_SEQ_Generation.log"
>$log_file
##Log Header
 
        echo "************************************************************************************" >> $log_file
        START_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "Start of DM NEW TBL XREF SEQ Generation: - "$START_TIME_STAMP >> $log_file
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
        echo "End of DM NEW TBL XREF SEQ Generation: - "$END_TIME_STAMP >> $log_file
        echo "************************************************************************************" >> $log_file
} # End of log_footer
 
##############################################################################
#
#    Subroutine     : xref_seq_ddl_preparation
#    Purpose        : Creating xref and SEQ
#    Parameters     : PROJECTNAME
#    Return Values  : None
##############################################################################
xref_seq_ddl_preparation()
{
projectName=${1}
loadInd=${2}
current_date=`date '+%Y-%b-%d'`
Log_Entry "--------------------------------------------------"
Log_Entry "XREF SEQ DDL Preparation Started                     "
Log_Entry "--------------------------------------------------"
 
if [[ $loadInd == "INDIV" ]];
then
        while read line
        do
        tablename=`echo ${line}_XREF`
                orgtable=`echo $line`
        Log_Entry "                DDL Started for : $tablename                    "
       
        tgtDdlFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_SRC_"$tablename"_DDL.sql"
       
        echo "-----------------------------------------------------------------------" >$tgtDdlFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtDdlFile
        echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $tablename" >> $tgtDdlFile
        echo "--Developer    :   $DEV_USER" >> $tgtDdlFile
        echo "--Created Date :   $current_date" >> $tgtDdlFile
        echo "-----------------------------------------------------------------------" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        Log_Entry "                        Header Generated : $tablename                    "
        echo "DROP TABLE $tablename IF EXISTS;" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        echo "CREATE TABLE $tablename" >> $tgtDdlFile
        echo "(" >> $tgtDdlFile
        awk -v con="$orgtable" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/DM_XREF_DDL.ddl >> $tgtDdlFile
               
                cat $config_dir/xref_audit.2nd >> $tgtDdlFile
        echo " " >>$tgtDdlFile
        echo ")" >>$tgtDdlFile
                echo "DISTRIBUTE ON RANDOM;" >>$tgtDdlFile
                echo " " >>$tgtDdlFile
       Log_Entry "                        Columns Generated : $tablename                    "
        Log_Entry "                        DDL Generation Completed : $tablename                    "
               
                tablename=`echo ${line}_SEQ`
                        Log_Entry "                SEQ DDL Started for : $tablename                    "
        tgtDdlFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_SRC_"$tablename"_DDL.sql"
       
        echo "-----------------------------------------------------------------------" >$tgtDdlFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtDdlFile
        echo "--Purpose      :   ONE TIME TABLE CREATION SEQ DDL SCRIPT FOR $tablename" >> $tgtDdlFile
        echo "--Developer    :   $DEV_USER" >> $tgtDdlFile
        echo "--Created Date :   $current_date" >> $tgtDdlFile
        echo "-----------------------------------------------------------------------" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        Log_Entry "                        Header Generated : $tablename                    "
        echo "CREATE SEQUENCE $tablename" >> $tgtDdlFile
               
                cat $config_dir/seq_gen.2nd >> $tgtDdlFile
      
        echo ";" >>$tgtDdlFile
                echo " " >>$tgtDdlFile
        Log_Entry "                        SEQ DDL Generated : $tablename                    "
               
done < $temp_dir/DM_XREF_List.csv
fi
 
if [[ $loadInd == "COMBINED" ]]
then
        tgtDdlFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_SRC_XREF_DDL.sql"
        >$tgtDdlFile
            tgtSeqFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_SRC_SEQ_DDL.sql"
        >$tgtSeqFile
                echo "-----------------------------------------------------------------------" >>$tgtDdlFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtDdlFile
        echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $projectName" >> $tgtDdlFile
        echo "--Developer    :   $DEV_USER" >> $tgtDdlFile
        echo "--Created Date :   $current_date" >> $tgtDdlFile
        echo "-----------------------------------------------------------------------" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
               
                echo "-----------------------------------------------------------------------" >$tgtSeqFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtSeqFile
        echo "--Purpose      :   ONE TIME TABLE CREATION SEQ DDL SCRIPT FOR $projectName" >> $tgtSeqFile
        echo "--Developer    :   $DEV_USER" >> $tgtSeqFile
        echo "--Created Date :   $current_date" >> $tgtSeqFile
        echo "-----------------------------------------------------------------------" >> $tgtSeqFile
        echo "" >> $tgtSeqFile
        Log_Entry "                        Combined DDL Started                    "
               
                while read line
        do
        tablename=`echo ${line}_XREF`
                orgtable=`echo $line`
        Log_Entry "                DDL Started for : $tablename                    "
  
        echo "DROP TABLE $tablename IF EXISTS;" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        echo "CREATE TABLE $tablename" >> $tgtDdlFile
                echo "(" >>$tgtDdlFile
       
        awk -v con="$orgtable" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/DM_XREF_DDL.ddl >> $tgtDdlFile
               
                cat $config_dir/xref_audit.2nd >> $tgtDdlFile
        echo " " >>$tgtDdlFile
        echo ")" >>$tgtDdlFile
                echo "DISTRIBUTE ON RANDOM;" >>$tgtDdlFile
                echo " " >>$tgtDdlFile
                tablename=`echo ${line}_SEQ`
                echo "CREATE SEQUENCE $tablename" >> $tgtSeqFile
               
                cat $config_dir/seq_gen.2nd >> $tgtSeqFile
      
        echo ";" >>$tgtSeqFile
                echo " " >>$tgtSeqFile
               
                done < $temp_dir/DM_XREF_List.csv
                Log_Entry "                        Combined DDL Completed                    "
fi
Log_Entry "--------------------------------------------------"
Log_Entry "XREF SEQ DDL Preparation Completed                "
Log_Entry "--------------------------------------------------"
}
 
flowfile="$temp_dir/Process.Flow"
 
procInd=`awk -F "|" '{ print $4 }' $flowfile|uniq`
projName=`awk -F "|" '{ print $1 }' $flowfile|uniq`
 
if [[ $procInd == "Automatic" ]];
then
databasename=`awk -F "|" '{ print $3 }' $temp_dir/DDL_Configuration.csv |uniq`
Log_Entry " --------Automatic Process Found---------- "
 
Log_Entry "                 Checking For New Tables..... "
 
XreffileList=$temp_dir/DM_XREF_List.csv
 
xrefListQry=`cat $config_dir/XREF_List_Gen.sql`
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $XreffileList
 
        ${xrefListQry}
;
EOF
 
cnt=`cat $XreffileList|wc -l`
 
           if [ $cnt -eq 0 ];
           then
           Log_Entry "                 No New Table Found..... "
           log_footer
                   exit 0
                   fi
Log_Entry "                 New Tables Found "
Log_Entry "                 Generating Primary and Uniq Key Column List "
 
XrefGenFile=$temp_dir/DM_XREF_DDL.ddl
 
xrefGenQry=`cat $config_dir/XREF_Gen.sql`
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $XrefGenFile
 
        ${xrefGenQry}
;
EOF
 
Log_Entry "                 Primary and Uniq Key Column List are generated "
else
Log_Entry " --------Automatic Process Not Found---------- "
log_footer
exit 0
fi
 
while read line
do
projName=`echo $line |awk -F "|" '{ print $1 }'`
ruleType=`echo $line |awk -F "|" '{ print $2 }'`
ruleInd=`echo $line |awk -F "|" '{ print $3 }'`
procInd=`echo $line |awk -F "|" '{ print $4 }'`
 
if [[ $procInd == "Automatic" ]];
then
       
       if [[ $ruleType == "DM_NEW_TBL_XREF_SEQ-INDIVID_DDL" ]];
           then
             xref_seq_ddl_preparation $projName "INDIV"
       fi         
       if [[ $ruleType == "DM_NEW_TBL_XREF_SEQ-COMBINED_DDL" ]];
          then
             xref_seq_ddl_preparation $projName "COMBINED"
       fi
fi        
 
done < $flowfile
log_footer# ----------------------------------------------------------------
# Dev_Automation-DM_TGT_TDM_DDL_Generation_Process.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. /nfs/rosetld/scripts/ksh/Dev_Automation/.initrc_Dev_Automation
 
log_file="$log_dir/DM_TGT_TDM_DDL_Generation.log"
>$log_file
##Log Header
 
        echo "************************************************************************************" >> $log_file
        START_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "Start of DM TGT TDM DDL Generation: - "$START_TIME_STAMP >> $log_file
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
        echo "End of DM TGT TDM DDL Generation: - "$END_TIME_STAMP >> $log_file
        echo "************************************************************************************" >> $log_file
} # End of log_footer
 
##############################################################################
#
#    Subroutine     : dm_ddl_generation
#    Purpose        : Creating dm ddl's
#    Parameters     : PROJECTNAME
#    Return Values  : None
##############################################################################
dm_ddl_generation()
{
projectName=${1}
 
Log_Entry "--------------------------------------------------"
Log_Entry "Target DDL Preparation Started                     "
Log_Entry "--------------------------------------------------"
 
Log_Entry "                1. All Columns are Generating .....            "
 
cmdDdlGen=`cat $config_dir/DDL_Gen.sql`
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/$projectName"_"$databasename"_TGT_ddl.ddl"
 
        ${cmdDdlGen}
;
EOF
 
Log_Entry "                1. All Columns are Generation Completed. "
 
cmdDdlGenCom=`cat $config_dir/DDL_Gen_Comments.sql`
 
Log_Entry "                2. All Column Descriptions are Generating.... "
 
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/$projectName"_"$databasename"_TGT_ddl.descriptions"
 
        ${cmdDdlGenCom}
;
EOF
 
Log_Entry "                2. All Column Descriptions are Completed. "
Log_Entry "                3. All Keys are generating..... "
cmdDdlGenKeys=`cat $config_dir/DDL_Gen_Keys.sql`
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/$projectName"_"$databasename"_TGT_ddl.PkFkUkkeys"
 
        ${cmdDdlGenKeys}
;
EOF
 
Log_Entry "                3. All Keys are generation Completed. "
Log_Entry "                4. All Distributed and Organized Columns are generating...... "
cmdDdlDistOrgKeys=`cat $config_dir/DDL_Gen_Dist_Org.sql`
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/$projectName"_"$databasename"_TGT_ddl.DistOrgKeys"
 
        ${cmdDdlDistOrgKeys}
;
EOF
 
Log_Entry "                4. All Distributed and Organized Columns are generation Completed. "
}
##############################################################################
#
#    Subroutine     : tgt_ddl_preparation
#    Purpose        : Creating dm ddl's
#    Parameters     : PROJECTNAME
#    Return Values  : None
##############################################################################
tgt_ddl_preparation()
{
projectname=${1}
loadInd=${2}
current_date=`date '+%Y-%b-%d'`
 
if [[ $loadInd == "INDIV" ]];
then
        while read line
        do
        tablename=`echo $line`
        Log_Entry "                DDL Started for : $tablename                    "
       
        tgtDdlFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_TGT_"$tablename"_DDL.sql"
       
        echo "-----------------------------------------------------------------------" >$tgtDdlFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtDdlFile
        echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $tablename" >> $tgtDdlFile
        echo "--Developer    :   $DEV_USER" >> $tgtDdlFile
        echo "--Created Date :   $current_date" >> $tgtDdlFile
        echo "-----------------------------------------------------------------------" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        Log_Entry "                        Header Generated : $tablename                    "
        echo "DROP TABLE $tablename IF EXISTS;" >> $tgtDdlFile
       echo "" >> $tgtDdlFile
        echo "CREATE TABLE $tablename (" >> $tgtDdlFile
       
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.ddl" > $temp_dir/select_temp.ddl
        
        lastRecord=`awk 'END{ print NR }' $temp_dir/select_temp.ddl`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub(",","",$0); print $0 }' $temp_dir/select_temp.ddl>>$tgtDdlFile
        echo ")" >>$tgtDdlFile
        Log_Entry "                        Columns Generated : $tablename                    "
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.DistOrgKeys" >>$tgtDdlFile
        echo ";" >>$tgtDdlFile
        Log_Entry "                        Distributed and Organized keys are Generated : $tablename                    "
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.PkFkUkkeys" >>$tgtDdlFile
        Log_Entry "                        PK, FK and UK's are Generated : $tablename                    "
                echo " " >>$tgtDdlFile
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.descriptions"|sed "s/ÃŠ/'/g"|sed 's/Ã¢/\n/g'|sed "s/Ãª/''/g" >>$tgtDdlFile
        Log_Entry "                        Column descriptions are Generated : $tablename                    "
        Log_Entry "                        DDL Generation Completed : $tablename                    "
done < $temp_dir/Temp_DM_table_list.txt
fi
 
if [[ $loadInd == "COMBINED" ]]
then
        tgtDdlFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_TGT_DDL.sql"
        >$tgtDdlFile
                echo "-----------------------------------------------------------------------" >>$tgtDdlFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtDdlFile
        echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $projectName" >> $tgtDdlFile
        echo "--Developer    :   $DEV_USER" >> $tgtDdlFile
        echo "--Created Date :   $current_date" >> $tgtDdlFile
        echo "-----------------------------------------------------------------------" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        Log_Entry "                        Combined DDL Started                    "
               
                while read line
        do
        tablename=`echo $line`       
        echo "DROP TABLE $tablename IF EXISTS;" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        echo "CREATE TABLE $tablename (" >> $tgtDdlFile
       
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.ddl" > $temp_dir/select_temp.ddl
        
        lastRecord=`awk 'END{ print NR }' $temp_dir/select_temp.ddl`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub(",","",$0); print $0 }' $temp_dir/select_temp.ddl>>$tgtDdlFile
        echo ")" >>$tgtDdlFile
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.DistOrgKeys" >>$tgtDdlFile
        echo ";" >>$tgtDdlFile
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.PkFkUkkeys" >>$tgtDdlFile
                echo " " >>$tgtDdlFile
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_TGT_ddl.descriptions"|sed "s/ÃŠ/'/g"|sed 's/Ã¢/\n/g'|sed "s/Ãª/''/g" >>$tgtDdlFile
                echo " " >>$tgtDdlFile
done < $temp_dir/Temp_DM_table_list.txt
        Log_Entry "                        Combined DDL Completed                    "
fi
Log_Entry "--------------------------------------------------"
Log_Entry "Target DDL Preparation Completed                     "
Log_Entry "--------------------------------------------------"
}
##############################################################################
#
#    Subroutine     : tdm_ddl_generation
#    Purpose        : Creating dm ddl's
#    Parameters     : PROJECTNAME
#    Return Values  : None
##############################################################################
tdm_ddl_generation()
{
projectName=${1}
 
Log_Entry "--------------------------------------------------"
Log_Entry "TDM DDL Preparation Started                     "
Log_Entry "--------------------------------------------------"
 
Log_Entry "                1. All Columns are Generating .....            "
 
cmdDdlGen=`cat $config_dir/TDM_DDL_Gen.sql`
 
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/$projectName"_"$databasename"_SRC_ddl.ddl"
 
        ${cmdDdlGen}
;
EOF
 
Log_Entry "                1. All Columns are Generation Completed. "
 
Log_Entry "                3. All Keys are generating..... "
cmdDdlGenKeys=`cat $config_dir/TDM_DDL_Gen_Keys.sql`
 
nzsql -r -A -t -d ${tdm_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/$projectName"_"$databasename"_SRC_ddl.PkFkUkkeys"
 
        ${cmdDdlGenKeys}
;
EOF
 
Log_Entry "                3. All Keys are generation Completed. "
Log_Entry "                4. All Distributed and Organized Columns are generating...... "
cmdDdlDistOrgKeys=`cat $config_dir/TDM_DDL_Gen_Dist_Org.sql`
 
nzsql -r -A -t -d ${tdm_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/$projectName"_"$databasename"_SRC_ddl.DistOrgKeys"
 
        ${cmdDdlDistOrgKeys}
;
EOF
 
Log_Entry "                4. All Distributed and Organized Columns are generation Completed. "
}
##############################################################################
#
#    Subroutine     : tdm_ddl_preparation
#    Purpose        : Creating dm ddl's
#    Parameters     : PROJECTNAME
#    Return Values  : None
##############################################################################
tdm_ddl_preparation()
{
projectname=${1}
loadInd=${2}
current_date=`date '+%Y-%b-%d'`
 
if [[ $loadInd == "INDIV" ]];
then
        while read line
        do
        tablename=`echo TDM_${line}`
        Log_Entry "                DDL Started for : $tablename                    "
       
        tgtDdlFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_SRC_"$tablename"_DDL.sql"
       
        echo "-----------------------------------------------------------------------" >$tgtDdlFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtDdlFile
        echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $tablename" >> $tgtDdlFile
        echo "--Developer    :   $DEV_USER" >> $tgtDdlFile
        echo "--Created Date :   $current_date" >> $tgtDdlFile
        echo "-----------------------------------------------------------------------" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        Log_Entry "                        Header Generated : $tablename                    "
        echo "DROP TABLE $tablename IF EXISTS;" >> $tgtDdlFile
       echo "" >> $tgtDdlFile
        echo "CREATE TABLE $tablename (" >> $tgtDdlFile
       
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.ddl" > $temp_dir/select_temp.ddl
        
        lastRecord=`awk 'END{ print NR }' $temp_dir/select_temp.ddl`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub(",","",$0); print $0 }' $temp_dir/select_temp.ddl>>$tgtDdlFile
        echo ")" >>$tgtDdlFile
        Log_Entry "                        Columns Generated : $tablename                    "
                awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.DistOrgKeys">$temp_dir/awk_cnt.txt
                cnt=`cat $temp_dir/awk_cnt.txt|wc -l`
           if [ $cnt -eq 0 ];
           then
           echo "DISTRIBUTE ON RANDOM" >>$tgtDdlFile
           else        
           awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.DistOrgKeys" >>$tgtDdlFile
                   fi
        echo ";" >>$tgtDdlFile
        Log_Entry "                        Distributed and Organized keys are Generated : $tablename                    "
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.PkFkUkkeys" >>$tgtDdlFile
        Log_Entry "                        PK, FK and UK's are Generated : $tablename                    "
        Log_Entry "                        DDL Generation Completed : $tablename                    "
done < $temp_dir/Temp_DM_table_list.txt
fi
 
if [[ $loadInd == "COMBINED" ]]
then
        tgtDdlFile=$ddl_dir/$tgt_prefix"_002_"$projectName"_"$databasename"_SRC_DDL.sql"
        >$tgtDdlFile
                echo "-----------------------------------------------------------------------" >>$tgtDdlFile
        echo "--Project Name :   $PROJECT_NAME" >> $tgtDdlFile
        echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $projectName" >> $tgtDdlFile
        echo "--Developer    :   $DEV_USER" >> $tgtDdlFile
        echo "--Created Date :   $current_date" >> $tgtDdlFile
        echo "-----------------------------------------------------------------------" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        Log_Entry "                        Combined DDL Started                    "
               
                while read line
        do
        tablename=`echo TDM_${line}`       
        echo "DROP TABLE $tablename IF EXISTS;" >> $tgtDdlFile
        echo "" >> $tgtDdlFile
        echo "CREATE TABLE $tablename (" >> $tgtDdlFile
       
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.ddl" > $temp_dir/select_temp.ddl
       
        lastRecord=`awk 'END{ print NR }' $temp_dir/select_temp.ddl`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub(",","",$0); print $0 }' $temp_dir/select_temp.ddl>>$tgtDdlFile
        echo ")" >>$tgtDdlFile
                awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.DistOrgKeys">$temp_dir/awk_cnt.txt
                cnt=`cat $temp_dir/awk_cnt.txt|wc -l`
           if [ $cnt -eq 0 ];
           then
           echo "DISTRIBUTE ON RANDOM" >>$tgtDdlFile
           else        
           awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.DistOrgKeys" >>$tgtDdlFile
                   fi
        echo ";" >>$tgtDdlFile
        awk -v con="$tablename" -F "=>" '{ if ( $1 == con )  print $2 }' $temp_dir/$projectName"_"$databasename"_SRC_ddl.PkFkUkkeys" >>$tgtDdlFile
                echo " " >>$tgtDdlFile
done < $temp_dir/Temp_DM_table_list.txt
        Log_Entry "                        Combined DDL Completed                    "
fi
Log_Entry "--------------------------------------------------"
Log_Entry "TDM DDL Preparation Completed                     "
Log_Entry "--------------------------------------------------"
}
 
flowfile="$temp_dir/Process.Flow"
 
procInd=`awk -F "|" '{ print $4 }' $flowfile|uniq`
projName=`awk -F "|" '{ print $1 }' $flowfile|uniq`
databasename=`awk -F "|" '{ print $3 }' $temp_dir/DDL_Configuration.csv |uniq`
 
if [[ $procInd == "Automatic" ]];
then
dm_ddl_generation $projName
tdm_ddl_generation $projName
fi
 
while read line
do
projName=`echo $line |awk -F "|" '{ print $1 }'`
ruleType=`echo $line |awk -F "|" '{ print $2 }'`
ruleInd=`echo $line |awk -F "|" '{ print $3 }'`
procInd=`echo $line |awk -F "|" '{ print $4 }'`
 
if [[ $procInd == "Automatic" ]];
then
       
       if [[ $ruleType == "DM_PROD_MERGE-INDIVID_DDL" ]];
           then
             tgt_ddl_preparation $projName "INDIV"
       fi         
       if [[ $ruleType == "DM_PROD_MERGE-COMBINED_DDL" ]];
          then
             tgt_ddl_preparation $projName "COMBINED"
       fi
          if [[ $ruleType == "DM_PROD_TDM_MERGE-INDIVID_DDL" ]];
          then
                tdm_ddl_preparation $projName "INDIV"
       fi
          if [[ $ruleType == "DM_PROD_TDM_MERGE-COMBINED_DDL" ]];
          then
                tdm_ddl_preparation $projName "COMBINED"
       fi
fi        
 
done < $flowfile
log_footer# ----------------------------------------------------------------
# Dev_Automation-TDM_TGT_BKP_INSERT_Generation_Process.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. /nfs/rosetld/scripts/ksh/Dev_Automation/.initrc_Dev_Automation
 
log_file="$log_dir/TDM_TGT_BKP_INSERT_Generation.log"
>$log_file
##Log Header
 
        echo "************************************************************************************" >> $log_file
        START_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "Start of TDM TGT Backup Insert Script Generation: - "$START_TIME_STAMP >> $log_file
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
        echo "End of TDM TGT Backup Insert Script Generation:: - "$END_TIME_STAMP >> $log_file
        echo "************************************************************************************" >> $log_file
} # End of log_footer
 
#user defined backup date
 
bkpDate=`echo BKP_${backup_table_date}`
 
sed -i "s/BKP_01/$bkpDate/g" $config_dir/table_bkp.2nd
sed -i "s/BKP_01/$bkpDate/g" $config_dir/bkp_insert.2nd
 
##############################################################################
#
#    Subroutine     : tgt_bkp_insert_auto
#    Purpose        : to created bakup scripts
#    Parameters     : project name, tablename, dbname
#    Return Values  : None
#
##############################################################################
tgt_bkp_insert_auto()
{
projectname=${1}
loadInd=${2}
current_date=`date '+%Y-%b-%d'`
lowerprojname=`echo $projectname|awk '{ print tolower($0) }' `
 
if [[ $loadInd == "INDIV" ]];
then
Log_Entry  "Backup and Insert Script is Started for Individual DDL's"
while read line
do
tablename=`echo $line`
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
Log_Entry  "             1.Backup Starting for $tablename "
    #backup file generation
    file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$tablename"_"$databasename"_TGT_TABLES_BKP.sql"
    >$file
            echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TABLE CREATION FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    cat $config_dir/table_bkp.1st >>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/table_bkp.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    echo "\t" >>$file
Log_Entry  "             1.Backup Completed for $tablename "  
Log_Entry  "             2.Backup to Insert Started for $tablename "  
    #backup to insert file generation
    file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$tablename"_"$databasename"_TGT_BKP_TO_TGT.sql"
    >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO TARGET INSERT FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    cat $config_dir/bkp_insert.1st>>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/bkp_insert.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    echo "\t" >>$file
Log_Entry  "             2.Backup to Insert Completed for $tablename "
done < $temp_dir/Final_Table_List.csv
Log_Entry  "Backup and Insert Script is Completed for Individual DDL's"
fi
 
if [[ $loadInd == "COMBINED" ]];
then
Log_Entry  "Backup and Insert Script is Started for Combined DDL's"
    listfile="$temp_dir/temp1_"$projectname"_"$databasename"_combined.2nd"
        >$listfile
while read line
do
tablename=`echo $line`
Log_Entry  "             Backup and Insert Script is included for $tablename "
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
    echo "SELECT '$tablename' AS TABLENAME UNION ALL" >>$listfile
done < $temp_dir/Final_Table_List.csv
 
        lastRecord=`awk 'END{ print NR }' $listfile`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub("UNION ALL","",$0); print $0 }' $listfile>$temp_dir/temp"_"$projectname"_"$databasename"_combined.2nd"
        file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$databasename"_TGT_TABLES_BKP.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP SCRIPTS CREATION IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        listfile="$temp_dir/temp_"$projectname"_"$databasename"_combined.2nd"
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_tgt_bkp_ddl.out"  >>$file
        cat $config_dir/table_bkp.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/table_bkp.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_tgt_bkp_ddl.out" >>$file
        echo "\t" >>$file
       
        #bkp to insert file generation
        file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$databasename"_TGT_BKP_TO_TGT.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO TARGETS INSERTS IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_tgt_bkp_to_tgt.out"  >>$file
        cat $config_dir/bkp_insert.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/bkp_insert.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_tgt_bkp_to_tgt.out" >>$file
        echo "\t" >>$file
Log_Entry  "Backup and Insert Script is Completed for Combined DDL's"
fi
}
 
##############################################################################
#
#    Subroutine     : tdm_bkp_insert_auto
#    Purpose        : to created bakup scripts
#    Parameters     : project name, tablename, dbname
#    Return Values  : None
#
##############################################################################
tdm_bkp_insert_auto()
{
projectname=${1}
loadInd=${2}
current_date=`date '+%Y-%b-%d'`
lowerprojname=`echo $projectname|awk '{ print tolower($0) }' `
 
if [[ $loadInd == "INDIV" ]];
then
Log_Entry  "Backup and Insert Script is Started for Individual DDL's"
while read line
do
tablename=`echo TDM_$line`
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
Log_Entry  "             1.Backup Starting for $tablename "
    #backup file generation
    file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$tablename"_"$databasename"_SRC_TABLES_BKP.sql"
    >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP CREATION FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    cat $config_dir/table_bkp.1st >>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/table_bkp.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    echo "\t" >>$file
Log_Entry  "             1.Backup Completed for $tablename "  
Log_Entry  "             2.Backup to Insert Started for $tablename "  
    #backup to insert file generation
    file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$tablename"_"$databasename"_SRC_BKP_TO_TGT.sql"
    >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO TARGET INSERT SCRIPT FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    cat $config_dir/bkp_insert.1st>>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/bkp_insert.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    echo "\t" >>$file
Log_Entry  "             2.Backup to Insert Completed for $tablename "
done < $temp_dir/Final_Table_List.csv
Log_Entry  "Backup and Insert Script is Completed for Individual DDL's"
fi
 
if [[ $loadInd == "COMBINED" ]];
then
Log_Entry  "Backup and Insert Script is Started for Combined DDL's"
    listfile="$temp_dir/temp1_"$projectname"_"$databasename"_combined.2nd"
        >$listfile
while read line
do
tablename=`echo TDM_${line}`
Log_Entry  "             Backup and Insert Script is included for $tablename "
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
    echo "SELECT '$tablename' AS TABLENAME UNION ALL" >>$listfile
done < $temp_dir/Final_Table_List.csv
 
        lastRecord=`awk 'END{ print NR }' $listfile`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub("UNION ALL","",$0); print $0 }' $listfile>$temp_dir/temp"_"$projectname"_"$databasename"_combined.2nd"
        file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$databasename"_SRC_TABLES_BKP.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TABLES CREATION IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        listfile="$temp_dir/temp_"$projectname"_"$databasename"_combined.2nd"
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_src_bkp_ddl.out"  >>$file
        cat $config_dir/table_bkp.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/table_bkp.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_src_bkp_ddl.out" >>$file
        echo "\t" >>$file
       
        #bkp to insert file generation
        file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$databasename"_SRC_BKP_TO_TGT.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO INSERT SCRIPTS IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_src_bkp_to_tgt.out"  >>$file
        cat $config_dir/bkp_insert.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/bkp_insert.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_src_bkp_to_tgt.out" >>$file
        echo "\t" >>$file
Log_Entry  "Backup and Insert Script is Completed for Combined DDL's"
fi
}
 
##############################################################################
#
#    Subroutine     : tgt_bkp_insert_manual
#    Purpose        : to created bakup scripts
#    Parameters     : project name, tablename, dbname
#    Return Values  : None
#
##############################################################################
tgt_bkp_insert_manual()
{
projectname=${1}
loadInd=${2}
current_date=`date '+%Y-%b-%d'`
lowerprojname=`echo $projectname|awk '{ print tolower($0) }' `
 
if [[ $loadInd == "INDIV" ]];
then
Log_Entry  "Backup and Insert Script is Started for Individual DDL's"
while read line
do
tablename=`echo $line|awk -F "|" '{ print $1 }'`
if [[ $tablename != TDM_* ]];
then
databasename=`echo $line|awk -F "|" '{ print $2 }'`
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
Log_Entry  "             1.Backup Starting for $tablename "
    #backup file generation
    file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$tablename"_"$databasename"_TABLES_BKP.sql"
    >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TABLE CREATION FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
       echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    cat $config_dir/table_bkp.1st >>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/table_bkp.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    echo "\t" >>$file
Log_Entry  "             1.Backup Completed for $tablename "  
Log_Entry  "             2.Backup to Insert Started for $tablename "  
    #backup to insert file generation
    file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$tablename"_"$databasename"_BKP_TO_TGT.sql"
    >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO TARGET INSERT SCRIPTS FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    cat $config_dir/bkp_insert.1st>>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/bkp_insert.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    echo "\t" >>$file
Log_Entry  "             2.Backup to Insert Completed for $tablename "
fi
done < $tablelilst
Log_Entry  "Backup and Insert Script is Completed for Individual DDL's"
fi
 
if [[ $loadInd == "COMBINED" ]];
then
Log_Entry  "Backup and Insert Script is Started for Combined DDL's"
    listfile="$temp_dir/temp1_"$projectname"_"$databasename"_combined.2nd"
        >$listfile
while read line
do
tablename=`echo $line|awk -F "|" '{ print $1 }'`
if [[ $tablename != TDM_* ]];
then
databasename=`echo $line|awk -F "|" '{ print $2 }'`
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
lowerdbname=`echo $databasename|awk '{ print tolower($0) }'`
Log_Entry  "             Backup and Insert Script is included for $tablename "
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
    echo "SELECT '$tablename' AS TABLENAME UNION ALL" >>$listfile
fi
done < $tablelilst
 
        lastRecord=`awk 'END{ print NR }' $listfile`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub("UNION ALL","",$0); print $0 }' $listfile>$temp_dir/temp"_"$projectname"_"$databasename"_combined.2nd"
        file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$databasename"_TABLES_BKP.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TABLE SCRIPTS IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        listfile="$temp_dir/temp_"$projectname"_"$databasename"_combined.2nd"
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_bkp_ddl.out"  >>$file
        cat $config_dir/table_bkp.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/table_bkp.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_bkp_ddl.out" >>$file
        echo "\t" >>$file
       
        #bkp to insert file generation
        file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$databasename"_BKP_TO_TGT.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO TARGET INSERT SCRIPTS IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_bkp_to_tgt.out"  >>$file
        cat $config_dir/bkp_insert.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/bkp_insert.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_bkp_to_tgt.out" >>$file
        echo "\t" >>$file
Log_Entry  "Backup and Insert Script is Completed for Combined DDL's"
fi
}
 
##############################################################################
#
#    Subroutine     : tdm_bkp_insert_manual
#    Purpose        : to created bakup scripts
#    Parameters     : project name, tablename, dbname
#    Return Values  : None
#
##############################################################################
tdm_bkp_insert_manual()
{
projectname=${1}
loadInd=${2}
current_date=`date '+%Y-%b-%d'`
lowerprojname=`echo $projectname|awk '{ print tolower($0) }' `
 
if [[ $loadInd == "INDIV" ]];
then
Log_Entry  "Backup and Insert Script is Started for Individual DDL's"
while read line
do
tablename=`echo $line|awk -F "|" '{ print $1 }'`
if [[ $tablename == TDM_* ]];
then
databasename=`echo $line|awk -F "|" '{ print $2 }'`
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
lowerdbname=`echo $databasename|awk '{ print tolower($0) }'`
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
Log_Entry  "             1.Backup Starting for $tablename "
    #backup file generation
    file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$tablename"_"$databasename"_TABLES_BKP.sql"
    >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TABLE SCRIPT FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    cat $config_dir/table_bkp.1st >>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/table_bkp.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_ddl.out" >>$file
    echo "\t" >>$file
Log_Entry  "             1.Backup Completed for $tablename "  
Log_Entry  "             2.Backup to Insert Started for $tablename "  
    #backup to insert file generation
    file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$tablename"_"$databasename"_BKP_TO_TGT.sql"
    >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO TABLE INSERT SCRIPT FOR $tablename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
    echo "\t"  >>$file
    echo "\o /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    cat $config_dir/bkp_insert.1st>>$file
    echo " " >>$file
    echo "SELECT '$tablename' AS TABLENAME" >>$file
    echo ")" >>$file
    cat $config_dir/bkp_insert.2nd >>$file
    echo " " >>$file
    echo "\o " >>$file
    echo "\i /tmp/"$lowerprojname"_"$lowertablename"_bkp_to_tgt.out" >>$file
    echo "\t" >>$file
Log_Entry  "             2.Backup to Insert Completed for $tablename "
fi
done < $tablelilst
Log_Entry  "Backup and Insert Script is Completed for Individual DDL's"
fi
 
if [[ $loadInd == "COMBINED" ]];
then
Log_Entry  "Backup and Insert Script is Started for Combined DDL's"
    listfile="$temp_dir/temp1_"$projectname"_"$databasename"_combined.2nd"
        >$listfile
while read line
do
tablename=`echo $line|awk -F "|" '{ print $1 }'`
if [[ $tablename == TDM_* ]];
then
databasename=`echo $line|awk -F "|" '{ print $2 }'`
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
lowerdbname=`echo $databasename|awk '{ print tolower($0) }'`
Log_Entry  "             Backup and Insert Script is included for $tablename "
lowertablename=`echo $tablename|awk '{ print tolower($0) }'`
    echo "SELECT '$tablename' AS TABLENAME UNION ALL" >>$listfile
fi
done <$tablelilst
 
        lastRecord=`awk 'END{ print NR }' $listfile`
        awk -v lrc="$lastRecord" '{ if ( NR==lrc ) gsub("UNION ALL","",$0); print $0 }' $listfile>$temp_dir/temp"_"$projectname"_"$databasename"_combined.2nd"
        file=$ddl_dir/$tgt_prefix"_001_"$projectname"_"$databasename"_TABLES_BKP.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TABLE SCRIPTS IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        listfile="$temp_dir/temp_"$projectname"_"$databasename"_combined.2nd"
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_bkp_ddl.out"  >>$file
        cat $config_dir/table_bkp.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/table_bkp.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_bkp_ddl.out" >>$file
        echo "\t" >>$file
       
        #bkp to insert file generation
        file=$ddl_dir/$tgt_prefix"_003_"$projectname"_"$databasename"_BKP_TO_TGT.sql"
        >$file
                echo "-----------------------------------------------------------------------" >$file
        echo "--Project Name :   $PROJECT_NAME" >> $file
        echo "--Purpose      :   ONE TIME BACKUP TO TABLE INSERT SCRIPTS IN $databasename" >> $file
        echo "--Developer    :   $DEV_USER" >> $file
        echo "--Created Date :   $current_date" >> $file
        echo "-----------------------------------------------------------------------" >> $file
        echo "" >> $file
        echo "\t"  >>$file
        echo "\o /tmp/"$lowerprojname"_"$lowerdbname"_bkp_to_tgt.out"  >>$file
        cat $config_dir/bkp_insert.1st >>$file
        echo " " >>$file
        cat $listfile >>$file
        echo ")" >>$file
        cat $config_dir/bkp_insert.2nd >>$file
        echo " " >>$file
        echo "\o " >>$file
        echo "\i /tmp/"$lowerprojname"_"$lowerdbname"_bkp_to_tgt.out" >>$file
        echo "\t" >>$file
Log_Entry  "Backup and Insert Script is Completed for Combined DDL's"
fi
}
 
flowfile="$temp_dir/Process.Flow"
tablelilst="$temp_dir/Table_List.csv"
 
procInd=`awk -F "|" '{ print $4 }' $flowfile|uniq`
projName=`awk -F "|" '{ print $1 }' $flowfile|uniq`
 
if [[ $procInd == "Automatic" ]];
then
databasename=`awk -F "|" '{ print $3 }' $temp_dir/DDL_Configuration.csv |uniq`
lowerdbname=`echo $databasename|awk '{ print tolower($0) }'`
 
tableListQuery=`cat $config_dir/TABLE_List_Gen.sql`
 
Log_Entry "          1. DM DDL Comparision Report Generation - Started"
 
nzsql -t -r -A -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF > $temp_dir/Final_Table_List.csv
 
${tableListQuery}
 
EOF
 
while read line
do
ruleType=`echo $line |awk -F "|" '{ print $2 }'`
 
       if [[ $ruleType == "TGT_BACKUP_INSERT-INDIVID_DDL" ]];
           then
             tgt_bkp_insert_auto $projName "INDIV"
       fi         
       if [[ $ruleType == "TGT_BACKUP_INSERT-COMBINED_DDL" ]];
          then
             tgt_bkp_insert_auto $projName "COMBINED"
       fi
          if [[ $ruleType == "TDM_BACKUP_INSERT-INDIVID_DDL" ]];
          then
                tdm_bkp_insert_auto $projName "INDIV"
       fi
          if [[ $ruleType == "TDM_BACKUP_INSERT-COMBINED_DDL" ]];
          then
                tdm_bkp_insert_auto $projName "COMBINED"
       fi
done < $flowfile
log_footer
fi
 
if [[ $procInd == "Manual-Tablelist" ]];
then
while read line
do
ruleType=`echo $line |awk -F "|" '{ print $2 }'`
 
       if [[ $ruleType == "TGT_BACKUP_INSERT-INDIVID_DDL" ]];
           then
             tgt_bkp_insert_manual $projName "INDIV"
       fi         
       if [[ $ruleType == "TGT_BACKUP_INSERT-COMBINED_DDL" ]];
          then
             tgt_bkp_insert_manual $projName "COMBINED"
       fi
          if [[ $ruleType == "TDM_BACKUP_INSERT-INDIVID_DDL" ]];
          then
                tdm_bkp_insert_manual $projName "INDIV"
       fi
          if [[ $ruleType == "TDM_BACKUP_INSERT-COMBINED_DDL" ]];
          then
                tdm_bkp_insert_manual $projName "COMBINED"
       fi
done < $flowfile
log_footer
fi
# backup date to default
 
sed -i "s/$bkpDate/BKP_01/g" $config_dir/table_bkp.2nd
sed -i "s/$bkpDate/BKP_01/g" $config_dir/bkp_insert.2nd
# ----------------------------------------------------------------
# Dev_Automation-WRAPPER_SCRIPT_Generation_Proces.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. /nfs/rosetld/scripts/ksh/Dev_Automation/.initrc_Dev_Automation
 
current_date=`date '+%Y-%b-%d'`
 
log_file="$log_dir/Wrapper_Scripts_Generation_Process.log"
>$log_file
##Log Header
 
        echo "************************************************************************************" >> $log_file
        START_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "Start of Wrapper Scripts Generation Process: - "$START_TIME_STAMP >> $log_file
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
        echo "End of Wrapper Scripts Generation Process: - "$END_TIME_STAMP >> $log_file
        echo "************************************************************************************" >> $log_file
} # End of log_footer
 
Log_Entry "  Wrapper Scripts Generation Process Started"
 
cnt=`ls $ddl_dir |wc -l`
 
if [ $cnt -gt 0 ];
then
    Log_Entry "          There are $cnt files are exists in DDL Directory"
    ls -1 $ddl_dir > $ddl_dir/filelist
    Log_Entry "$ddl_dir/filelist"
   
    flowfile="$temp_dir/Process.Flow"
    procInd=`awk -F "|" '{ print $4 }' $flowfile|uniq`
   
    
        if [[ $procInd == "Automatic" ]];
        then
        Log_Entry "          Wrapper Scrits Generation Started"
        ProjectName=`awk -F "|" '{ print $1 }' $flowfile|uniq`
        databasename=`awk -F "|" '{ print $3 }' $temp_dir/DDL_Configuration.csv |uniq`
        linePrefix="\i ../../src/tables"
        wrapperSrcFile=$wrapper_dir/$tgt_prefix"_001_"$ProjectName"_"$databasename"_SRC_TABLES_LOAD_PROECSS.sql"
                echo "-----------------------------------------------------------------------" >$wrapperSrcFile
                echo "--Project Name :   $PROJECT_NAME" >> $wrapperSrcFile
                echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $databasename SRC" >> $wrapperSrcFile
                echo "--Developer    :   $DEV_USER" >> $wrapperSrcFile
                echo "--Created Date :   $current_date" >> $wrapperSrcFile
                echo "-----------------------------------------------------------------------" >> $wrapperSrcFile
                echo "" >> $wrapperSrcFile
        wrapperTgtFile=$wrapper_dir/$tgt_prefix"_001_"$ProjectName"_"$databasename"_TGT_TABLES_LOAD_PROECSS.sql"
                echo "-----------------------------------------------------------------------" >$wrapperTgtFile
                echo "--Project Name :   $PROJECT_NAME" >> $wrapperTgtFile
                echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $databasename TGT" >> $wrapperTgtFile
                echo "--Developer    :   $DEV_USER" >> $wrapperTgtFile
                echo "--Created Date :   $current_date" >> $wrapperTgtFile
                echo "-----------------------------------------------------------------------" >> $wrapperTgtFile
                echo "" >> $wrapperTgtFile
        while read line
        do
        srcSearchWord=`echo ${databasename}_SRC`
        tgtSearchWord=`echo ${databasename}_TGT`
       
        if [[ $line == *$srcSearchWord* ]];
        then
        echo $linePrefix/$line>>$wrapperSrcFile
        fi
       
        if [[ $line == *$tgtSearchWord* ]];
        then
        echo $linePrefix/$line>>$wrapperTgtFile
        fi
       
        done <$ddl_dir/filelist
        Log_Entry "          Wrapper Scrits Generation Ended"
        log_footer
        fi
 
        if [[ $procInd == "Manual-Tablelist" ]];
        then
        Log_Entry "          Wrapper Scrits Generation Started"
        ProjectName=`awk -F "|" '{ print $1 }' $flowfile|uniq`
        databasename=`awk -F "|" '{ print $2 }' $temp_dir/Table_List.csv|cut -d "_" -f1|uniq`
        linePrefix="\i ../../src/tables"
        wrapperSrcFile=$wrapper_dir/$tgt_prefix"_001_"$ProjectName"_"$databasename"_SRC_TABLES_LOAD_PROECSS.sql"
                echo "-----------------------------------------------------------------------" >$wrapperSrcFile
                echo "--Project Name :   $PROJECT_NAME" >> $wrapperSrcFile
                echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $databasename SRC" >> $wrapperSrcFile
                echo "--Developer    :   $DEV_USER" >> $wrapperSrcFile
                echo "--Created Date :   $current_date" >> $wrapperSrcFile
                echo "-----------------------------------------------------------------------" >> $wrapperSrcFile
                echo "" >> $wrapperSrcFile
        wrapperTgtFile=$wrapper_dir/$tgt_prefix"_001_"$ProjectName"_"$databasename"_TGT_TABLES_LOAD_PROECSS.sql"
                echo "-----------------------------------------------------------------------" >$wrapperTgtFile
                echo "--Project Name :   $PROJECT_NAME" >> $wrapperTgtFile
                echo "--Purpose      :   ONE TIME TABLE CREATION DDL SCRIPT FOR $databasename TGT" >> $wrapperTgtFile
                echo "--Developer    :   $DEV_USER" >> $wrapperTgtFile
                echo "--Created Date :   $current_date" >> $wrapperTgtFile
                echo "-----------------------------------------------------------------------" >> $wrapperTgtFile
                echo "" >> $wrapperTgtFile
        while read line
        do
        srcSearchWord=`echo ${databasename}_SRC`
        tgtSearchWord=`echo ${databasename}_TGT`
       
        if [[ $line == *$srcSearchWord* ]];
        then
        echo $linePrefix/$line>>$wrapperSrcFile
        fi
       
        if [[ $line == *$tgtSearchWord* ]];
        then
        echo $linePrefix/$line>>$wrapperTgtFile
        fi
       
        done <$ddl_dir/filelist
        Log_Entry "          Wrapper Scrits Generation Ended"
                log_footer
        fi
else
    Log_Entry "          There are No files are exists in DDL Directory"
        log_footer
fi
rm -f $ddl_dir/filelist