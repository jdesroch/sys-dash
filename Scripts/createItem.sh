#!/usr/bin/ksh
. `dirname $0`/../lib/sys-dash.env 
#TODO: Make this part of an item.sh script with other stuf
usage() {
    echo "Usage: `basename $0` -i <new_item_name> -c <creator>"
    echo "  -i  Name of file and function namespace"
    echo "  -c  Username of file creator - no spaces"
    exit 1
}

ITEM_NAME=TODO_ITEM_NAME
CREATOR=TODO_CREATOR
DATE=`date '+%Y%m%d'`
#TODO: Add AUTO_FIX=false

if [ $# != 4 ]
then
    usage
fi

while getopts :i:c: ITEM_ARG 2>/dev/null
do 
    case $ITEM_ARG in
        i) ITEM_NAME=$OPTARG
            ;;
        c) CREATOR=$OPTARG
            ;;
        \?) usage
            ;;
    esac
done

ITEM_PATH=$ITEM_DIR/$ITEM_NAME
echo "New Item Path: $ITEM_PATH"

if [ -f $ITEM_PATH ]
then
    echo "WARNING: File already exists for item."
    echo "Original file backup:"
    echo "  $ITEM_DIR/$ITEM_NAME.bak"
    cp -p $ITEM_PATH $ITEM_PATH.bak
fi

cat $ITEM_TEMPLATE \
    | sed s/\<item_name\>/$ITEM_NAME/g \
    | sed s/\<creator\>/$CREATOR/g \
    | sed s/\<date\>/$DATE/g \
    > $ITEM_PATH
# chown root:sysadmin $ITEM_PATH
chmod 660 $ITEM_PATH
