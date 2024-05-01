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


if [ -z $1 ] || [ $1 = "-h" -o $1 = "--help" ]; then
    cat << EOF
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
    exit 0
fi



#----------------------
#  functions
#----------------------
mk_dl_links(){
    _vsurl=$($CURL -L $_dideo_url |\
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


mk_auto_dideo(){
    _v=$($TRURL --url $_y --get '{query:v}')
    _l=$($TRURL --url $_y --get '{query:list}')

    
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
            printf "\nError, invalid url,\n"                                  >&2
            printf "give only a youtube video or playlist or channel link.\n" >&2
            exit 2
        fi
    fi
}


mk_dideo_url(){
    _v=$($TRURL --url $_y --get '{query:v}')
    
    if [ -z $_v ]; then
        printf "\nError, your url doesn't contain a watch id,    \n" >&2
        printf "?v=xxxxxxxxxxx  pattern was not found in the url.\n" >&2
        printf "if it's a playlist link, use -l option.          \n" >&2
        exit 1
    else
        _dideo_url="https://dideo.ir/v/yt/$_v"
    fi
}


mk_list(){
    _l=$($TRURL --url $_y --get '{query:list}')

    if [ -z $_l ]; then
        printf "\nError, your url doesn't contain a list parameter,\n" >&2
        printf "?list=xxx pattern was not found in the url.        \n" >&2
        exit 1
    else
        _dideo_url="https://dideo.ir/v/yt?list=$_l"
    fi
}


invalid_option(){
    printf "\ndideofy: invalid option -- '%s'\n"     "$1" >&2
    printf "Try 'dideofy --help' for more information.\n" >&2
    exit 1
}



#----------------------
#  main
#----------------------
_h=$($TRURL --url $1  --get '{host}' | sed -e "s/^www\.//g")

if [ -z $_h ]; then
    printf "\nError, invalid url.\n" >&2
    exit 1
else
    case $_h in
        "youtube.com")          # usual youtube link
            _y=$1
            ;;

        "youtu.be")             # needs normalization
            _y="youtube.com/watch?v="$(echo $1 | grep "[^\/]*$" -o)
            ;;

        "google.com")           # google search links
            _y=$($TRURL --url $1 --json | \
                     grep "value.*"  -o | \
                     grep "[^\"]*\.youtube\.com[^\"]*" -o)
            ;;

        "dideo.tv"|"dideo.ir")  # dideo
            _dideo_url=$1

            # _y and _v might be used in the future,
            # but for now, _y only needs to be not an empty string
            #
            #_v=$(echo $1 | sed "s/.*\/\([^\/]\{11\}\)\/.*/\1/g")
            #_y="https://youtube.com/watch?v=$_v"
            _y=$1

           ;;

        *)
            printf "\nError, url is not supported.\n" >&2
            exit 1
            ;;
    esac
fi


if [ -z $_y ]; then
    printf "\nError, url is not supported.\n" >&2
    exit 1
fi


if [ -z $2 ]; then
    [ -z $_dideo_url ] && mk_dideo_url
    printf "%s\n" $_dideo_url
else
    case $2 in
        "-a")
            [ -z $_dideo_url ] &&  mk_auto_dideo
            printf "%s\n" $_dideo_url
            ;;
        
        "-d"|"-d1"|"-d2")        # make download link
            [ -z $_dideo_url ] && mk_dideo_url
            mk_dl_links $(echo $2 | cut -c3)
            printf "%s\n" $_dl_links
            ;;

        "-l"|"--playlist")       # link is a playlist
            mk_list
            printf "%s\n" $_dideo_url
            ;;

        *)
            invalid_option $2
    esac
fi
