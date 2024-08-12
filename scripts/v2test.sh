#!/bin/bash
# v2test.sh
# This file is part of my dot.scripts project <https://gitlab.com/SI.AMO/>

# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.

# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see <https://www.gnu.org/licenses/>.

# This is v2test script
# to test v2ray configuration files and URL's
# v2test is a wrapper script for the `vs2conf.sh` script
#
# EXAMPLES:
#     to test config files (add -r to delete broken ones):
#   $ v2test --config /path/to/files -r --timeout 42s
#     to change v2ray client command (v2ray instead of v2ray-ng)
#   $ v2test --v2ray v2ray
#     to create config files without testing them
#   $ cat links.txt | v2test --no-test
#     to find working URL's
#   $ cat links.txt | v2test -r --quiet >> working_links.txt
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
#  v2ray-ng (default) or any other v2ray client (see --v2ray option)
#
function cleanup {
    if [[ -n "$V2_PID" ]] && \
           [[ -n "$(ps h -p $V2_PID -o comm)" ]] && \
           [[ -z "$_running_v2_is_not_mine" ]]; then
        kill $V2_PID 2>/dev/null
        [[ 1 = $_verbose ]] && \
            echo "cleanup: $V2 child process (PID: $V2_PID) was killed."
    fi
}
trap cleanup EXIT

function usage(){
    cat <<EOF
v2test [OPTIONS] [/path/to/file.json] [/path/to/dir]


OPTIONS:
    -c, --config [Optional]  to specify path to config files
    -T, --timeout            to specify testing timeout
    -o, --prefix             to specify prefix to save output json files
    -V, --v2ray              to set v2ray client command
    -x, --proxy              for testing config files, should be set to the same
                             address that is used in the \`inbounds\` section
    -g, --rule               to add routing rules (Ex. -g geoip:ir)
                             corresponding file (geoio.dat) should be available
                             in the root of your v2ray client program
    -k, --keep               to keep generated config files anyway
    -r, --rm                 to delete faulty config files
    -R, --extra-rm           to also delete not responding config files
    -s, --quiet              use stdout only to print working links
                             and print warnings and errors on stedrr
    -t, --test               to only test the HTTP_PROXY itself
   -tn, --no-test            create config files and ignore testing them
  -sni, --servername         to manually add a sni header to the tlsSettings section
                             it may get overridden by the input

EOF
}

while test $# -gt 0; do
    case $1 in
        -c | --conf | --config)
            _print_path=1
            _test_path="$_test_path $2"
            shift 2;;
        -T | --time | --timeout)
            TOUT="0${2//[^0-9]/}s"
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
        -g | --g | --geo | --rule | --geo-rule)
            # vs2conf script uses _v2_rules_ip variable
            if [[ -z "$_v2_rules_ip" ]]; then
                export _v2_rules_ip="\"$2\""
            else
                export _v2_rules_ip="$_v2_rules_ip, \"$2\""
            fi
            shift 2;;
        -sni | --servername)
            export V2CONF_sni="$2"
            shift 2;;
        -r | --rm)
            _rm_config_file=1
            shift;;
        -R | --extra-rm)
            _ext_rm_config_file=1
            shift;;
        -k | -ko | --keep | --keep-config)
            _keep_config_file=1
            shift;;
        -s | --silent | --quiet)
            _print_path=1
            _test_quiet=1
            shift;;
        -tn | --no-test | --test-no)
            _no_test=1
            shift;;
        -v | --ver | --verb | --verbose)
            _verbose=1
            shift;;
        -t | --test)
            _only_test_api=1
            shift;;
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
# $2 is log prefix (only in verbose mode)
log_result(){
    if [[ "OK." == "$_RES" ]]; then
        if [[ 1 == $_test_quiet ]]; then
            [[ 1 == $_print_path ]] && echo "$1"
        else
            if [[ 1 == $_verbose ]];then
                echo "$2 $1  --  [IP: $_ip] $_RES"
            elif [[ 1 == $_print_path ]]; then
                echo "$1  --  $_RES"
            fi
        fi
    else
        if [[ 1 == $_verbose ]]; then
            if [[ 1 == $_test_quiet ]]; then
                echo "$2 $1  --  $_RES" >&2
            elif [[ 1 == $_print_path ]]; then
                echo "$2 $1  --  $_RES"
            fi
        else
            if [[ 1 == $_test_quiet ]]; then
                echo "$1  --  $_RES" >&2
            elif [[ 1 == $_print_path ]]; then
                echo "$1  --  $_RES"
            fi
        fi
    fi
}

test_links_stdin(){
    # check the path exists
    if [[ -n "$PREFIX" && ! -s "$PREFIX" ]]; then
        echo "'$PREFIX': No such file or directory." >&2
        exit 1
    fi
    if [[ 1 == $_verbose ]]; then
        echo " - using '$PREFIX' as the output path"
        _print_path=1
    fi

    # read from stdin
    while IFS=$'\n' read -r _ln; do
        # comments
        case "${_ln:0:1}" in
            '#'|' '|''|$'\n'|$'\t'|$'\r') continue;;
        esac

        # only create config file (without testing)
        if [[ 1 == $_no_test ]]; then
            mk_ccpath "$_ln"
            echo "$_ln" | $MKCONF > $CCPATH
            [[ 1 == $_verbose ]] && echo "$CCPATH was created."
            continue
        fi

        # create config file and test it
        echo "$_ln" | $MKCONF > $TMP_FILE
        if [[ ! -s "$TMP_FILE" ]]; then
            echo "Config File Was not Created." >&2
        else
            test_config_file__H "$TMP_FILE"
            log_result "$_ln" "  "
            
            if [[ 1 != $_rm_config_file ]] && \
                   [[ 1 == $_keep_config_file || "OK." == "$_RES" ]]
            then
                mk_ccpath "$_ln"
                cp "$TMP_FILE" "$CCPATH"
                [[ 1 == $_verbose ]] && echo "$CCPATH was created."
                unset CCPATH
            fi
        fi
    done
}

# $1: name of executable (normally $_V2)
# provides V2_PID variable, pid of $1
get_v2_pid(){
    V2_PID=$(ps h -C "$1" -o pid | grep "[0-9]*" -o)
}

# wait for v2ray's HTTP proxy's response
wait_for_v2(){
    # max retry (20*0.3 = 6s)
    local retry=$((20))
    while [[ 0 -le $retry ]]; do
        # break the loop if HTTP_PROXY is listening
        (exec 7<>/dev/tcp/${HTTP_PROXY/://}) 2>/dev/null && break
        retry=$(( $retry - 1 ))
        sleep 0.3s
    done
    # close fd 7
    exec 7>&-
    exec 7<&-
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
test_config_file__H(){
    run_v2 "$1"
    wait_for_v2
    # *Do Not* use `$!` instead of `get_v2_pid`
    # *Do Not* get the pid before the `wait_for_v2` function
    # for error-handling purposes, we need to ensure that
    # the v2 client is still running and hasn't exited
    get_v2_pid $_V2

    if [[ -z "$V2_PID" ]]; then
        _RES="Error."
    else
        test_api
        kill $V2_PID
    fi
}

test_config_file(){
    test_config_file__H "$1"

    if [[ 1 == $_rm_config_file ]]; then
        if [[ "$_RES" == "Not Working." || "$_RES" == "Error." ]]; then
            rm $1
            log_result "$1" "rm"
        else
            log_result "$1" "  "
        fi
    elif [[ 1 == $_ext_rm_config_file ]]; then
        rm $1
        log_result "$1" "rm"
    else
        log_result "$1"
    fi
}


#------
# main
#------
if [[ 1 = $_only_test_api ]]; then
    test_api
    echo "Status: $_RES"
    [[ "OK." == "$_RES" ]] && echo "IP: $_ip"
    exit 0
fi

for __v in v2ray v2ray-ng; do
    get_v2_pid $__v
    if [[ -n "$V2_PID" ]]; then
        _running_v2_is_not_mine=1
        echo "One instance of v2ray is Already Running," \
             "first kill possess $__v (PID: $V2_PID)" >&2
        exit 1
    fi
done

if [[ -z "$_test_path" ]]; then  # use stdin
    test_links_stdin
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
