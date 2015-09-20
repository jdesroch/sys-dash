###############################
#   Data file format
#   line:=<lastpass>:<lastrun>:<result>:<output>
#   lastpass:=datetime
#   lastrun:=datetime
#   datetime:=<YYYYMMDDhhmmss>
#   result:=<"pass"|"fail"|"error">
#   output:=STRING
#
###############################
if [ -z "$DATA_DIR" ]; then 
    echo "DATA_DIR must be defined"
    exit 1
fi
mkdir -p $DATA_DIR

DELIM="~"
# Result fields
LASTPASS=f1
LASTRUN=f2
RESULT=f3
OUTPUT=f4

# API Functions
# validateZoneItemArgs <zone> <item>
validateZoneItemArgs(){
    zone=$1; item=$2
    if [ -z "$1" -o -z "$2" ]
    then
        echo "Invalid zone ($zone) or item ($item)"
        exit 1 
    fi
    data_file=`data_getFile $zone $item`
}
data_getFile(){
    touch $DATA_DIR/$1"-"$2
    echo $DATA_DIR/$1"-"$2
}
# data_getValue <zone> <item> <dataField>
data_getValue(){
    validateZoneItemArgs $1 $2
    if [ $# -eq 3 ]
    then
        dataField=$3
        echo `tail -1 $data_file | cut -d $DELIM -$dataField`
    else
        echo `tail -1 $data_file`
    fi
}
data_getValues(){
    for item in $ITEM_LIST
    do
        for zone in $(item_zones $item)
        do
            echo $zone$DELIM$item$DELIM`data_getValue $zone $item`
        done
    done
}
# data_clear <zone> <item>
data_clear(){
    validateZoneItemArgs $1 $2
    cat /dev/null > `data_getFile $zone $item`
}
data_clearAll(){
    rm $DATA_DIR/*
}
# data_update <zone> <item>
data_update(){
    validateZoneItemArgs $1 $2
    
    lastpass=`data_getValue $1 $2 $LASTPASS`
    currdate=`date '+%Y%m%d%H%M%S'`
    output=`item_check $item $zone`
    res=$?
    if [ $res -eq "0" ]
    then
        result=pass
        lastpass=$currdate
    elif [ $res -eq "2" ]
    then
        result=fail
    else
        result=error
    fi
    
    #TODO: Fix item data history
    
    #TMP=$cache".tmp"
    #HIST=`cacheSize $item`
    #tail -$HIST $cache > $TMP
    #cat $TMP > $cache
    echo "$lastpass$DELIM$currdate$DELIM$result$DELIM$output" > $data_file
    #rm $TMP
}
data_updateAll(){
    for item in $ITEM_LIST
    do
        for zone in `item_zones $item`
        do
            data_update $zone $item
        done
    done
}