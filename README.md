[![endorse](https://api.coderwall.com/zeroecco/endorsecount.png)](https://coderwall.com/zeroecco)

bash-wrapper
============

a simple bash wrapper to run any command you want in cron

What it does
============

1. Adds basic logging for the cron job - default is '/var/log/shell_wrapper.log'
1. Ensures that the command is not run at the same time via lock file - '/tmp/shell_wrapper.lock'
1. Ensures that if the command exited in non-zero, it will not re-run on the next cron run.

Usage
=====

wrapper.sh -c 'COMMAND' << SINGLE QUOTES ARE NECESSARY!!!

Why
===

I have had to re-write cron wrappers so many freaking times that I am sick of it.
This tool is to be the end all to a cron wrapper.

TODO
====

TDD is not done at this time. Need to find a framework that works well with bash
