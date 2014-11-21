#!/bin/bash
# ----------check_file_count.sh-----------
# This is going to check the number of files in a specific directory is below certain thresholds 
# and return results in a nagios compatible format.
#
# Version 0.01 - Nov/2014
# by Ben Field / ben.field@concreteplatform.com

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

function help {
	echo -e "
	This is going to check the number of files in a specific directory is below certain thresholds 
	and return results in a nagios compatible format.
		
	Usage:

	-d = Directory to be checked. Example: \"-d /tmp/\". Required parameter.

	-w,-c = Warning and critical levels respectively. Required parameter.
		
	-r = recursive mode.
 	
 	-h = This help
	"
	exit -1
}

# ----------PARAMETER INPUT AND TESTING-----------

DIRECTORYFLAG=false
WARNINGFLAG=false
DIRECTORYFLAG=false
ARGUMENTFLAG=false
RECURSE=""

while getopts "d:w:c:r" OPT; do
	case $OPT in
		"d") DIRECTORY=$OPTARG
		DIRECTORYFLAG=true
		;;
		"w") WARNING=$OPTARG
		WARNINGFLAG=true
		;;
		"c") CRITICAL=$OPTARG
		CRITICALFLAG=true
		;;
		"r") RECURSE="-R"
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
if ! $WARNINGFLAG; then
	echo "UNKNOWN - Warning level parameter required" >&2
	ARGUMENTFLAG=true
fi
if ! $CRITICALFLAG; then
	echo "UNKNOWN - Critical level parameter required" >&2
	ARGUMENTFLAG=true
fi
if ! $DIRECTORYFLAG; then
	echo "UNKNOWN - Directory parameter required" >&2
	ARGUMENTFLAG=true
fi

#Checks for sane Warning/Critical levels
if [ $WARNING -gt $CRITICAL ]; then
	echo "UNKNOWN - Warning level should not be higher than Critical level" >&2
	ARGUMENTFLAG=true
fi

#Checks to see if valid directory
if [ ! -d $DIRECTORY ]; then
	echo "UNKNOWN - $DIRECTORY is not a valid directory" >&2
	ARGUMENTFLAG=true
fi

if $ARGUMENTFLAG; then
	exit $STATE_UNKNOWN
fi

# ----------FILE COUNT CALCULATION-----------

FILE_COUNT=`ls -la $RECURSE $DIRECTORY | grep -i ^- | wc -l`

# ----------FILE COUNT TEST AND RETURN TO NAGIOS-----------

if [ $FILE_COUNT -ge $CRITICAL ]; then
	echo "CRITICAL - $FILE_COUNT files in $DIRECTORY"
	exit $STATE_CRITICAL
elif [ $FILE_COUNT -ge $WARNING ]; then
	echo "WARNING - $FILE_COUNT files in $DIRECTORY"
	exit $STATE_WARNING
else
	echo "OK - $FILE_COUNT files in $DIRECTORY"
	exit $STATE_OK
fi