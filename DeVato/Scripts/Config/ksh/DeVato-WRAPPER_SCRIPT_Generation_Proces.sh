# ----------------------------------------------------------------
# DeVato-WRAPPER_SCRIPT_Generation_Proces.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. initrc_DeVato
 
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
