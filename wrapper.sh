#!/bin/bash

# written by zeroecco for all those times
# I needed a wrapper and had to re-write one
#

LOCK_FILE="/tmp/shell_wrapper.lock"
LOG_DIR='/var/log/'
LOG_FILE='/var/log/shell_wrapper.log'

if [[ ! -d $LOG_DIR ]]; then
  mkdir $LOG_DIR
fi
# make sure we can write to the log dir
if [[ ! -w $LOG_DIR ]]; then
  echo "cannot write to $LOG_DIR, exiting"
  exit 1
fi

# A basic logging function for reviews
log() {
  # Log Date Format
  DATE=$(date +"%Y-%m-%d %H:%M:%S %z")
  echo -e "$DATE\t$1" >> "$LOG_FILE"
}

while getopts ":c:" opt; do
  case "$opt " in
     c) COMMAND=$OPTARG
      ;;
  esac
done

# Check the lock file so that a command is not
# run on top of itself
if [ -e $LOCK_FILE ]
then
  log "$COMMAND job already running...exiting"
  exit 1
fi

# Create the lock file for the command to be ran
touch $LOCK_FILE

# Run the command
# TODO - make this more intellegent
$COMMAND

# If command fails, do not re-run
if [[ $? -ne 0 ]]; then
  log "$COMMAND exited with a non-zero status. exiting without removing the lock file."
  exit 1
fi

#delete lock file at end of your job
log "removing lock file"
rm $LOCK_FILE

if [[ ! -f $LOCK_FILE ]]; then
  log "$COMMAND completed successfully."
  exit 0
fi

log "$COMMAND completed un-successfully. Please investigate"
exit 1
