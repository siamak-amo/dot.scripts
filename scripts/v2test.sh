#!/bin/sh
#
# to test v2ray configurations
# Usage:
#   v2test -c config.json
#   echo LINK | v2test [OPTIONS]
# 
# Options:
#   -co       : keep the genarated config file anyway
#

function read_links_stdin(){
    while IFS=$'\n' v2_link -r line; do
        sleep 1
        if [ -z $1 ]; then echo "keep"; done;
        echo "got $v2_link"
    done
}

if [ -z "$1" ]; then
    read_links_stdin
else
    case "$1" in
        "-c")
            test_config_file "$2"
            ;;
        "-co")
            read_links_stdin 1
            ;;
fi
