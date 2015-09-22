###############################
# Configuration - System checks
# Prerequisites:
#   Define $ITEM_DIR
#   Import logging.sh
###############################
if [ -z "$ITEM_DIR" ]; then 
    echo "ITEM_DIR must be defined"
    exit 1
fi

# Execution within a container (Zone, LXC, etc.)
# This should be used within items' check method
# global container represents the host OS (Solaris global zone)
HOST=global
kernel=$(uname -s)
# isStarted <zone>
isStarted() {
    xc $1 ls > /dev/null 2>&1
}
#xc <zone> <command>
xc() {
    set -x
    container=$1; shift
    command=$@
    if [ "$container" = "$HOST" ]
    then # Run command directly
        $@
    else
        case $kernel in
            "Linux") sudo lxc-attach -n $container -- $command ;;
            "SunOS") zlogin $container "$command" ;;
            *) return 1 ;;
        esac
    fi
    set +x
}

item_isValid() {
    echo $ITEM_LIST | grep $1 > /dev/null
    if [ "$?" -eq 0 ]
    then return 0
    else return 1
    fi
}

# Generic way to call an item's functions
# run <item> <function> [<additional args>...]
item_run() {
    item=$1
    function=$2
    shift 2
log_debug "Run $item.$function($@)"
    item_isValid $item
    if [ "$? -eq 0" ]
    then
        $item"_"$function "$@"
    else
        log_warn "Passed item=$item; function=$function; args=$@... Item is not valid"
        exit 1
    fi
}

##########################
# Item interface functions
##########################
# item_title <item>
item_title() {
    item_run $1 title
}
# item_historySize <item>
item_historySize() {
    item_run $1 historySize
}
# item_zones <item>
item_zones() {
    item_run $1 zones
}
# item_tags <item>
item_tags() {
    item_run $1 tags
}
# item_check <item> <zone>
item_check() {
    item=$1
    zone=$2
    if isStarted $zone
    then
        item_run $item check $zone
    else
        echo "Zone is not available"
        return 1 
    fi
}
# item_description <item>
item_description() {
    item_run $1 description
}
# item_commands <item>
item_commands() {
    item_run $1 commands
}
# item_indicators <item>
item_indicators() {
    item_run $1 indicators
}
# item_fixMethod <item>
item_fixMethod() {
    item_run $1 fixMethod
}
# item_hasAutoFix <item>
item_hasAutoFix() {
    item_run $1 hasAutoFix
}
# item_autoFix <item>
item_autoFix() {
    item_run $1 autoFix
}

item_toString() {
    item=$1
    echo Checking $item 
    echo "------------------"
    item_check $item
    echo ""
    echo "---Description---"
    item_description $item
    echo ""
    echo "---Commands---"
    item_commands $item
    echo ""
    echo "---Problem Indicator---"
    item_indicators $item
    echo ""
    echo "---Possible Fix---"
    item_fixMethod $item
    echo ""
}

# Use tmp file to collect unique zones used in all items
TMP_ZONES=/tmp/zonelist.sd
collectZones() {
    for zone in $(item_zones $1)
    do
    echo $zone >> $TMP_ZONES
    done
}
saveZoneList() {
    for zone in $(cat $TMP_ZONES | sort | uniq)
    do
        ZONE_LIST=$ZONE_LIST" "$zone
    done
    rm $TMP_ZONES
log_debug "ZONE_LIST=$ZONE_LIST"
}
# Use tmp file to collect unique tags used in all items
TMP_TAGS=/tmp/taglist.sd
collectTags() {
    for tag in $(item_tags $1)
    do
    echo $tag >> $TMP_TAGS
    done
}
saveTagList() {
    for tag in $(cat $TMP_TAGS | sort | uniq)
    do
        TAG_LIST=$TAG_LIST" "$tag
    done
    rm $TMP_TAGS
log_debug "TAG_LIST=$TAG_LIST"
}

# Configuration API
if [ -z "$API_LOADED" ]
then
    ITEM_LIST=`ls $ITEM_DIR | grep -v bak`
    ITEM_PATTERN=`echo $ITEM_LIST | tr " " "|"`


log_debug "Loading items..."
    # Load each item
    for item in $ITEM_LIST
    do
log_debug "Loading item: $item..."
        . $ITEM_DIR/$item
        collectZones $item
        collectTags $item
log_info "Loaded item: $item"
    done
    
    saveZoneList #"global" #TODO Generate from current items
    saveTagList #TODO Future feature...Generate from tags given to items 
    #Intend to allow views grouped by tags (i.e. system functions)

    API_LOADED="true"
log_debug "Loading items complete"
fi