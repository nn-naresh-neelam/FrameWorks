# ----------------------------------------------------------------
# DeVato-CLEAN-UP_Proces.sh
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Developer : Naresh Neelam
# ----------------------------------------------------------------

.initrc_Dev_Automation
 
log_file="$log_dir/Clean_Up_Process.log"
>$log_file
##Log Header
 
        echo "************************************************************************************" >> $log_file
        START_TIME_STAMP=`date | awk '{print $3$2$6"-"$4}' `
        echo "Start of Cleanup Process: - "$START_TIME_STAMP >> $log_file
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
 
Log_Entry "  Cleanup Process Started"
 
 
if [ ! -f $temp_dir/Temp_Drop_DM_table_list.txt ];
then
Log_Entry "  No DM Tables to DROP"
Log_Entry "  Cleanup Process Ended"
log_footer
else
cmdDropDM=`cat $temp_dir/Temp_Drop_DM_table_list.txt`
nzsql -r -A -t -d ${temp_db} -host ${NZ_HOST} -u ${NZ_USER} <<EOF >> $log_file
 
        ${cmdDropDM}
;
EOF
 
Log_Entry "  Cleanup Process Ended"
log_footer
fi
