# ----------------------------------------------------------------
# DeVato-TDM_TGT_BKP_INSERT_Generation_Process.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. initrc_DeVato
 
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
