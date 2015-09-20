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
    echo ""
    echo "Loading test file $test_file"
    . $test_file
    reset=${TEST_GROUP}_reset
    for test_func in $(grep test_ $test_file | grep "()" | grep -v \# | cut -d\( -f1)
    do
        echo "  Running $test_func"
        $reset
        $test_func >> $TEST_OUT
    done
    $reset
    echo "${TEST_GROUP} results:"
    echo "PASS: $(grep PASS $TEST_OUT | wc -l)"
    echo "FAIL: $(grep FAIL $TEST_OUT | wc -l)"
done

