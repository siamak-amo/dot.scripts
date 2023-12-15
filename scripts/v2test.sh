#!/bin/bash
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
        if [[ 1 == $_keep_config_file ]]; then
            echo "keep";
        fi;
        echo "got $v2_link"
    done
}

# $1 is the file path
test_config_file(){
    if [[ 1 == $_print_path ]]; then
        echo $1
    fi
}

if [[ -z "$1" ]]; then
    test_links_stdin
else
    case "$1" in
        "-c")
            _print_path=1
            for _path in "${@:2}"; do
                test_config_file $_path
            done
            ;;
        "-co")
            _keep_config_file=1
            test_links_stdin
            ;;
    esac
fi
