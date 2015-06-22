#!/bin/bash
# ----------check_mount.sh-----------
# This is going to check that there is a mountpoint at that path. This will probably timeout if there is a samba issue. It will only fail to critical.
#
# Version 0.01 - Jun/2015
# by Ben Field / ben.field@concreteplatform.com

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

function help {
	echo -e "
	This is going to check that there is a mountpoint at that path. This will probably timeout if there is a samba issue. It will only fail to critical.
		
	Usage:

	-p = Path to be checked. Example: \"-d /mnt/backups/\". Required parameter.
 	
 	-h = This help
	"
	exit -1
}

# ----------PARAMETER INPUT AND TESTING-----------

PATHFLAG=false
ARGUMENTFLAG=false
NUMBER=1
RECURSE="-maxdepth 1"

while getopts "p:h" OPT; do
	case $OPT in
		"p") PATH=$OPTARG
		PATHFLAG=true
		;;
		"h") echo "help:" && help
		;;
		\?) echo "UNKNOWN - Invalid option: -$OPT" >&2
		ARGUMENTFLAG=true
		;;
		:) echo "UNKNOWN - Option -$OPTARG requires an argument" >&2
		ARGUMENTFLAG=true
		;;
	esac
done		

#Checks to see if any arguments are missing:
if ! $PATHFLAG; then
	echo "UNKNOWN - PATH parameter required" >&2
	ARGUMENTFLAG=true
fi

#Checks to see if valid directory
if [ ! -d $PATH ]; then
	echo "UNKNOWN - $PATH is not a valid path" >&2
	ARGUMENTFLAG=true
fi

if $ARGUMENTFLAG; then
	exit $STATE_UNKNOWN
fi

# ----------MOUNTPOINT CHECK-----------

MOUNTPOINT=`/bin/mountpoint $PATH | /bin/grep "is a mountpoint" | /usr/bin/wc -l`

# ----------MOUNTPOINT TEST AND RETURN TO NAGIOS-----------

if [ $MOUNTPOINT -lt 1 ]; then
	echo "CRITICAL - $PATH is not a mount"
	exit $STATE_CRITICAL
else
	echo "OK - $PATH is a mount"
	exit $STATE_OK
fi