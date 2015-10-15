#!/bin/bash
#
# Event handler script for restarting the web server on the local machine
#
# Note: This script will only restart the web server if the service is
#       retried 3 times (in a "soft" state) or if the web service somehow
#       manages to fall into a "hard" error state.
#
# This has been completly ripped off from the nagios3 examples page. However, this is going to be reengineered so it actually uses getopts. 
# It should fare as a decent framework for future event-handlers we create.
# Options:
# -s State (OK, Warning, Critical, Unknown)
# The state of the service
# -t Type (Soft, Hard)
# The type of state
# -a Attempts
# The number of attempts checked
# -h Host
# The host to resync

STATEFLAG=false
TYPEFLAG=false
ATTEMPTFLAG=false
ARGUMENTFLAG=false
HOSTFLAG=false
COMMANDFLAG=false

#This block will test the arguments as parsed
while getopts 's:t:a:h:c:' opt; do
	case $opt in
		s)	STATE=$OPTARG
			STATEFLAG=true
			;;
		t)	TYPE=$OPTARG
			TYPEFLAG=true
			;;
		a)	ATTEMPT=$OPTARG
			ATTEMPTFLAG=true
			;;
		h)	HOST=$OPTARG
			HOSTFLAG=true
			;;
		c)	COMMAND=$OPTARG
			COMMANDFLAG=true
			;;	
		\?) echo "Invalid option: -$OPTARG"
			ARGUMENTFLAG=true
			;;
		:) echo "Option -$OPTARG requires an argument."
			ARGUMENTFLAG=true
			;;	
	esac
done

#Checks for missing arguments
if ! $STATEFLAG; then
	echo "Option State is missing"
	ARGUMENTFLAG=true
fi
if ! $TYPEFLAG; then
	echo "Option Type is missing"
	ARGUMENTFLAG=true
fi
if ! $ATTEMPTFLAG; then
	echo "Option Attempts is missing"
	ARGUMENTFLAG=true
fi
if ! $HOSTFLAG; then
	echo "Option Host is missing"
	ARGUMENTFLAG=true
fi
if ! $COMMANDFLAG; then
	echo "Option Command is missing"
	ARGUMENTFLAG=true
fi
if $ARGUMENTFLAG; then
	exit 1
fi

#Running the actual event handler:
case $STATE in
	OK)	
		# The service just came back up, so don't do anything...
		;;
	UNKNOWN)	
		# We don't know what might be causing an unknown error, so don't do anything...
		;;
	WARNING)
		case $TYPE in
			SOFT)
				case $ATTEMPT in
					#Will run command on the 3rd soft warning
					3)	
						/usr/lib/nagios/plugins/check_nrpe -H $HOST -c $COMMAND
						;;
				esac
				;;
			HARD)
				/usr/lib/nagios/plugins/check_nrpe -H $HOST -c $COMMAND
				;;
		esac
		;;
	CRITICAL)
		case $TYPE in
			SOFT)
				case $ATTEMPT in
					#Will run command on the 3rd soft warning
					3)	
						/usr/lib/nagios/plugins/check_nrpe -H $HOST -c $COMMAND
						;;
				esac
				;;
			HARD)
				/usr/lib/nagios/plugins/check_nrpe -H $HOST -c $COMMAND
				;;
		esac
		;;
esac

exit 0