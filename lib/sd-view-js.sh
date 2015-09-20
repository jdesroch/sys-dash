###############################
# Javascript View
# Prerequisites:
#   Define $JS_DATA
#   Import logging.sh
#   Import sd-items.sh
#   Import sd-data.sh
###############################
if [ -z "$JS_DATA" ]; then 
    echo "JS_DATA must be defined"
    exit 1
fi

# Javascript helper functions
startSysData(){ 
    echo "var sysdata = {" > $JS_DATA 
}
endSysData(){ 
    append "};" 
}
append(){ 
    echo "$@" >> $JS_DATA 
}
# $listIndex tracks nested JS lists
# $listEmpty array tracking if the JS lists are empty
listIndex=-1
declare -a listEmpty
startList(){ 
    append "    $1: ["
    let "listIndex++"
    listEmpty[$listIndex]=true
    
}
listSeparator(){
    if [ "${listEmpty[$listIndex]}" = false ]
    then 
        append $1
    fi
    listEmpty[$listIndex]=false
}
endList(){
    append "    ]"
    let "listIndex--"
}
startObj(){ 
    append "{" 
}
endObj(){ 
    append "}" 
}
#TODO: maintain newline characters
propertyValue(){ 
    append "$1: \"`echo $2 | tr "\n" "\\\n"`\"," 
}
propertyValueLast(){ 
    append "$1: \"`echo $2 | tr "\n" "\\\n"`\""
}

# Work breakdown by items/results
writeItems(){
    startList items
    for item in $ITEM_LIST
    do
        listSeparator ","
        startObj #item
        propertyValue ID "$item"
        propertyValue title "`item_title $item`"
        propertyValue description "`item_description $item`"
        propertyValue commands "`item_commands $item`"
        propertyValue indicators "`item_indicators $item`"
        startList zones
        for zone in `item_zones $item`
        do
            listSeparator ","
            append "\"$zone\""
        done
        endList #zones
        append ","
        startList tags
        for tag in `item_tags $item`
        do
            listSeparator ","
            append "\"$tag\""
        done
        endList #tags
        endObj #item
    done
    endList #items
}

writeResults(){
    startList results
    for item in $ITEM_LIST
    do
        for zone in `item_zones $item`
        do
            listSeparator ","
            startObj #result
            propertyValue itemID $item
            propertyValue zone $zone
            propertyValue lastrun "`data_getValue $zone $item $LASTRUN`"
            propertyValue lastpass "`data_getValue $zone $item $LASTPASS`"
            propertyValue output "`data_getValue $zone $item $OUTPUT`"
            propertyValueLast status "`data_getValue $zone $item $RESULT`"
            endObj #result
        done
    done
    endList #results
}

writeZones() {
    startList zones
    for zone in $ZONE_LIST;
    do
        listSeparator ","
        append "\"$zone\""
    done
    endList #zones
}

writeTags() {
    startList tags
    for tag in $TAG_LIST;
    do
        listSeparator ","
        append "\"$tag\""
    done
    endList #tags
}

js_view_update() {
log_debug "JS view is updating"
    startSysData
    writeTags
    append ","
    writeZones
    append ","
    writeItems
    append ","
    writeResults
    endSysData
log_debug "JS view update complete"
}