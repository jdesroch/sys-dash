assert() {
    TEST=$1
    MSG=$2
    shift
    if [ $TEST ]; 
    then
        echo "$(basename $0):${FUNCNAME[1]} PASSED: $MSG"
    else
        echo "$(basename $0):${FUNCNAME[1]} FAILED ($TEST): $MSG"
    fi
}