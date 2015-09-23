#!/bin/bash
############################################
# Command line access to stored results
############################################
. $(dirname $0)/../config/sys-dash.env 

usage() {
    SCRIPT=$(basename $0)
    echo "Usage:"
    echo "  $SCRIPT update <item> <zone>"
    echo "  $SCRIPT updateAll"
    echo "  $SCRIPT clear <item> <zone>"
    echo "  $SCRIPT clearAll"
    echo "  $SCRIPT get [<item> [<zone>]]" 
}

case $1 in
    "update")       
        data_update $2 $3
        js_view_update
        ;;
    "updateAll")    
        data_updateAll
        js_view_update
        ;;
    "get")          
        if [ $# -eq 1 ]; then
            data_getValues
        elif [ $# -eq 2 ]; then
            for zone in $(item_zones $2); do
                data_getValue $2 $zone
            done
        elif [ $# -eq 3 ]; then
            data_getValue $2 $3
        else
            usage
        fi
    ;;
    "clear")        data_clear $2 $3 ;;
    "clearAll")     data_clearAll ;;
    *) usage ;;
esac