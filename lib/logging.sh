#########################################################
# Logging functionality that can be imported
# into runnable scripts
#
# Prerequisites: NONE
#
# Optional configuration:
#   Define LOG_LEVEL=[0-6] (Use defined LOG_* variables below)
#   Define LOG_DIR=<directory path to put logs>
#   Define LOG_FILE=<file name>
#   Define LOG_DATE_FMT=<format string for datetime>
#   
#########################################################

# Log levels adapted from Log4j
            # Exmaple of log type
LOG_ALL=0
LOG_TRACE=1 # Variable state
LOG_DEBUG=2 # Processing state
LOG_INFO=3  # Major function complete
LOG_WARN=4  # Recoverable issue
LOG_ERROR=5 # Non-recoverable issue
LOG_OFF=6

# Configurable variable defaults
if [ -z "$LOG_LEVEL" ]; then LOG_LEVEL=$LOG_INFO; fi
if [ -z "$LOG_DIR" ]; then LOG_DIR=`dirname $0`/log; fi
if [ -z "$LOG_FILE" ]; then LOG_FILE=$(basename "${0%.*}").log; fi
if [ -z "$LOG_DATE_FMT" ]; then LOG_DATE_FMT=""; fi

# Currently configured log file path
log_path() {
    echo "$LOG_DIR/$LOG_FILE"
}

# Clear the old log
log_clear() {
    if [ -f "`log_path`" ]; then
        cat /dev/null > $(log_path)
    fi
}

# Remove log archive files
log_deleteArchives() {
    rm `log_path`.*   
}

# Date stamp the current log file and start a new one
# Optionally pass command to run on old log
# log_archive [<gzip or other command>]
log_archive(){
    if [ -f "`log_path`" ]; then
        ARCHIVE=`log_path`.`date +%Y%m%d%H%M%S`
        mv `log_path` $ARCHIVE
        touch `log_path`
        if [ ! -z $1 ]; then $@ $ARCHIVE; fi
    fi
}

# Logging should be done through helper methods to log appropriate FUNCNAME value
# log <level-int> <level-name> <message>
log() {
    mkdir -p $LOG_DIR
    touch $(log_path)
    if [ "$1" -ge "$LOG_LEVEL" ]
    then
        level=$2
        shift; shift
        echo "`date $LOG_DATE_FMT` $level (${FUNCNAME[2]}):  $@" >> $(log_path)
    fi
}

# Primary functions to call in main script
# log_<level> <message>

log_trace() {
    log $LOG_TRACE "TRACE" "$@"
}
log_debug() {
    log $LOG_DEBUG "DEBUG" "$@"
}
log_info() {
    log $LOG_INFO "INFO" "$@"
}
log_warn() {
    log $LOG_WARN "WARN" "$@"
}
log_error() {
    log $LOG_ERROR "ERROR" "$@"
}