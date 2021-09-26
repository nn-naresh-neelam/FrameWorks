# ----------------------------------------------------------------
# DeVato-DM_TGT_TDM_DDL_Generation_Process.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. initrc_DeVato
 
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
log_footer
