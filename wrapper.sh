#!/bin/bash
# written by zeroecco for all those times
# I needed a cron task wrapper and had to re-write one

# http://redsymbol.net/articles/unofficial-bash-strict-mode/P
set -eu
set -o pipefail
IFS=$'\n\t'

# TODO - make these configurable
local LOCK_FILE="/tmp/shell_wrapper.lock"
local LOG_DIR='/var/log/'
local LOG_FILE='/var/log/shell_wrapper.log'
local STATUS='LOCKED'

if [[ ! -d $LOG_DIR ]]; then
  mkdir $LOG_DIR
fi

# make sure we can write to the log dir
if [[ ! -w $LOG_DIR ]]; then
  echo "Cannot write to $LOG_DIR as this user: $USER, exiting"
  exit 1
fi

# A basic logging function for reviews
log() {
  # Log Date Format
  DATE=$(date +"%Y-%m-%d %H:%M:%S %z")
  echo -e "$DATE\t$1" >> "$LOG_FILE"
}

# The lock function
lock() {
  # Lock the cron job
  log "Creating lock file for: $COMMAND"
  # TODO - catch on error
  touch $LOCK_FILE
}

# The unlock function
unlock() {
  # unlock the cron job
  log "Removing lock file"
  rm $LOCK_FILE
}

status() {
  if [[ -e $LOCK_FILE ]]; then
    STATUS='LOCKED'
  fi

  if [[ ! -e $LOCK_FILE ]]; then
    STATUS='UNLOCKED'
  fi
}


while getopts ":c:" opt; do
  case "$opt" in
     c) COMMAND=$OPTARG
      ;;
  esac
done

log "$COMMAND is beginning its' run"

# Check the lock file so that a command is not
# run on top of itself
if [ -e $LOCK_FILE ]
then
  log "$COMMAND lock file exists... exiting"
  exit 1
fi

# Create the lock file for the command to be ran
lock


# Run the command
# TODO - make this more intellegent
$COMMAND >> $LOG_FILE

# If command fails, do not re-run
if [[ $? -ne 0 ]]; then
  log "$COMMAND exited with a non-zero status. exiting without removing the lock file."
  exit 1
fi

#delete lock file at end of your job
unlock

if [[ ! -f $LOCK_FILE ]]; then
  log "$COMMAND completed successfully."
  exit 0
else
  log "$LOCK_FILE is still there, removal of lock file likely did not complete. Please investigate."
  exit 1
fi
