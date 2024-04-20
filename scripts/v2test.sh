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
#   $ v2test -s 2>/dev/null
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
#   -s,  --quiet             use stdout only to print working links (quiet)
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
#  v2ray-ng (default) or any other v2ray client (see -v2 option)
#
while test $# -gt 0; do
    case $1 in
        -c | --conf | --config)
            _print_path=1
            _test_path="$_test_path $2"
            shift 2;;
        -T | --time | --timeout)
            TOUT="${2//[^0-9]/}s"
            if [[ "$TOUT" == 's' || "$TOUT" == '0s' ]]; then
                echo "invalid timeout ($2) -- exiting." >&2
                exit 1
            fi
            shift 2;;
        --pref | --prefix)
            PREFIX="$2"
            shift 2;;
        -x | --proxy)
            HTTP_PROXY="$2"
            shift 2;;
        -v | -v2 | --v2 | --v2ray)
            _V2=$2
            shift 2;;
        -r | --rm)
            _rm_config_file=1
            shift;;
        -k | -ko | --keep | --keep-config)
            _keep_config_file=1
            shift;;
        -s | --silent | --quiet)
            _print_path=0
            _test_quiet=1
            shift;;
        -tn | --no-test | --test-no)
            _no_test=1
            shift;;
        -t | --test)
            test_api
            echo "Status: $_RES"
            [[ "OK." == "$_RES" ]] && echo "IP: $_ip"
            exit 0;;
        *)
            echo "invalid option ($1) -- exiting." >&2
            exit 1;;
    esac
done

# defaults
[ -z "$_V2" ] && _V2="v2ray-ng"
V2=$(which $_V2)
if [[ -z "$V2" ]]; then
    echo "command not found ($_V2) -- exiting." >&2
    exit 2
fi

CURL="$(which curl) -sk"
MKCONF=$(which vs2conf)
TMP_FILE="/tmp/config.json"

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
    # output format: xxx.yyy.json
    # where: yyy is the first 16 bytes sha1 hash of $1
    #   and, xxx is either `v2` or `v2ng` (based on $_V2)
    #   or `V` for unknown v2ray client name $_V2
    _na_sha1=$(echo $1 | sha1sum)
    case $_V2 in
        "v2ray")
            _pref_na="v2";;
        "v2ray-ng")
            _pref_na="v2ng";;
        *)
            _pref_na="V";;
    esac

    CCPATH="$PREFIX/$_pref_na-${_na_sha1:0:16}.json"
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
        echo "$_ln" | $MKCONF > $TMP_FILE
        
        if [[ ! -s "$TMP_FILE" ]]; then
            echo "Config File Was not Created." >&2
        else
            test_config_file "$TMP_FILE"
            log_result "$_ln"
            
            if [[ 1 != $_rm_config_file ]] && \
                   [[ 1 == $_keep_config_file || "OK." == "$_RES" ]]
            then
                cp "$TMP_FILE" "$CCPATH"
                unset CCPATH
            fi
        fi
    done
}

get_v2_pid(){
    V2_PID=$(ps h -C $_V2 -o pid | grep "[0-9]*" -o)
}

# $1 is the config.json path
run_v2(){
    case "$_V2" in
        v2ray)
            $V2 -c "$1" >/dev/null & ;;
        v2ray-ng)
            $V2 run -c "$1" >/dev/null & ;;
    esac
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


#------
# main
#------
if [[ -z "$_test_path" ]]; then  # use stdin
    if [[ 1 == $_no_test ]]; then
        while IFS=$'\n' read -r _ln; do
            mk_ccpath "$_ln"
            echo "$_ln" | $MKCONF > $CCPATH
        done
    else
        test_links_stdin
    fi
else
    if [[ 1 == $_no_test ]]; then
        echo "nothing to do -- exiting."
        exit 0
    fi
    for _path in "$_test_path"; do
        if [[ -f "$_path" ]]; then
            test_config_file $_path
        else
            for _json_cfg in $(ls -1 $_path/*\.json); do
                test_config_file $_json_cfg
            done
        fi
    done
fi
