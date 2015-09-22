#!/bin/bash

TEST_DIR=$(dirname $0)
RESULTS_DIR=$TEST_DIR/results
mkdir -p $RESULTS_DIR

setTestGroup() {
    TEST_GROUP=$1
    TEST_OUT="$RESULTS_DIR/${TEST_GROUP}.txt"
    cat /dev/null > $TEST_OUT
}

for test_file in $(ls $TEST_DIR/test-*)
do
    setTestGroup $(basename "$test_file" | cut -d\. -f1)

    echo -e "\nLoading test file $test_file"
    . $test_file
    reset=${TEST_GROUP}_reset
    for test_func in $(grep test_ $test_file | grep "()" | grep -v \# | cut -d\( -f1)
    do
        echo -e "\tRunning $test_func"
        $reset
        $test_func >> $TEST_OUT
    done
    $reset
    echo -e "Result summary:\t${TEST_GROUP}"
    echo -e "\tPASS: $(grep PASS $TEST_OUT | wc -l) \tFAIL: $(grep FAIL $TEST_OUT | wc -l)"
done

echo -e "\nResult details found in $RESULTS_DIR\n"

