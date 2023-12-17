#!/bin/bash
#
# v2test
# test v2ray configuration files and links
#
# USAGE:
#   - to test a json config file:
#     v2test -c *.json
#   - to generate tested config file from links
#     echo LINK | v2test [OPTIONS]
#   - to test a running v2ray
#     v2test -t
#
# OPTIONS:
#   -co        keep generated config files anyway
#   -rc        delete generated config files anyway
#   -t         to only test the API
#
# we assumed that your configuration files 
# will set an HTTP proxy on localhost:10809,
# so either use vs2conf script or edit your
# files or edit HT_PROXY variable below.
#
# DEPENDENCIES:
#  vs2conf script (in this repo)
#  curl
#  v2ray-ng (alternatively you can use v2ray by editing _V2 variable)
#
_V2="v2ray-ng"
V2=$(which $_V2)
CURL="$(which curl) -s"
MKCONF=$(which vs2conf)

TOUT="5s"
TEST_API="https://api.ipify.org"
HT_PROXY="127.0.0.1:10809"

test_api(){
    _ip=$(timeout $TOUT $CURL $TEST_API --proxy $HT_PROXY)

    [[ -z $(echo $_ip | grep "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" -o) ]] \
        && _RES="Not Working." || _RES="OK."
}

# $1 is v2ray config link
mk_ccpath(){
    CCPATH=$(echo $1 | sha1sum)
    CCPATH="${CCPATH:0:16}.json"
}

# if $1 is set, will keep generated json config files
test_links_stdin(){
    while IFS=$'\n' read -r _ln; do
        mk_ccpath "$_ln"
        echo "$_ln" | $MKCONF > $CCPATH
        if [[ -n "$(cat $CCPATH)" ]]; then
            test_config_file "$CCPATH"

            if [[ "OK." == "$_RES" ]]; then
                echo "$_ln  --  $_RES"
            else
                echo "$_RES" >&2
            fi
            
            if [[ 1 != $_rm_config_file ]] && \
                   [[ 1 == $_keep_config_file || "OK." == "$_RES" ]]
            then
                unset CCPATH
            else
                rm -f $CCPATH
            fi
        else
            echo "creating config file failed" >&2
        fi
    done
}

get_v2_pid(){
    V2_PID=$(ps -C $_V2 -o pid | tail -1 | grep "[0-9]*" -o)
}

# $1 is the file path
test_config_file(){
    get_v2_pid
    if [[ -n "$V2_PID" ]]; then
        echo "first kill the current running $_V2 instance." >&2
    else
        $V2 run -c $1 >/dev/null & 
        sleep 0.2s
        get_v2_pid
        if [[ -z "$V2_PID" ]]; then
            echo "running $_V2 failed." >&2
        else
            test_api
            if [[ 1 == $_print_path ]]; then
                printf "%s\t -- %s\n" "$1" "$_RES"
            fi
            killall $_V2
        fi
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
        "-rc")
            _rm_config_file=1
            test_links_stdin
            ;;
        "-t")
            test_api
            echo "Status: $_RES"
            ;;
    esac
fi
