#!/bin/bash

. /opt/alco-nas-back/settings.cfg

rundir=$(dirname "$0") && cd "${rundir}" || exit 1
STARTTIME=`date +%s`
MAXLINES=7000
MINLINES=2000
LOGSIZE=$( wc $RTLOG | awk '{ print $1 }' )

echo -e "\n\n+++++ reverse-tunnel started on `date` +++++" >> $RTLOG



set -x
# See https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-autossh/
/opt/bin/kill -9 $(ps aux|grep '[a]utossh'|awk '{print $1}')

# Forward ports to remote host. Remote port will be $FWD_START + <last two digits of forwarded port>
cd /
# autossh will retry even on failure of first attempt to run ssh.
export AUTOSSH_GATETIME=0
for localport in $LOCAL_PORTS; do
    port_last_two_digits=$(echo $localport|sed 's/.*\(..\)/\1/')
    remote_port=$FWD_START${port_last_two_digits}
    autossh -N -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -o 'ExitOnForwardFailure yes' \
                        $DESTINATION -T -R *:${remote_port}:localhost:${localport} & >> $RTLOG 2>&1
done

EXITSTATUS=$?

ENDTIME=`date +%s`
INTERVAL=$((ENDTIME - STARTTIME))
RUNTIME="$(($INTERVAL / 60)) min. $(($INTERVAL % 60)) sec."

echo "reverse-tunnel exited with status $EXITSTATUS" >> $RTLOG

echo "+++++ reverse-tunnel" $RUNTIME "and script completed on `date` +++++" >> $RTLOG