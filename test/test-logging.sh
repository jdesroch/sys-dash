#!/bin/bash

. `dirname $0`/test.env
#. $LIB_DIR/logging.sh

test-logging_reset() {
    if [ ! -z "$LOG_DIR" ]; then
        rm -rf $LOG_DIR
    fi
    LOG_LEVEL=
    LOG_FILE=
    LOG_DIR=
    . $LIB_DIR/logging.sh
}

# Logging level filtering
test_logLevelWarn() {
    LOG_LEVEL=$LOG_WARN
    log_clear
    log_trace "NOT logged"
    log_debug "NOT logged"
    log_info "NOT logged"
    log_warn "Logged"
    log_error "Logged"
    grep TRACE $(log_path) > /dev/null; traceResult=$?
    grep DEBUG $(log_path) > /dev/null; debugResult=$?
    grep INFO $(log_path) > /dev/null; infoResult=$?
    grep WARN $(log_path) > /dev/null; warnResult=$?
    grep ERROR $(log_path) > /dev/null; errorResult=$?
    assert "$traceResult -ne 0 \
        -a $debugResult -ne 0 \
        -a $infoResult -ne 0 \
        -a $warnResult -eq 0 \
        -a $errorResult -eq 0" \
        "Only LOG_LEVEL=$LOG_LEVEL and above are logged"
}

# Logging level filtering
test_logLevelInfo() {
    LOG_LEVEL=$LOG_INFO
    log_trace "NOT logged"
    log_debug "NOT logged"
    log_info "Logged"
    log_warn "Logged"
    log_error "Logged"
    grep TRACE $(log_path) > /dev/null; traceResult=$?
    grep DEBUG $(log_path) > /dev/null; debugResult=$?
    grep INFO $(log_path) > /dev/null; infoResult=$?
    grep WARN $(log_path) > /dev/null; warnResult=$?
    grep ERROR $(log_path) > /dev/null; errorResult=$?
    assert "$traceResult -ne 0 \
        -a $debugResult -ne 0 \
        -a $infoResult -eq 0 \
        -a $warnResult -eq 0 \
        -a $errorResult -eq 0" \
        "Only LOG_LEVEL=$LOG_LEVEL and above are logged"
}

# Logging level filtering
test_logLevelAll() {
    LOG_LEVEL=$LOG_ALL
    log_trace "Logged"
    log_debug "Logged"
    log_info "Logged"
    log_warn "Logged"
    log_error "Logged"
    grep TRACE $(log_path) > /dev/null; traceResult=$?
    grep DEBUG $(log_path) > /dev/null; debugResult=$?
    grep INFO $(log_path) > /dev/null; infoResult=$?
    grep WARN $(log_path) > /dev/null; warnResult=$?
    grep ERROR $(log_path) > /dev/null; errorResult=$?
    assert "$traceResult -eq 0 \
        -a $debugResult -eq 0 \
        -a $infoResult -eq 0 \
        -a $warnResult -eq 0 \
        -a $errorResult -eq 0" \
        "Only LOG_LEVEL=$LOG_LEVEL and above are logged"
}

# Logging level filtering
test_logLevelOff() {
    LOG_LEVEL=$LOG_OFF
    log_trace "NOT logged"
    log_debug "NOT logged"
    log_info "NOT logged"
    log_warn "NOT logged"
    log_error "NOT logged"
    grep -s TRACE $(log_path) > /dev/null; traceResult=$?
    grep -s DEBUG $(log_path) > /dev/null; debugResult=$?
    grep -s INFO $(log_path) > /dev/null; infoResult=$?
    grep -s WARN $(log_path) > /dev/null; warnResult=$?
    grep -s ERROR $(log_path) > /dev/null; errorResult=$?
    assert "$traceResult -ne 0 \
        -a $debugResult -ne 0 \
        -a $infoResult -ne 0 \
        -a $warnResult -ne 0 \
        -a $errorResult -ne 0" \
        "Only LOG_LEVEL=$LOG_LEVEL and above are logged"
}

# Default logging level is honored
test_logLevelDefault() {
    log_debug "NOT logged"
    log_info "Logged"
    grep DEBUG $(log_path) > /dev/null; debugResult=$?
    grep INFO $(log_path) > /dev/null; infoResult=$?
    assert "$debugResult -ne 0 \
        -a $infoResult -eq 0" \
        "Only LOG_LEVEL=$LOG_LEVEL and above are logged"
}

test_clear() {
    log_info "TEST"
    log_clear
    assert "! -s $(log_path)" "Log file is empty"
}

# Archiving logged
test_archive() {
    log_info "TEST TO ARCHIVE"
    log_archive
    assert "$(ls $LOG_DIR/*.log.* | wc -l) -eq 1" "Found archive file"
}

# Archiving and zipping log
test_archiveGzip() {
    log_info "TEST TO ARCHIVE"
    log_archive gzip
    assert "$(ls $LOG_DIR/*.log.*.gz | wc -l) -eq 1" "Found zipped archive file"
}

# Custom log directory
test_logDirDefault() {
    LOG_FILE=
    LOG_DIR=
    . $LIB_DIR/logging.sh
    log_info "TEST TO ARCHIVE"
    log_archive
    sleep 1
    log_info "TEST TO ARCHIVE GZIP"
    log_archive gzip
    assert "$(ls $(dirname $0)/log | wc -l) -eq 3" ""
    log_clear
    log_deleteArchives
    assert "$(ls $(dirname $0)/log | wc -l) -eq 1" ""
}

# Custom log directory
test_logDirSetBefore() {
    TMP_DIR=/tmp/test-log
    
    LOG_DIR=$TMP_DIR
    . $LIB_DIR/logging.sh
    
    log_info "TEST TO ARCHIVE"
    log_archive
    sleep 1
    log_info "TEST TO ARCHIVE GZIP"
    log_archive gzip
    assert "$(ls $TMP_DIR | wc -l) -eq 3"
    log_clear
    log_deleteArchives
    assert "$(ls $TMP_DIR | wc -l) -eq 1"
}

# Custom log directory
test_logDirSetAfter() {
    TMP_DIR=/tmp/test-log
    
    . $LIB_DIR/logging.sh
    LOG_DIR=$TMP_DIR
    
    log_info "TEST TO ARCHIVE"
    log_archive
    sleep 1
    log_info "TEST TO ARCHIVE GZIP"
    log_archive gzip
    assert "$(ls $TMP_DIR | wc -l) -eq 3" "$TMP_DIR has 3 files" 
    log_clear
    log_deleteArchives
    assert "$(ls $TMP_DIR | wc -l) -eq 1" "$TMP_DIR has 1 file"
}

#reset
#test_logDirDefault; reset
#test_logDirSetBefore; reset
#test_logDirSetAfter; reset
#test_logLevelWarn; reset
#test_logLevelInfo; reset
#test_logLevelAll; reset
#test_logLevelOff; reset
#test_logLevelDefault; reset
#test_clear; reset
#test_archive; reset
#test_archiveGzip; reset