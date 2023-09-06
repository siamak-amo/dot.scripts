#!/bin/sh
#
#  jcal to panel
#  output:  چهارشنبه ۳۱ خرداد  [21 Jun]
#
JDATE=$(which jdate)
DATE=$(which date)

_j=$($JDATE +%G" "%d" "%V -f)
_d=$($DATE +%-1e" "%b)

printf "%s  [%s]  " "$_j" "$_d"
