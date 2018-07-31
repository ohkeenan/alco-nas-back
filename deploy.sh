#!/bin/sh

# check if QNAP or Synology
if [ -f "/sbin/getsysinfo" ]; then
    # is QNAP
    MODEL=$(/sbin/getsysinfo model)
    echo -e "QNAP $MODEL found."

elif [ -f "/etc/synoinfo.conf" ]; then
    # is Synology
    MODEL=$(cat /etc/synoinfo.conf|grep -n upnpmodelname|cut -f2 -d'"')
    echo -e "Synology $MODEL found."

else
    # is something else
    echo "Could not detect if device is QNAP or Synology."
    exit
fi
