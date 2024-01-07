#!/bin/bash
#
# `v2att`  V2ray all the things!
#  this script uses Bash_V2rayCollector.sh to genarate links
#  and then makes verified config files by v2test.sh script
#
V2TEST="$(which v2test)"
BCC="$(which Bash_V2rayCollector)"
TMP_LINKS_FILE="/tmp/v2att.links"
TMP_JSON_PATH="/tmp/v2att"

# remove HTTP_PROXY if telegram is not blocked in your region
HTTP_PROXY="127.0.0.1:10809" $BCC > $TMP_LINKS_FILE

if [[ ! -s $TMP_LINKS_FILE ]]; then
    echo "Error -- $BCC returned empty" >&2
    exit 1
fi


[[ ! -s $TMP_JSON_PATH ]] && mkdir $TMP_JSON_PATH
# make configs
cat $TMP_LINKS_FILE |\
    PREFIX=$TMP_JSON_PATH $V2TEST 1>/dev/null 2>/dev/null

if [[ "$(ls -1 $TMP_LINKS_PATH | wc -l)" == "0" ]]; then
    echo "Error -- $V2TEST made no json file" >&2
    exit 1
fi
