#!/bin/bash
# ----------check_kernel_leak.sh-----------
# This is going to test for potential memory leaks, checking the available low memory and slab objects in use.
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
	This is going to test for potential memory leaks, checking the available low memory and slab objects in use.
		
	Usage:

	-w,-c = Warning and critical levels respectively. Required parameter. The format should be lowmemory,objectcount,total.
	Lowmemory should be an integer percentage and objectcount should be an integer. Total will be an integer - it will score
	1 point for each warning (lowmemory and critical) and 2 points for each critical.
	ie -w 2,8000000,3
 	
 	-h = This help
	"
	exit -1
}

# ----------PARAMETER INPUT AND TESTING-----------

WARNINGFLAG=false
ARGUMENTFLAG=false
RECURSE=""
TOTAL=0

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

#Checks to see if any arguments are missing, this should be improved:
if ! $WARNINGFLAG; then
	echo "UNKNOWN - Warning level parameter required" >&2
	ARGUMENTFLAG=true
fi
if ! $CRITICALFLAG; then
	echo "UNKNOWN - Critical level parameter required" >&2
	ARGUMENTFLAG=true
fi

WARNING_LOWMEMORY=`echo $WARNING | cut -d, -f1`
WARNING_OBJECTS=`echo $WARNING | cut -d, -f2`
WARNING_TOTAL=`echo $WARNING | cut -d, -f3`

CRITICAL_LOWMEMORY=`echo $CRITICAL | cut -d, -f1`
CRITICAL_OBJECTS=`echo $CRITICAL | cut -d, -f2`
CRITICAL_TOTAL=`echo $CRITICAL | cut -d, -f3`

#Checks for sane Warning/Critical levels
if [ $WARNING_LOWMEMORY -lt $CRITICAL_LOWMEMORY ]; then
	echo "UNKNOWN - Lowmemory Warning level should not be lower than Critical level" >&2
	ARGUMENTFLAG=true
fi
if [ $WARNING_OBJECTS -gt $CRITICAL_OBJECTS ]; then
	echo "UNKNOWN - Objects Warning level should not be higher than Critical level" >&2
	ARGUMENTFLAG=true
fi
if [ $WARNING_TOTAL -gt $CRITICAL_TOTAL ]; then
	echo "UNKNOWN - Total Warning level should not be higher than Critical level" >&2
	ARGUMENTFLAG=true
fi

if $ARGUMENTFLAG; then
	exit $STATE_UNKNOWN
fi

# ----------LOW MEMORY CALCULATION-----------

LOWMEMORYSPECIFIC=`/usr/bin/free -lm | /bin/grep Low | /usr/bin/awk '{printf("%-.1f\n", $4/$2*100); }'`

LOWMEMORYNODECIMAL=`/usr/bin/free -lm | /bin/grep Low | /usr/bin/awk '{printf("%-.0f\n", $4/$2*1000); }'`

CRITICALNODECIMAL=`/usr/bin/expr $CRITICAL_LOWMEMORY \* 10`

WARNINGNODECIMAL=`/usr/bin/expr $WARNING_LOWMEMORY \* 10`

# ----------LOW MEMORY TEST-----------

if [ $LOWMEMORYNODECIMAL -le $CRITICALNODECIMAL ]; then
        TOTAL=$TOTAL+2
elif [ $LOWMEMORYNODECIMAL -le $WARNINGNODECIMAL ]; then
        TOTAL=$TOTAL+1
fi

# ----------TOTAL OBJECTS CALCULATION-----------

TOTALOBJECTS=`/bin/cat /proc/slabinfo | /usr/bin/awk '{n=n+$2}END{print n}'`

# ----------TOTAL OBJECTS TEST-----------

if [ $TOTALOBJECTS -ge $CRITICAL_OBJECTS ]; then
        TOTAL=$TOTAL+2
elif [ $TOTALOBJECTS -ge $WARNING_OBJECTS ]; then
        TOTAL=$TOTAL+1
fi

# ----------RETURN TO NAGIOS-----------

if [ $TOTAL -ge $CRITICAL_TOTAL ]; then
        echo "CRITICAL - $LOWMEMORYSPECIFIC% of lowmemory free, $TOTALOBJECTS objects used"
        exit $STATE_CRITICAL
elif [ $TOTALOBJECTS -ge $WARNING_OBJECTS ]; then
        echo "WARNING - $LOWMEMORYSPECIFIC% of lowmemory free, $TOTALOBJECTS objects used"
        exit $STATE_WARNING
else
        echo "OK - $LOWMEMORYSPECIFIC% of lowmemory free, $TOTALOBJECTS objects used"
        exit $STATE_OK
fi