#!/bin/bash
# ----------check_lowmemory.sh-----------
# This is going to check the low memory of the machine in question.
#
# Version 0.01 - Jan/2015
# by Ben Field / ben.field@concreteplatform.com

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

function help {
	echo -e "
	This is going to check the low memory of the machine in question. It will test to 1dp, but parameters must be integers!
		
	Usage:

	-d = Directory to be checked. Example: \"-d /tmp/\". Required parameter.

	-w,-c = Warning and critical levels respectively. Required parameter.
		
	-r = recursive mode.
 	
 	-h = This help
	"
	exit -1
}

# ----------PARAMETER INPUT AND TESTING-----------

WARNINGFLAG=false
ARGUMENTFLAG=false
RECURSE=""

while getopts "w:c:" OPT; do
	case $OPT in
		"w") WARNING=$OPTARG
		WARNINGFLAG=true
		;;
		"c") CRITICAL=$OPTARG
		CRITICALFLAG=true
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

#Checks for sane Warning/Critical levels
if [ $WARNING -lt $CRITICAL ]; then
	echo "UNKNOWN - Warning level should not be lower than Critical level" >&2
	ARGUMENTFLAG=true
fi

if $ARGUMENTFLAG; then
	exit $STATE_UNKNOWN
fi

# ----------LOW MEMORY CALCULATION-----------

LOWMEMORYSPECIFIC=`/usr/bin/free -lm | /bin/grep Low | /usr/bin/awk '{printf("%-.1f\n", $4/$2*100); }'`

LOWMEMORYNODECIMAL=`/usr/bin/free -lm | /bin/grep Low | /usr/bin/awk '{printf("%-.0f\n", $4/$2*1000); }'`

CRITICALNODECIMAL=`/usr/bin/expr $CRITICAL \* 10`

WARNINGNODECIMAL=`/usr/bin/expr $WARNING \* 10`

# ----------LOW MEMORY TEST AND RETURN TO NAGIOS-----------

if [ $LOWMEMORYNODECIMAL -le $CRITICALNODECIMAL ]; then
        echo "CRITICAL - $LOWMEMORYSPECIFIC% of lowmemory free"
        exit $STATE_CRITICAL
elif [ $LOWMEMORYNODECIMAL -le $WARNINGNODECIMAL ]; then
        echo "WARNING - $LOWMEMORYSPECIFIC% of lowmemory free"
        exit $STATE_WARNING
else
        echo "OK - $LOWMEMORYSPECIFIC% of lowmemory free"
        exit $STATE_OK
