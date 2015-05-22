#!/bin/bash
# ----------check_file_ages.sh-----------
# This is going to check that there are at least a certain number of files in a folder younger than both warning and critical age levels.
#
# Version 0.01 - Feb/2015
# by Ben Field / ben.field@concreteplatform.com

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

function help {
	echo -e "
	This is going to check that there are at least a certain number of files in a folder younger than both warning and critical age levels.
		
	Usage:

	-d = Directory to be checked. Example: \"-d /tmp/\". Required parameter.

	-w,-c = Warning and critical levels respectively. Required parameter.
	
	-a = Number of files needed for each level. Inclusive.Not required. Defaults to 1.
		
	-r = recursive mode.
 	
 	-h = This help
	"
	exit -1
}

# ----------PARAMETER INPUT AND TESTING-----------

DIRECTORYFLAG=false
WARNINGFLAG=false
CRITICALFLAG=false
ARGUMENTFLAG=false
NUMBER=1
RECURSE="-maxdepth 1"

while getopts "d:w:c:t:a:r" OPT; do
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
		"a") NUMBER=$OPTARG
		;;
		"r") RECURSE=""
		;;
		"t") if [ $OPTARG == "file" ]; then
			TYPE="-type f"
		elif [ $OPTARG == "directory" ]; then
			TYPE="-type d"
		else
			TYPE=""
		fi
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
	echo "UNKNOWN - Warning level should not be greater than Critical level" >&2
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

FILE_COUNT_WARNING=`find $DIRECTORY $RECURSE -ctime -$WARNING $TYPE | wc -l`

FILE_COUNT_CRITICAL=`find $DIRECTORY $RECURSE -ctime -$CRITICAL $TYPE | wc -l`

# ----------FILE COUNT TEST AND RETURN TO NAGIOS-----------

if [ $FILE_COUNT_CRITICAL -lt $NUMBER ]; then
	echo "CRITICAL - $FILE_COUNT_CRITICAL files newer than $CRITICAL days in $DIRECTORY - Threshold is $NUMBER"
	exit $STATE_CRITICAL
elif [ $FILE_COUNT_WARNING -lt $NUMBER ]; then
	echo "WARNING - $FILE_COUNT_WARNING files newer than $WARNING days in $DIRECTORY - Threshold is $NUMBER"
	exit $STATE_WARNING
else
	echo "OK - $FILE_COUNT_WARNING files newer than $WARNING days in $DIRECTORY - Threshold is $NUMBER"
	exit $STATE_OK
fi