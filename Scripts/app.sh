#!/bin/bash
. $(dirname $0)/sys-dash.env 

usage() {
    SCRIPT=$(basename $0)
    echo "Usage:"
    echo "  $SCRIPT start|stop"
    exit 1
}

if [ $# -ne 1 ]; then usage; fi

# Read args start or stop
case $1 in
    start)  startCron ;;
    stop)   stopCron ;;
    *) usage ;;
esac

export EDITOR=vi

startCron() {
    echo Start cron
    # Create cron to updateAll data
    #echo "#* * * * * $SD_SCRIPTS/results.sh updateAll >/dev/null 2>&1" | crontab -
}

stopCron() {
    echo Stop cron
    # Comment out updateAll cron
    #echo "#* * * * * $SD_SCRIPTS/results.sh updateAll >/dev/null 2>&1" | crontab -
}