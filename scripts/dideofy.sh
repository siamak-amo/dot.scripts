#!/bin/bash
#--------------------------------------------------------------------------
#    dideofy is a simple script to make dideo.ir links from youtube links
#  you can pass links like www.youtube.com/watch?v=xxxxxxxxxxx to it, Or
#  also links that you've got from google search, like:
#    www.google.com/url?...?url=https%3a%2f%2fwww.youtube.com%2fwatch...
#  
#  * trurl is a dependency *
#
#--------------------------------------------------------------------------
TRURL=$(which trurl)
CURL="$(which curl) -s"

usage(){
    cat <<EOF
usage: dideofy [URL] [OPTIONS]
dideofy makes dideo.ir links from youtube.com URL's


OPTIONS:
        -h, --help          show this page
        -d, -d{n}           to make direct download links
                              -d1 for the lowest  video quality
                              -d2 for the highest video quality
                              -d  for all qualities
        -l, --playlist      use this option if URL is a
                            youtube playlist link
EOF
}

while test $# -gt 0; do
    case "$1" in
        -h | --help)
            usage
            exit 0;;
        -d | -d1 | -d2)
            _download=1
            _dl_quality=${1:3:1}
            shift;;
        --dow | --down | --download)
            _download=1
            _dl_quality="$2"
            shift 2;;
        -l | --list | --playl | --playlist)
            _is_playlist=1
            shift;;
        -a | --aut | --auto)
            _auto_dideo=1
            shift;;
        -u | --url)
            _url="$2"
            shift 2;;
        --)
            _url="$@"
            break;;
        *)
            _url="$1"
            shift;;
    esac
done



#-----------
# functions
#-----------
function mk_dl_links(){
    _vsurl=$($CURL -L "$_dideo_url" |\
                 grep "videoSourceUrl.*" -o | cut -d\" -f3)

    if [ -z $_vsurl ]; then
        printf "Error, videoSourceUrl does not exist.\n" >&2
        exit 1
    fi

    _dl_links=$($CURL --compressed $_vsurl \
                      --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64)' |\
                    grep "url\":\"[^\"]*" -o | cut -d\" -f3 | sed -E "s/[\]\//\//g")

    if [ -z $1 ]; then
        _dl_links=$(echo $_dl_links | tr ' ' '\n')
    else
        _dl_links=$(echo $_dl_links | cut -d' ' -f$1)
    fi
}


function mk_auto_dideo(){
    _v=$($TRURL --url "$_y" --get '{query:v}')
    _l=$($TRURL --url "$_y" --get '{query:list}')

    
    [ -n $_v ] && _dideo_url="https://dideo.tv/v/yt/$_v"
    [ -n $_l ] && _dideo_url="https://dideo.tv/v/yt?list=$_l"

    
    if [ -z $_v ] & [ -z $_l ]; then
        # check for channel
        [ -n $(echo $_y | grep "/channel/" -o) ] &&\
            _c=$(echo $_y | grep "/channel/[^/]*" -o | grep "[^/]*$" -o)
        
        [ -n $(echo $_y | grep "/c/" -o) ] &&\
            _c=$(echo $_y | grep "/c/[^/]*" -o | grep "[^/]*$" -o)
        
        [ -n $(echo $_y | grep "/@.*" -o) ] &&\
            _c=$(echo $_y | grep "/@[^/]*" -o | grep "[^/]*$" -o)


        if [ -n $_c ]; then
             _dideo_url="https://dideo.tv/ch/yt/$_c"
        else
            echo "invalid link." >&2
            return 1
        fi
    fi
}


    _v=$($TRURL --url $_y --get '{query:v}')
function mk_dideo_url(){
    
    if [ -z $_v ]; then
        echo "Error, your url doesn't contain a watch ID (?v=xxx)" >&2
        return 2
    fi
}


function mk_list(){
    _l=$($TRURL --url "$_y" --get '{query:list}')

    if [ -z $_l ]; then
        echo "Error, your url doesn't contain a list parameter (?list=xxx)" >&2
        return 2
    else
        _dideo_url="https://dideo.ir/v/yt?list=$_l"
    fi
}


function parse_url(){
 case $_h in
        "youtube.com")          # usual youtube link
            _y=$_url
            ;;

        "youtu.be")             # needs normalization
            _y="youtube.com/watch?v="$(echo $_url | grep "[^\/]*$" -o)
            ;;

        "google.com")           # google search links
            _y=$($TRURL --url $_url --json | \
                     grep "value.*"  -o | \
                     grep "[^\"]*\.youtube\.com[^\"]*" -o)
            ;;

        "dideo.tv"|"dideo.ir")  # dideo
            _dideo_url=$_url

            # _y and _v might be used in the future,
            # but for now, _y only needs to be not an empty string
            #
            #_v=$(echo $1 | sed "s/.*\/\([^\/]\{11\}\)\/.*/\1/g")
            #_y="https://youtube.com/watch?v=$_v"
            _y=$_url

           ;;

        *)
            echo "Error, not supported URL." >&2
            return 1
            ;;
    esac
}


function do_dideofy__H(){
    if [[ 1 == $_is_playlist ]]; then
        # link is a playlist
        mk_list
        echo $_dideo_url
        return 0
    elif [[ 1 == $_auto_dideo ]]; then
        mk_auto_dideo
        echo $_dideo_url
    fi

    mk_dideo_url
    if [ 0 == $? ]; then
        # make download link
        if [[ 1 == $_download ]]; then
            mk_dl_links $_dl_quality
            echo $_dl_links
        else
            echo $_dideo_url
        fi
    fi
    unset _dideo_url
}


function do_dideofy(){
    _h=$($TRURL --url "$_url"  --get '{host}' | sed -e "s/^www\.//g")

    if [ -z "$_h" ]; then
        echo "invalid URL." >&2
        return 1
    else
        parse_url

        if [[ 0 == $? ]]; then
            do_dideofy__H
        fi
    fi
}


#------
# main
#------
if [ -z "$_url" ]; then
    _auto_dideofy=1
    while IFS=$'\n' read -r _url; do
        case ${_url:0:1} in
            "" | "#" | " ") # comment
                continue;;
            *)
                do_dideofy;;
        esac
    done
else
    do_dideofy
    [[ 0 != $? ]] && exit 3
fi
