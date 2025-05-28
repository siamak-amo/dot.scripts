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
# Utils #
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

# word pronunciation
# plays files at ~/.local/share/dict/sounds/x/xXXX
function wsay(){
    local W="$(echo $1 | tr 'A-Z' 'a-z')"
    local BASE="$HOME/.local/share/dict/sounds/${W:0:1}"
    local FN="$BASE/$(ls -1 "$BASE" | grep "$1\." | head -n1)"
    if [[ "/" != "${FN: -1}" ]]; then
        mplayer -volume 100 $FN >/dev/null 2>&1
    else
        echo "'$W' not found." >&2
    fi
}

# default terminal based browser
BROWSER="w3m"

# SDcv support
function sd()
{
    sdcv -n --json "$1" |\
        jq -r '
"<html><body><ul>" +
(map(
    "<li><strong>" + .dict + "</strong>: <ol>" +
    (.definition | gsub("\n"; "<BR>") |
    gsub(">([ ]*[0-9]+)[ :]*" ; "></li></p><p><li>")) +
    "</ol></li>") | join("<BR><HR><BR>")) +
"</ul></body></html>"'
}

function sdwww()
{
    local BROWSER_OPTS=("-T" "text/html" "-dump")
    sd $1 |\
        $BROWSER "${BROWSER_OPTS[@]}"
}


#-------#
# V2ray #
#-------#

# $1 is file name of config.json in $V2_ETC/configs
function chv2()
{
    local _def="$V2_ETC/default.json"
    local _new="$V2_ETC/configs/$1"

    if [[ -z "$1" ]]; then
        echo "chv2 usage:  chv2 [file_name.json]" >&2
    elif [[ -s "$_new" && -n "$1" ]]; then
        [[ -h "$_def" ]] && unlink $_def
        ln -s $_new $_def
        echo "sudo systemctl restart v2ray.service"
    else
        echo "$_new -- file not found" >&2
    fi
}

function do_Bash_V2rayCollector()
{
    local _fn="$HOME/Stuff/vpn/v2ray/assets/links/links_$(date +%d_%b_%Y).txt"
    echo " * $_fn"
    Bash_V2rayCollector --proxy "127.0.0.1:10809" >> $_fn
}

function do_v2test()
{
    local v2ln_path="$V2_ROOT/assets/links"
    local v2json_path="$V2_ROOT/configs.working"

    local last_v2ln=$(find "$v2ln_path" -type f -name "links_*" -exec ls -t {} + | head -n1)
    echo "using $last_v2ln"

    cat "$last_v2ln" |\
        v2test --timeout 4s --quiet --prefix "$v2json_path" |\
        tee $v2json_path/links
}
