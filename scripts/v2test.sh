#!/bin/bash
#
# v2test
# test v2ray configuration files and links
#
# EXAMPLES:
#     to test config files (use -rc to delete broken config files):
#   $ v2test -c [dirs or files]
#     to generate tested config file from links:
#   $ echo LINKS | v2test 2>/dev/null
#     to test a running v2ray:
#   $ v2test -t
#     to only print working links:
#   $ v2test -tl 2>/dev/null
#     to specify the timeout duration during the testing process:
#   $ TOUT=12s v2test [OPTIONS]
#     to specify a prefix to write json files
#   $ PREFIX=/tmp v2test [OPTIONS]
#     to use v2ray program instead of v2ray-ng
#   $ _V2="v2ray" v2test [OPTIONS]
#     to create config files from all links without testing them
#   $ v2test -tn
#
# OPTIONS:
#   -c, -rc                  to specify path to config files
#                            use -rc to delete if config is not working
#   -ko, --keep-config       keep generated config files anyway
#   -ro, --rm-config         delete generated config files anyway
#   -tl, --quiet             use stdout only to print working links (quiet)
#   -t,  --test              to only test the HTTP proxy itself
#   -tn, --no-test           create config files and ignore testing them
#
# this script won't modify your HTTP_PROXY shell variable
# if it was previously set, so if your v2ray configuration makes
# HTTP proxy on another port, either change it or 
# set the HTTP_PROXY variable before running this script:
#   $ HTTP_PROXY="127.0.0.1:xxxx" v2test [OPTIONS]
#
# generated v2ray JSON config files by this script
# come from the vs2conf script, which has `localhost:10809`
# as the default value of the HTTP proxy field,
# so we use this value when HTTP_PROXY is not set.
#
# DEPENDENCIES:
#  vs2conf script (available in this repo)
#  curl command
#  v2ray-ng (set _V2="v2ray" to use v2ray instead of v2ray-ng)
#
[ -z "$_V2" ] && _V2="v2ray-ng"
V2=$(which $_V2)
CURL="$(which curl) -sk"
MKCONF=$(which vs2conf)

[ -z "$TOUT" ] && TOUT="10s"
[ -z "$PREFIX" ] && PREFIX="."
[ -z "$HTTP_PROXY" ] && HTTP_PROXY="127.0.0.1:10809"
TEST_API="https://api.ipify.org"

test_api(){
    _ip=$(timeout $TOUT $CURL $TEST_API --proxy $HTTP_PROXY)
    __api_exit=$?

    if [[ $__api_exit == 124 ]]; then # timeout
        _RES="Not Responding."
    elif [[ $__api_exit == 7 ]]; then # not listening
        _RES="HTTP_PROXY is Not Listening."
    else
        if [[ -z $(echo $_ip | grep "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" -o) ]]; then
            _RES="Not Working."
        else
            _RES="OK."
        fi
    fi
}

# make configuration file path
mk_ccpath(){
    # $1 must be a v2ray configuration `URL`
    # output format: ./xxxxxxxxxxxxxxxx.json
    CCPATH="$PREFIX/$(echo $1 | sha1sum | head -c 16).json"
}

# $1 must be the link `URL` or config file path
log_result(){
    if [[ "OK." == "$_RES" ]]; then
        if [[ 1 == $_test_quiet ]]; then
            echo "$1"
        else
            echo "$1  --  [IP: $_ip] $_RES"
        fi
    else
        if [[ 1 == $_test_quiet ]]; then
            echo "$1  --  $_RES" >&2
        else
            echo "$1  --  $_RES"
        fi
    fi
}


# if $1 is set, will keep generated json config files
test_links_stdin(){
    while IFS=$'\n' read -r _ln; do
        mk_ccpath "$_ln"
        echo "$_ln" | $MKCONF > $CCPATH
        if [[ -n "$(cat $CCPATH)" ]]; then
            test_config_file "$CCPATH"
            log_result "$_ln"
            
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
    V2_PID=$(ps h -C $_V2 -o pid | grep "[0-9]*" -o)
}

# $1 is the config.json path
run_v2(){
    if [[ "$_V2" == "v2ray-ng" ]]; then
        $V2 run -c "$1" >/dev/null &
    elif [[ "$_V2" == "v2ray" ]]; then
        $V2 -c "$1" >/dev/null &
    else
        echo "Not Supported Command $_V2." >&2
        exit 2
    fi
}

# $1 is the file path
test_config_file(){
    get_v2_pid
    if [[ -n "$V2_PID" ]]; then
        echo "$_V2 is Already Running," \
        "first kill the current running $_V2 instance." >&2
        exit 1
    else
        run_v2 "$1"
        sleep 0.2s
        get_v2_pid
        if [[ -z "$V2_PID" ]]; then
            echo "$_V2 Running Failure." >&2
        else
            test_api

            if [[ 1 == $_print_path ]]; then
                log_result "$1"
            fi
            if [[ 1 == $_rm_config_file ]] &&\
                   [[ "$_RES" != "OK." ]]; then
                rm $1
            fi
            killall $_V2
        fi
    fi
}

if [[ -z "$1" ]]; then
    test_links_stdin
else
    case "$1" in
        "-c"|"-rc")
            [ $1 == "-rc" ] &&  _rm_config_file=1
            _print_path=1
            for _path in "${@:2}"; do
                if [[ -f "$_path" ]]; then
                    test_config_file $_path
                else
                    for _json_cfg in $(ls -1 $_path/*\.json); do
                        test_config_file $_json_cfg
                    done
                fi
            done
            ;;
        "-tn"|"--no-test")
            while IFS=$'\n' read -r _ln; do
                mk_ccpath "$_ln"
                echo "$_ln" | $MKCONF > $CCPATH
            done
            ;;
        "-ko"|"--keep-config")
            _keep_config_file=1
            test_links_stdin
            ;;
        "-do"|"--rm-config")
            _rm_config_file=1
            test_links_stdin
            ;;
        "-tl"|"--quiet")
            _rm_config_file=1
            _test_quiet=1
            test_links_stdin
            ;;
        "-t"|"--test")
            test_api
            echo "Status: $_RES"
            ;;
        *)
            echo "Unknown Option ($1) -- exiting." >&2
            exit 1
            ;;
    esac
fi
