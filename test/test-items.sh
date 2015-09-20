#!/bin/bash

. `dirname $0`/test.env
. $LIB_DIR/logging.sh

test-items_reset() {
   ITEM_DIR=$LIB_DIR/../config/item
   . $LIB_DIR/sd-items.sh
}

test_tester() {
    assert "$(echo $ITEM_LIST | wc -w) -eq 3" "Three items"
}