#!/bin/bash
# Nagios script for monitoring Moab 7 sync state with Torque 4
SHOWRES=/opt/moab/bin/showres
QSTAT=/usr/bin/qstat
GREP=/bin/grep
AWK=/bin/awk
CUT=/bin/cut
ECHO=/bin/echo
DATE=/bin/date
TOUCH=/bin/touch
CAT=/bin/cat
EXPR=/usr/bin/expr

STATEFILE=/tmp/check_moab_sync-last_sync_date

MoabRunningJobID=`$SHOWRES | $GREP "Job R" | $AWK '{print $1}'`
TorqueRunningJobID=`$QSTAT -t | $GREP " R " | $CUT -d. -f1`
MoabStrayJobID=`for i in $MoabRunningJobID; do $ECHO $TorqueRunningJobID | $GREP -q -F "$i" || $ECHO $i; done`
TorqueStrayJobID=`for i in $TorqueRunningJobID; do $ECHO $MoabRunningJobID | $GREP -q -F "$i" || $ECHO $i; done`

$TOUCH $STATEFILE
[ "$MoavStrayJobID$TorqueStrayJobID" = "" ] && $DATE +%s > $STATEFILE
DATESYNC=`$CAT $STATEFILE`
DATENOW=`$DATE +%s`
LASTSYNC=`$EXPR $DATENOW - $DATESYNC`
if [ $? -eq 2 ]; then
	$ECHO "Moab/Torque last sync date not availabe."
	exit 3
fi
if [ $LASTSYNC -lt 120 ]; then
	$ECHO "Moab/Torque last sync in $LASTSYNC seconds."
	exit 0
fi
if [ $LASTSYNC -gt 1800 ]; then
	$ECHO "Moab/Torque out of sync for more than 30 minutes."
	exit 2
fi
$ECHO "Moab/Torque out of sync for more than 2 minutes."
exit 1
