#!/bin/bash

# Author		Julien.Simon@concrete.cc
# Version 		V1

scriptName=$(basename $0)

usage() {
        echo "Usage:"
        echo "$0 -w <warnlevel> -c <critlevel> -d <dir> [ -t <ext> ]"
        exit 1
}

while getopts "w:c:d:t:" o; do
    case "${o}" in
        w)
            w=${OPTARG}
            ;;
        c)
            c=${OPTARG}
            ;;
        d)
            d=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${w}" ] || [ -z "${c}" ] || [ -z "${d}" ] || [ "${w}" -lt "0" ] ||  [ "${c}" -lt "0" ] || [ ! -d "${d}"  ] ; then
    usage
fi

numWarn="find ${d} -mtime -${w} -type f "
[ -z ${t} ] ||  numWarn=$numWarn" -name *${t}"
numWarn=$($numWarn | wc -l)

numCrit="find ${d} -mtime -${c} -type f "
[ -z ${t} ] ||  numCrit=$numCrit" -name *${t}"
numCrit=$($numCrit | wc -l)

num="find ${d} -type f "
[ -z ${t} ] ||  num=$num" -name *${t}"
num=$($num | wc -l)


if [ "$num" -eq "0" ]; then
    echo "$scriptName - CRITICAL - No *${t} file found in $(hostname):${d} !"
    $(exit 2)
elif [ "$numCrit" -eq "0" ]; then
    echo "$scriptName - CRITICAL - No *${t} file modified in the last ${w} days in $(hostname):${d}"
    $(exit 2)
elif [ "$numWarn" -eq "0" ]; then
    echo "$scriptName - WARNING - No *${t} file modified in the last ${c} days in $(hostname):${d}"
    $(exit 1)
else
    echo "$scriptName - OK - $num *${t} files are in $(hostname):${d}, $numWarn not older then ${w} days, $numCrit files not older then ${c} days"
    $(exit 0)
fi





