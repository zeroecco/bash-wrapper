bash-wrapper
============

a simple bash wrapper to run any command you want in cron

What it does
============

1. Adds basic logging for the cron job
1. ensures that the command is not run at the same time
1. Ensures that if the command exited in non-zero, it will not re-run.

Usage
=====

wrapper.sh -c 'the command you wish to run and its flags'
