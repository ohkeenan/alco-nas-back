#!/bin/bash

# This script is a wrapper around rsnapshot, so status information is logged
# and notification are made via Pushover app.  It also makes sure the log file
# doesn't grow too large.
# Credit to http://jeffskinnerbox.me/posts/2014/Feb/08/network-backups-via-rsync-and-rsnapshot/

. /opt/alco-nas-back/settings.cfg

rundir=$(dirname "$0") && cd "${rundir}" || exit 1

# Capture scripts start time
STARTTIME=`date +%s`

# Number of lines in the log file required to trigger it's truncation
MAXLINES=7000

# Number of lines remaining in the log file after its truncated
MINLINES=2000

# Calculate the size of the Log file
LOGSIZE=$( wc $LOG | awk '{ print $1 }' )

# Place in the log file information concerning the execution of this script
echo -e "\n\n+++++ rsnapshot script started on `date` +++++" >> $LOG
echo "options passed to rsnapshot: " $@ >> $LOG

# Now execute the script
/opt/bin/rsnapshot "$@" >> $LOG 2>&1
EXITSTATUS=$?

# Capture scripts end time and calculate run time
ENDTIME=`date +%s`
INTERVAL=$((ENDTIME - STARTTIME))
RUNTIME="$(($INTERVAL / 60)) min. $(($INTERVAL % 60)) sec."

# Place time-stamped completion message in the Log
echo "rsnapshot exited with status $EXITSTATUS" >> $LOG
echo "+++++ rsnapshot ran" $RUNTIME "and script completed on `date` +++++" >> $LOG

# Send status notification via Amazon SES
if [[ "$@" != *hourly* ]]; then
        if [[ "$use_ses" == true ]]; then
        nohup sh /opt/alco-nas-back/plugins/aws-ses.sh "$@" "Filesystem backup took $RUNTIME and completed on `date` with exit status $EXITSTATUS.  Log file $LOG has $LOGSIZE lines."
        fi
fi

# open reverse tunnel
if [[ "$@" == *daily* ]]; then
 nohup sh /opt/alco-nas-back/reverse-tunnel.sh &
fi

# Truncate the log file if needed
if [ $LOGSIZE -ge $MAXLINES ]
then
    LINECUT=`expr $LOGSIZE - $MINLINES`
    sed -i "1,$LINECUT d" $LOG
    sed -i "1i ////////////////  File truncated here on `date`. //////////////// " $LOG
fi
