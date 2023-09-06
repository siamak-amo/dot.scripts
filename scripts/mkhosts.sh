#!/usr/bin/sh
#
#  Usage:        mkhosts [DOMAIN] [OPTIONS]
#  OPTIONS:
#       -wn, --no-www       dont print www.domain
#
#  Example:    $ mkhosts gnu.org
#              209.51.188.116 gnu.org www.gnu.org
#
#  (no www)    $ mkhosts www.gnu.org -wn
#              209.51.188.116 gnu.org
#
#  (set NS)    $ NS=1.1.1.1 mkhosts gnu.org
#
# set the default dns server
[ -z $NS ] && NS="185.51.200.2"


DIG=$(which dig)
if [ -z $DIG ]; then
    printf "dig is not installed.\n" >&2
    exit 1
fi


_ho=$(echo $1 | sed -E "s/^www\.//g")
_ip=$($DIG +short @$NS $_ho |\
          grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')


if [ -z "$_ip" ]; then
    printf "no result.\n" >&2
    exit 1
else
    if [ -z $2 ] ||\
           [ $2 != "-wn" -a $2 != "--no-www" ]
    then
        for __ip in $_ip; do
            printf "%s %s www.%s\n" $__ip $_ho $_ho
        done
    else
         for __ip in $_ip; do
            printf "%s %s\n" $__ip $_ho
        done
    fi
fi
