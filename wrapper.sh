#!/bin/bash
# written by zeroecco for all those times
# I needed a cron task wrapper and had to re-write one

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -eu
set +e
set -o pipefail
IFS=$'\n\t'

# A basic logging function for reviews
log() {
  local MESSAGE=$1
  local DATE=$(date +"%Y-%m-%d %H:%M:%S%z")

  echo -e "$DATE\t$MESSAGE" >> "$LOG_FILE"
}

log_mkdir() {
  local LOG_DIR=$1

  if [[ ! -d $LOG_DIR ]]; then
    mkdir "$LOG_DIR"
  fi
}

log_writeable() {
  if [[ ! -w $LOG_DIR ]]; then
    echo "Cannot write to $LOG_DIR as this user: $USER, exiting"
    exit 1
  fi
}

locked() {
  if [[ -e $LOCK_FILE ]]; then
    log "Lock file exists, exiting." >> "$LOG_FILE"
    exit 1
  elif [[ ! -e $LOCK_FILE ]]; then
    log "No lock file exists, moving forward" >> "$LOG_FILE"
  fi
}

run_command() {
  local CMD=$1
  log "$CMD is beginning its' run"
  # TODO - make this more intellegent
  eval "$CMD" >> "$LOG_FILE" 2>&1
  if [[ $? -eq 1 ]]; then
    log "[FATAL] $CMD failed with exit code 1"
  fi
}


# The lock function
lock() {
  # Lock the cron job
  log "Creating lock file for: $COMMAND"
  # TODO - catch on error
  touch "$LOCK_FILE"
}

# The unlock function
unlock() {
  # unlock the cron job
  log "Removing lock file"
  rm "$LOCK_FILE"
}

while getopts ":c:" opt; do
  case "$opt" in
     c) COMMAND=$OPTARG
      ;;
  esac
done

main() {
  local LOCK_FILE="/tmp/shell_wrapper.lock"
  local LOG_DIR='/var/log/'
  local LOG_FILE='/var/log/shell_wrapper.log'

  locked
  log_writeable
  log_mkdir "$LOG_DIR"
  lock
  run_command "$1"
  unlock
  log "task completed, exiting"
  exit 0
}
main "$COMMAND"
