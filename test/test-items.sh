#!/bin/bash

. `dirname $0`/test.env
. $LIB_DIR/logging.sh

test-items_reset() {
   ITEM_DIR=$LIB_DIR/../config/item
   . $LIB_DIR/sd-items.sh
}

test_itemcheckGlobal() {
    res_out=$(item_check disk_usage_pass global)
    res_code=$?
    assert "$res_code -eq 0" "$res_out"
}