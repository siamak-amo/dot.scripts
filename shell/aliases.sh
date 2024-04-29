# aliases.sh
#
# Usage:
#   add the folloing line to your ~/.[your shell]rc
#   `source /path/to/aliases.sh`
#
##### General #####
alias sl="ls"
alias mv="mv -i"
alias cp="cp -i"
alias ymv="yes | mv"
alias ycp="yes | cp"
alias ping="timeout 20s ping -c4"

##### Git #####
alias gs="git status"
alias ga="git add"
alias gaa="git add -a"
alias gc="git commit"
alias gcm="git commit -m"
alias gcl="git clone"
alias gsh="git push"
alias gll="git pull"

##### FFmpeg #####
# ** to call these aliases in loops, always use `do; ...; done` format **
# to eliminate metadata
#  usage: ffmeta file.ogg out.ogg
alias ffmeta='function _ffmeta(){ ffmpeg -i $1 -map_metadata -1 -c:v copy $2 }; _ffmeta'
# voice conversion (no video)
#  usage: ffogg file.mp3      -> output: file.ogg
#         ffogg file.mp3 webm -> output: file.webm
alias ffogg='function _ffogg(){ ffmpeg -i $1 -vn ${1%.*}$([ -z "$2" ] && echo ".ogg" || echo ".$2") }; _ffogg'
# make the input audio file free! (metadata elimination and converting to ogg format)
#  usage:  fffree file.mp3    -> output: file.ogg
alias fffree='function _fffree(){_p="/tmp/FF_FREE_OUT.${1##*.}" && ffmeta "$1" "$_p" && ffogg "$_p" && rm -f "$_p" && mv "/tmp/FF_FREE_OUT.ogg" "${1%.*}.ogg"}; _fffree'

##### PS #####
alias psm='ps -A --format=pid,pcpu,pmem,comm --sort=-pmem,-pcpu | head'
alias pss='ps -A --format=pid,pcpu,pmem,comm --sort=-pcpu,-pmem | head'
