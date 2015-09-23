#!/bin/bash

usage() {
    echo `basename $0` "update"
    echo `basename $0` "get <item> [-z <zone>]" 
}

if [ $# != 0 ] 
then
    usage
    exit 1
fi

. $(dirname $0)/../config/sys-dash.env 

data_updateAll
log_info "Item data updated"

js_view_update
log_info "JS view updated"