#!/bin/bash
#
#
HOST="8.8.8.8"
ping -W 1 -c 1 $HOST 1>/dev/null
_ret=$?

if [[ -n $1 ]]
then
  if [ $1 = "-v" ]
  then
    if [ $_ret = 0 ]
    then
      echo "Connected."
    else
      echo "* Not Connected *"
    fi
  fi
fi

exit $_ret
