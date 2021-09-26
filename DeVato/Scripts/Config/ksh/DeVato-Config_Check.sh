# ----------------------------------------------------------------
# DeVato-Config_Check.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# Developer : Naresh Neelam
# ----------------------------------------------------------------
 
. initrc_DeVato
 
##moving files from source and tempdir
 
rm -f $source_dir/*.*
rm -f $temp_dir/*.*
rm -f $log_dir/*.*
rm -f $log_dir/*.*
rm -f $wrapper_dir/*.*
rm -f $report_dir/*.*
rm -f $ddl_dir/*.*
 
log_file="$log_dir/Config_Checks.log"
>$log_file
##Log Header
 
        echo "************************************************************************************" >> $log_file
        START_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "Start of Dev Automation Config Check: - "$START_TIME_STAMP >> $log_file
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
        echo "End of Dev Automation Config Check: - "$END_TIME_STAMP >> $log_file
        echo "************************************************************************************" >> $log_file
} # End of log_footer
 
cp $raw_dir/*.* $source_dir/
 
echo "$(ls $raw_dir/)" |sed -e 's! !\\ !g' > $temp_dir/cp_list.list
while read filename
do
cd $source_dir/
newfileName=`echo "$filename"|sed -e 's/\\ /_/g'`
mv "$filename" "$newfileName" 2>/dev/null
done < $temp_dir/cp_list.list
 
 
confile="$source_dir/$config_file"
if [[ ! -f $confile ]] ; then
    Log_Entry "Configutaion Template File is not available"
        log_footer
        exit 1
fi
 
if [[ -f $confile ]] ; then
    Log_Entry "Cleaning Temp Dir .."
        rm -f $temp_dir/*.*
    Log_Entry "Configutaion Template File is available"
        Log_Entry "------------------------------------------------------"
        Log_Entry "Generating Configuration Files From Configuration Template File ......."
        python3 $script_dir/DeVato-Configuration-PYTHON-Excel_CSV.py $source_dir/ $config_file $temp_dir/
       
                                if [ $? -eq 0 ];
                                then
                                                Log_Entry "The Configuration Files are Succefully Generated"
                                                Log_Entry "-------------------------------------------------------"
                                                list=`ls -1 $temp_dir/ |awk '{ print NR"."$0 }'`
                                                Log_Entry "$list"
                                                Log_Entry "-------------------------------------------------------"
                                else
                                        Log_Entry "Error while generating the Configuration Files. Please run the python script DeVato-Configuration-PYTHON-Excel_CSV.py manually"
                                        log_footer
                                        exit 1;
                                fi
fi
 
Log_Entry "Configuration Validation Started....."
 
flowfile=$temp_dir/Process.Flow
 
cnt=`cat $flowfile |wc -l`
 
                                if [ $cnt -eq 0 ];
                                then
                                                Log_Entry "The Flow Configuration File have no Records, so unable to proceed further"
                                                Log_Entry "-------------------------------------------------------"
                        log_footer
                                                exit 1;
                                fi
 
while read line
do
projName=`echo $line |awk -F "|" '{ print $1 }'`
ruleType=`echo $line |awk -F "|" '{ print $2 }'`
ruleInd=`echo $line |awk -F "|" '{ print $3 }'`
processflow=`echo $line |awk -F "|" '{ print $4 }'`
#Mandatory fields checks
                    if [[ $projName == "" ]] || [[ $ruleType == "" ]] || [[ $ruleInd == "" ]];
                            then
                             Log_Entry "Mandatory Columns are Empty in OUTPUT_Configuration tab, unable to proceed further"
                                                Log_Entry "-------------------------------------------------------"
                         log_footer
                                                exit 1;
                                else
                                         Log_Entry "Mandatory Columns are valid for $ruleType in OUTPUT_Configuration tab, Proceeding for next validations"
                            fi
 
if [[ $processflow == "Automatic" ]];
then
# Checks
ddlconfile=$temp_dir/DDL_Configuration.csv
                    if [[ $ruleType == "DM_PROD_DDL_COMPARISON" ]] || [[ $ruleType == "DM_PROD_MERGE-SINGLE_DDL" ]] || [[ $ruleType == "DM_PROD_MERGE-COMBINED_DDL" ]] || [[ $ruleType == "DM_PROD_TDM_MERGE-SINGLE_DDL" ]] || [[ $ruleType == "DM_PROD_TDM_MERGE-COMBINED_DDL" ]];
                            then
                             csvcnt=`cat $ddlconfile|grep "XLSX"|wc -l`
                                                ddlcnt=`cat $ddlconfile|grep "DDL"|wc -l`
                                                if [ $csvcnt -eq 0 ] ||  [ $ddlcnt -eq 0 ];
                                                then 
                                                     Log_Entry "Either DDL or PROD CSV missed in DDL_Configuration tab- Please check, unable to proceed further"
                                                     Log_Entry "-------------------------------------------------------"
                             log_footer
                                                        exit 1;
                                                else
                                                         Log_Entry "DDL_Configuration tab is valid for $ruleType"
                                                fi
                                                while read filename
                                                do
                                                fname=`echo $filename |awk -F "|" '{ print $1 }'`
                                                    if [[ ! -f $source_dir/$fname ]];
                                                        then
                                                            Log_Entry " $fname is not avaiable in Raw Source dir, Please place the file. Unable to proceed further "
                                                        Log_Entry "-------------------------------------------------------"
                                log_footer
                                                                exit 1;
                                                        else
                                                            Log_Entry "Required DDL Files are available in RawSrc Dir for $ruleType"
                            fi                                                         
                                                done < $ddlconfile
                            fi
#DM_PROD_DDL_STTM_COMPARISION Checks
sttmconfile=$temp_dir/STTM_Configuration.csv
                    if [[ $ruleType == "DM_PROD_DDL_STTM_COMPARISON" ]];
                            then
                             csvcnt=`cat $ddlconfile|grep "XLSX"|wc -l`
                                                ddlcnt=`cat $ddlconfile|grep "DDL"|wc -l`
                                                if [ $csvcnt -eq 0 ] ||  [ $ddlcnt -eq 0 ];
                                                then 
                                                     Log_Entry "Either DDL or PROD CSV missed in DDL_Configuration tab- Please check, unable to proceed further"
                                                     Log_Entry "-------------------------------------------------------"
                             log_footer
                                                        exit 1;
                                                else
                                                            Log_Entry "DDL_Configuration is valid for $ruleType"
                                                fi
                                                while read filename
                                                do
                                                fname=`echo $filename |awk -F "|" '{ print $1 }'`
                                                    if [[ ! -f $source_dir/$fname ]];
                                                        then
                                                            Log_Entry " $fname is not avaiable in Raw source dir, Please place the file. Unable to proceed further "
                                                        Log_Entry "-------------------------------------------------------"
                                log_footer
                                                                exit 1;
                                                        else
                                                            Log_Entry "Required DDL Files are available in RawSrc Dir for $ruleType"       
                            fi                                                         
                                                done < $ddlconfile
                             sttmcnt=`cat $sttmconfile|grep "STTM"|wc -l`
                                                if [ $sttmcnt -eq 0 ];
                                                then 
                                                     Log_Entry "STTM is missed STTM_Configuration tab- Please check, unable to proceed further"
                                                     Log_Entry "-------------------------------------------------------"
                                                        log_footer
                             exit 1;
                                                else
                                                            Log_Entry "STTM_Configuration tab is valid for $ruleType"
                                                fi
                                                while read filename
                                                do
                                                fname=`echo $filename |awk -F "|" '{ print $1 }'`
                                                    if [[ ! -f $source_dir/$fname ]];
                                                        then
                                                            Log_Entry " $fname is not avaiable in Raw source dir, Please place the file. Unable to proceed further "
                                                        Log_Entry "-------------------------------------------------------"
                                                                log_footer
                                                                exit 1;
                                                        else
                                                            Log_Entry "Required Files are available in RawSrc Dir for $ruleType"     
                            fi                                                         
                                                done < $sttmconfile
                            fi
procfile="$temp_dir/Start_Process_1"
echo "Automatic" >$procfile
fi
 
if [[ $processflow == "Manual-Tablelist" ]];
then
# Checks
tablelistFile="$temp_dir/Table_List.csv"
               if [[ $ruleType == "TGT_BACKUP_INSERT-SINGLE_DDL" ]] || [[ $ruleType == "TGT_BACKUP_INSERT-COMBINED_DDL" ]] || [[ $ruleType == "TDM_BACKUP_INSERT-SINGLE_DDL" ]] || [[ $ruleType == "TDM_BACKUP_INSERT-COMBINED_DDL" ]];
               then
                                 tablelistcnt=`cat $tablelistFile|wc -l`          
                                                 if [ $tablelistcnt -eq 0 ];
                                                then 
                                                     Log_Entry "Table list is missing in Table_List tab- Please check, unable to proceed further"
                                                     Log_Entry "-------------------------------------------------------"
                             log_footer
                                                        exit 1;
                                                else
                                                            Log_Entry "Required Table list is availabe for $ruleType"
                                                fi
                            fi
procfile="$temp_dir/Start_Process_1"
echo "Manuval" >$procfile
fi
done < "$flowfile"
Log_Entry "Configuration Validation Completed....."
log_footer
