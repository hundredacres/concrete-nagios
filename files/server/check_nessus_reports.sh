#!/bin/bash
# =====================================
#    Author: Justin Miller
#     Date: 20-02-2015
#   Version: 1.0
# =====================================

# This check should only run between 7am and 11am at concrete, otherwise scans will be running.
NOW=$(date +%k%M)
if [[ $NOW -le 0700 ]] && [[ $NOW -ge 1100 ]]; then
	echo "OK - The check has been run outside of the normal time period, scans are in progress. "
	exit 0
fi


VERSION="1.0"

# Check if jq is available...
type jq >/dev/null 2>&1 || { echo >&2 "UNKNOWN - the jq utility is required for this check to run."; exit 3; }

# function to print usage...
function usage {
cat <<EOF 

Usage: ./check_nessus_report.sh -s SERVER:PORT -C CREDENTIALS_FILE -t "TARGET_SCAN" -w WARNING_THRESHOLD -c CRITICAL_THRESHOLD
 
CREDENTIALS_FILE should be readable by the user that runs this script, the first line should be username,
and second line should be the password.
e.g.

myNessusUsername
myPassword

Options:

(Required)
	-s SERVER:PORT (e.g. nessus.mydomain.net:8834 )
	-C CREDENTIALS_FILE path (e.g. /etc/.my_creds )
	-t TARGET_SCAN (e.g. "My Daily Network Scan" )

(Optional)
	-w WARNING_THRESHOLD (number of critical vulnerabilities, integer, defaults to 999)
	-c CRITICAL_THRESHOLD (number of critical vulnerabilities, integer, defaults to 999)
	-h Display help / usage


Example:
./check_nessus_report.sh -s nessus.mydomain.net:8834 -C /etc/.my-credentials -t "My Daily Network Scan" -w 5 -c 10


EOF

exit 2
}

# Parse options...
while getopts ":s:C:t:w:c:h:V" OPTIONS; do
	case "${OPTIONS}" in
		s) SERVER=${OPTARG} ;;
		C) CREDENTIALS_FILE=${OPTARG} ;;
		t) TARGET_SCAN=${OPTARG} ;;
		w) WARNING_THRESHOLD=${OPTARG} ;;
		c) CRITICAL_THRESHOLD=${OPTARG} ;;
		h) usage ;;
		V) echo "check_nessus_scans.sh version: $VERSION";;
		*) usage ;;
	esac
done

if [[ -z $WARNING_THRESHOLD ]]; then WARNING_THRESHOLD=999; fi
if [[ -z $CRITICAL_THRESHOLD ]]; then CRITICAL_THRESHOLD=999;  fi

# username and password taken from file, more secure than passing to nrpe as parameters...
USERNAME=$(head -1 $CREDENTIALS_FILE)
PASSWORD=$(tail -1 $CREDENTIALS_FILE)


# Get authentication token from the server...	
TOKEN_STRING="{ \"username\": \"$USERNAME\", \"password\": \"$PASSWORD\" }"
TOKEN=$(curl -sS -k -X POST -H 'Content-Type: application/json' -d "$TOKEN_STRING" \
https://$SERVER/session) 
TOKEN=$(echo $TOKEN | jq '.[]')
TOKEN="${TOKEN//\"}"


SCAN_NAME_STRING="select (.name == \"$TARGET_SCAN\")"

# Get list of scans from the server...
SCAN_ID=$(curl -sS -k -H "X-Cookie: token=$TOKEN" https://$SERVER/scans \
| jq --raw-output '.[] | .[] | {name, starttime, id}' 2> /dev/null | jq "$SCAN_NAME_STRING")


# Select only the scans which have a start time, those which have been run...
SCAN_ID=$(echo $SCAN_ID | jq 'select (.starttime != null) .id')

if [[ -z "$SCAN_ID" ]]; then
	echo "UNKNOWN - Unable to find the requested scan."
	exit 3
fi


# Request from the server an export of the scan...
FILENAME=$(curl -sS -k -X POST -H "X-Cookie: token=$TOKEN" --data "format=nessus" https://$SERVER/scans/$SCAN_ID/export)
FILENAME=$(echo $FILENAME | jq '.[]')

# Wait a short time for the scan to be prepared by the server...
sleep 2

# Gets status of report, keeps trying until report ready to download
for a in {1..30}; do
	STATUS=$(curl -sS -k -H "X-Cookie: token=$TOKEN" https://$SERVER/scans/$SCAN_ID/export/$FILENAME/status)
	STATUS=$(echo $STATUS | jq '.[]')
	if [[ "$STATUS" == *"ready"* ]]; then 
		break
	fi
	# After 30 retrys, 30 seconds, then give up...
	if [[ $a -eq 30 ]]; then
		echo "UNKNOWN - Unable to download report!"
		exit 3
	fi
	sleep 1
done

# Make temp file to store the report for processing, but only if the time is OK (i.e. scans not running)
REPORT_FILE=$(mktemp /tmp/check_nessus_report_XXXXX)

# download report...
curl -sS -k -H "X-Cookie: token=$TOKEN" https://$SERVER/scans/$SCAN_ID/export/$FILENAME/download >> $REPORT_FILE

# Search through the downloaded report for critical and high vulnerabilities...
CRIT_VULNS=$(echo "$(grep -i severity=\"4\" $REPORT_FILE  | wc -l)"|bc)
HIGH_VULNS=$(echo "$(grep -i severity=\"3\" $REPORT_FILE  | wc -l)"|bc)
MED_VULNS=$(echo "$(grep -i severity=\"2\" $REPORT_FILE  | wc -l)"|bc)

PERF_DATA="critical=$CRIT_VULNS, high=$HIGH_VULNS, medium=$MED_VULNS"

# Remove report file...
rm -f $REPORT_FILE

############################################################################
## Optional, also write performace data to tmp file to be parsed by munin...
## replace spaces with underscores
#SCAN_NAME=${TARGET_SCAN// /_} 

## make a temp file
#TEMP_STRING="/tmp/check_nessus_perf_$SCAN_NAME"
#PERF_FILE=$(mktemp /tmp/check_nessus_perf-$SCAN_NAME-XXXXX)
#echo "$PERF_DATA" > $PERF_FILE
############################################################################


if [[ $CRIT_VULNS -le $WARNING_THRESHOLD ]]; then
	echo "OK - There are $CRIT_VULNS critical and $HIGH_VULNS high vulnerabilities in $TARGET_SCAN. | $PERF_DATA"
	exit 0
elif [[ $CRIT_VULNS -lt $CRITICAL_THRESHOLD ]]; then
	echo "WARNING - There are $CRIT_VULNS critical and $HIGH_VULNS high vulnerabilities in $TARGET_SCAN. | $PERF_DATA"
	exit 1
elif [[ $CRIT_VULNS -ge $CRITICAL_THRESHOLD ]]; then 
	echo "CRITICAL - There are $CRIT_VULNS and critical $HIGH_VULNS high vulnerabilities in $TARGET_SCAN. | $PERF_DATA"
	exit 2
else
	echo "UNKNOWN - Check script output"
	exit 3
fi