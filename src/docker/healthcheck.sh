#/bin/bash

test -f "${HOME}/.cm_init_lock" && exit 1

if ! cmu -l | grep -q 'not running' ;
then
  exit 0
else
  exit 1
fi