#!/bin/bash
#
# v2test
# tests v2ray configuration files and links
#
# EXAMPLES:
#     to test config files (add -r to delete bad files):
#   $ v2test --config /path/to/files -r --timeout 42s
#     to change v2ray client command (v2ray instead of v2ray-ng)
#   $ v2test --v2ray v2ray
#     to create config files without testing them
#   $ cat links.txt | v2test --no-test
#
#
# this script uses your HTTP_PROXY shell variable,
# so if your v2ray configuration (in the `indoors` section)
# makes HTTP proxy on another port, either change it,
# or set the HTTP_PROXY variable before running this script,
# or use --proxy option to change it's default value.
#
# generated v2ray JSON config files by this script
# come from the vs2conf script, which has `localhost:10809`
# as the default value of the indoors HTTP proxy field.
#
# DEPENDENCIES:
#  vs2conf script (available in this repo)
#  curl command
#  v2ray-ng (default) or any other v2ray client (see -v2 option)
#
function usage(){
    cat <<EOF
v2test [OPTIONS] [/path/to/file.json] [/path/to/dir]


OPTIONS:
    -c, --config [Optional]  to specify path to config files
    -T, --timeout            to specify testing timeout
    -o, --prefix             to specify prefix to save output json files
    -V, --v2ray              to set v2ray client command
    -x, --proxy              for testing config files, should be set to
                             the same address that is used in config,
                             in the \`inbounds\` section
    -k, --keep               to keep generated config files anyway
    -r, --rm                 to delete faulty config files
    -s, --quiet              use stdout only to print working links (quiet)
    -t, --test               to only test the HTTP_PROXY itself
   -tn, --no-test            create config files and ignore testing them

EOF
}

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
        -o | --pref | --prefix)
            PREFIX="$2"
            shift 2;;
        -x | --proxy)
            HTTP_PROXY="$2"
            shift 2;;
        -V | -V2 | -v2 | --v2 | --V2 | --v2ray)
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
        -v | --ver | --verb | --verbose)
            _verbose=1
            shift;;
        -t | --test)
            test_api
            echo "Status: $_RES"
            [[ "OK." == "$_RES" ]] && echo "IP: $_ip"
            exit 0;;
        -h | --help)
            usage
            exit 0;;
        --)
            shift
            _print_path=1
            _test_path="$_test_path $@"
            break;;
        *)
            if [[ "${1:0:1}" == '-' ]]; then
                echo "invalid option ($1) -- exiting." >&2
                echo "Try '--help' for more information." >&2
                exit 1
            else
                _print_path=1
                _test_path="$_test_path $1"
                shift 1
            fi
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
TMP_FILE="/tmp/.v2test_temp_config.json"

[ -z "$TOUT" ] && TOUT="10s"
[ -z "$PREFIX" ] && PREFIX="."
[ -z "$HTTP_PROXY" ] && HTTP_PROXY="127.0.0.1:10809"
TEST_API="https://api.ipify.org"


#-----------
# functions
#-----------
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
            [[ 1 == $_print_path ]] && echo "$1"
        else
            if [[ 1 == $_verbose ]];then
                echo "$1  --  [IP: $_ip] $_RES"
            else
                [[ 1 == $_print_path ]] && echo "$1  --  $_RES"
            fi
        fi
    else
        if [[ 1 == $_test_quiet ]]; then
            echo "$1  --  $_RES" >&2
        else
            [[ 1 == $_print_path ]] && echo "$1  --  $_RES"
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
            _RES="Error."
            log_result "$1"
        else
            test_api
            log_result "$1"
            kill $V2_PID

            if [[ 1 == $_rm_config_file ]] && \
                   [[ "$_RES" != "OK." ]]; then
                rm $1
            fi
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
    for _path in $_test_path; do
        if [[ -f "$_path" ]]; then
            [[ 1 == $_verbose ]] && echo " - testing file '$_path':"
            test_config_file $_path
        elif [[ -d "$_path" ]]; then
            [[ 1 == $_verbose ]] && echo " - testing files in '$_path':"
            for _json_cfg in $(ls -1 $_path/*\.json 2>/dev/null); do
                test_config_file $_json_cfg
            done
        else
            echo "cannot use path '$_path' -- ignoring." >&2
        fi
    done
fi
