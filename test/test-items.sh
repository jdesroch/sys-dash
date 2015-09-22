#!/bin/bash

. `dirname $0`/test.env

# Test specific logging configuration
. $LIB_DIR/logging.sh
LOG_DIR=log_items
LOG_LEVEL=$LOG_TRACE

#LOG_DATE_FMT=<format string for datetime>

test-items_reset() {
   ITEM_DIR=$LIB_DIR/../config/item
   . $LIB_DIR/sd-items.sh
}

test_isStartedGlobal() {
    isStarted global
    assert "[ $? -eq 0 ]" "Global started"
}
test_isStartedNgz1() {
    isStarted ngz1
    assert "[ $? -eq 0 ]" "ngz1 started"
}
test_isNotStartedNgz2() {
    isStarted ngz2
    assert "[ $? -ne 0 ]" "ngz2 not started"
}
test_isNotStartedNgz3() {
    isStarted ngz3
    assert "[ $? -ne 0 ]" "ngz3 not started"
}

test_itemcheckGlobalPass() {
    res_out=$(item_check disk_usage_pass global)
    res_code=$?
    assert "[ $res_code -eq 0 ]" "$res_out"
}
test_itemcheckGlobalFail() {
    res_out=$(item_check disk_usage_fail global)
    res_code=$?
    assert "[ $res_code -eq 2 ]" "$res_out"
}