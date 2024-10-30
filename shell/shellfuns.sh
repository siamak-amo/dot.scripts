# my shell functions
# usage:
#   add the following line to your ~/.[your shell]rc file
#   `source /path/to/shellfuns.sh`

#--------#
# FFmpeg #
#--------#

# to eliminate metadata
# usage:
#         ffmeta file.ogg out.ogg
function ffmeta(){
    ffmpeg -i $1 -map_metadata -1 -c:v copy $2
}

# voice format conversion (no video)
# usage:
#         ffogg file.mp3        -> output: file.ogg
#         ffogg file.mp3 webm   -> output: file.webm
function ffogg(){
    local _formato=$([ -z "$2" ] && echo ".ogg" || echo ".$2")
    ffmpeg -i $1 -vn "${1%.*}$_formato"
}

# making input file's audio free!
# metadata elimination and converting to the ogg format (audio)
# usage:
#         fffree file.mp3       -> output: file.ogg
#         fffree file.mp3 webm  -> output: file.webm
function fffree(){
    local _formato=$([ -z "$2" ] && echo ".ogg" || echo ".$2")
    local _tmpfile="/tmp/FF_FREE_OUT.${1##*.}"
    local _tmpogg="/tmp/FF_FREE_OUT$_formato"

    ffmpeg -i "$1" -vn -map_metadata -1 -c:v copy "$_tmpfile" &&\
        ffogg "$_tmpfile"
    rm -f "$_tmpfile"

    [[ -s "$_tmpogg" ]] && mv "$_tmpogg" "${1%.*}$_formato"
}

#-------#
# utils #
#-------#

# unlink wrapper
function unlinks(){
    for ln in $@; do
        /usr/bin/unlink "$ln"
    done
}

#  word lookup regex
#  usage:
#          wregex 'si' 'i' 'lar'    ->  '^si.*i.*lar$'
#          wregex 'simil' '.*'      ->  '^simil.*'
function wregex(){
    local REG=""
    [[ ".*" != "$1" ]] && REG="^$1"
    shift
    for _p in $@; do
        [[ ".*" != "$_p" ]] && REG="$REG.*$_p"
    done

    if [[ ".*" != "$_p" ]]; then
        echo "$REG\$"
    else
        echo "$REG.*"
    fi
}

# word grep
# does grep by wregex's regex on /usr/share/dict/words
# parameters are the same as wregex
function wgrep(){
    grep "$(wregex "$@")" /usr/share/dict/words
}
