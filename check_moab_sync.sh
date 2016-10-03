#!/bin/bash
# Nagios script for monitoring Moab 7 sync state with Torque 4
# When used with Nagios, make sure user:nagios has rights to restart Moab (ADMIN1)
# mschedctl -m config ADMIN1 root,nagios --flags=pers
runid=`date +%Y%m%d-%H%M`
workdir=/tmp/check_moab_sync
mkdir -p $workdir
# Please set your path accordingly
PATH=$PATH
output="$(showres -n 2>&1 | grep ' Job ' | sed 's/^/#/' | awk '{print $3}' | sort | uniq | xargs qstat | grep ' C ' | tee $workdir/$runid.log)"

if [ `find $workdir -mmin -15 -name \*.log | wc -l` -gt 0 ]; then
# Make sure we have some freshly generated log files
	if [ `find $workdir -mmin -1 -size 0 -name \*.log | wc -l` -gt 0 ]; then
		echo "Moab clean of stale reservation."
		exit 0
	elif [ `find $workdir -mmin -10 -size 0 -name \*.log | wc -l` -gt 0 ]; then
		echo "Moab has stale reservation (last clean <10 minutes). Issue might be temporary."
		exit 1
	elif [ `find $workdir -mmin -25 -size 0 -name \*.log | wc -l` -gt 0 ]; then
		echo "Moab has stale reservation (last clean 10-25 minutes). Recycling Moab soon."
		exit 1
	elif [ `find $workdir -mmin -75 -size 0 -name \*.log | wc -l` -gt 0 ]; then
		echo "Moab has stale reservation (last clean 25-75). Recycling Moab now."
		# mschedctl -R
		exit 1
	else
		echo "Moab has stale reservation (last clean >52 minutes. Please perform manual recovery."
		exit 2
	fi
else
# Nagios shoud return unknow state for stale logs
	echo "Moab condition unknow."
	exit 3
fi
