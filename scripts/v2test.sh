#!/bin/sh
#
# to test v2ray configurations
# Usage:
#   v2test -c config.json
#   echo LINK | v2test [OPTIONS]
# 
# Options:
#   -co       : keep the generated config file anyway
#

# if $1 is set, will keep generated json config files
test_links_stdin(){
    while IFS=$'\n' read -r v2_link; do
        sleep 1
        if [ -n $1 ]; then echo "keep"; fi;
        echo "got $v2_link"
    done
}

if [ -z "$1" ]; then
    test_links_stdin
else
    case "$1" in
        "-c")
            test_config_file "$2"
            ;;
        "-co")
            test_links_stdin 1
            ;;
    esac
fi
