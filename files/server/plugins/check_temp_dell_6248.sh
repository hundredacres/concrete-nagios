#!/bin/bash

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

#This will check the temperature of the 6248 (using the OID 1.3.6.1.4.1.674.10895.5000.2.6132.1.1.43.1) and compare it to 
#supplied warning and critical levels. Output will be parsable by nagios.
#
#Options:
#
#-w INTEGER
#   Exit with WARNING status if the temp is less than INTEGER
#
#-c INTEGER
#   Exit with CRITICAL status if the temp is less than INTEGER
#
#-i STRING
#   IP of the 6248 to check
#
#-C STRING
#   SNMP community of the 6248 to check

WARNINGFLAG=false
CRITICALFLAG=false
IPFLAG=false
COMMUNITYFLAG=false
ARGUEMENTFLAG=false

#This block will test the arguements as parsed
while getopts 'w:c:i:C:' opt; do
	case $opt in
		w) WARNING=$OPTARG
		if ! [ $WARNING -eq $WARNING ] 2>/dev/null; then
			echo "Warning value is not an integer!" >&2
			ARGUEMENTFLAG=true	
		fi
		WARNINGFLAG=true
		;;
		c) CRITICAL=$OPTARG
                if ! [ $CRITICAL -eq $CRITICAL ] 2>/dev/null; then
                        echo "Critical value is not an integer!" >&2
                        ARGUEMENTFLAG=true
                fi
		CRITICALFLAG=true
                ;;
		i) IP=$OPTARG
		#Tests if ip is in correct format
		#First check if basic format is correct
		if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
			#Then test if IP is in sensible range
			iterator=1
			while [ $iterator -le 4 ]; do 
				number=`echo $IP | cut -d . -f $iterator`
				if [ $number -ge 256 ]; then
					echo "The IP supplied is not in a valid format" >&2
					ARGUEMENTFLAG=true
				fi
				iterator=$(($iterator+1))
			done 
		else
			echo "The IP supplied is not in a valid format" >&2
			exit 1
		fi
		IPFLAG=true
		;;
		C) COMMUNITY=$OPTARG
		COMMUNITYFLAG=true
		;;
		\?) echo "Invalid option: -$OPTARG" >&2
    		exit 1
    		;;
  		:) echo "Option -$OPTARG requires an argument." >&2
    		exit 1
    		;;
	esac
done 

#Checks to see if any arguments are missing:
if ! $WARNINGFLAG; then
	echo "A Warning level is required!" >&2
	ARGUEMENTFLAG=true
fi
if ! $CRITICALFLAG; then
        echo "A Critical level is required!" >&2
        ARGUEMENTFLAG=true
fi
if ! $IPFLAG; then
        echo "An IP address is required!" >&2
        ARGUEMENTFLAG=true
fi
if ! $COMMUNITYFLAG; then
        echo "A community name is required!" >&2
        ARGUEMENTFLAG=true
fi
if $ARGUEMENTFLAG; then
	exit $STATE_UNKNOWN
fi

#Checks for sane Warning/Critical levels
if [ $WARNING -gt $CRITICAL ]; then
	echo "Warning level should not be higher than Critical level"
	exit $STATE_UNKNOWN
fi

#grabs the current temperature using snmpwalk from the ip and snmp community provided
CURRENTTEMP=`snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.4.1.674.10895.5000.2.6132.1.1.43.1.8.1.4 | cut -d ' ' -f 4`
#Checks for sane temperature
if ! [ $CURRENTTEMP -eq $CURRENTTEMP ]; then
	echo "Not recieving a sane temperature!"
	exit $STATE_UNKNOWN
fi

#Checks the temperature against the warning and critical levels and gives a nagios compatible response
if [ $CURRENTTEMP -lt $WARNING ]; then
	echo "TEMP OK - Current Temperature is $CURRENTTEMP"
	exit $STATE_OK
elif [ $CURRENTTEMP -lt $CRITICAL ]; then
	echo "TEMP WARNING - Current Temperature is $CURRENTTEMP"
	exit $STATE_WARNING
else
	echo "TEMP CRITICAL - Current Temperature is $CURRENTTEMP"
        exit $STATE_CRITICAL
fi
