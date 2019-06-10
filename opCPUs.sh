#!/bin/bash

# doc: https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-devices-system-cpu

#===================================================
# Instructions:
if [ "$1" == "" ]; then
    echo "***** Script for disable or enable threads *****"
    echo "* Usage: `basename $0` [NUM or all or info]"
    echo "* NUM: is the number of threads needed"
    exit 0
fi
#===================================================
# Variables:
NUM=""
END=""

if [ "$1" == "info" ]; then
    lscpu
    exit 0
fi

#START=$((`cat /sys/devices/system/cpu/possible | cut -d'-' -f1` + 1))
if [ "$1" == "all" ]; then
        NUM=$((`cat /sys/devices/system/cpu/possible | sed 's/0-//'` + 1))
    else
        case $1 in
            ''|*[!0-9]*) echo "illegal parameter"
                         exit 0;;
            *) NUM=$1 ;;
        esac
fi

END=$((`cat /sys/devices/system/cpu/possible | sed 's/0-//'` + 0))

if [ "$NUM" == "0" ]; then
    NUM=1
fi

END1=$(($END + 1))
if [ $NUM -gt $END1 ]; then
    NUM=$END1
fi

#echo "NUM: $NUM"
#echo "END: $END"

#===================================================
# Do the work:
# the dir: /sys/devices/system/cpu/cpu0/ don't have the "online" file
for i in $(eval echo "{1..$END}"); do
    IS_ONLINE=$(cat /sys/devices/system/cpu/cpu$i/online)
    
#echo ""
    if [ $IS_ONLINE -eq 1 ]; then
        #echo "$i is online"
        if [ $i -ge $NUM ]; then
            #echo "mudando $i para offline"
            echo 0 > /sys/devices/system/cpu/cpu$i/online
        fi
    else
        #echo "$i is offline"
        if [ $i -lt $NUM ]; then
            #echo "mudando $i para online"
            echo 1 > /sys/devices/system/cpu/cpu$i/online
        fi
    fi
done

# like: echo 0 > /sys/devices/system/cpu/cpu7/online
#===================================================
# Informations after:
lscpu
exit 0

