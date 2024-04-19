# aliases.sh
#
# Usage:
#   add the folloing line to your ~/.[your shell]rc
#   `source /path/to/aliases.sh`
#
# General
alias sl="ls"
alias mv="mv -i"
alias cp="cp -i"
alias ymv="yes | mv"
alias ycp="yes | cp"
alias ping="timeout 20s ping -c4"
#
# Git
alias gs="git status"
alias ga="git add"
alias gaa="git add -a"
alias gc="git commit"
alias gcm="git commit -m"
alias gcl="git clone"
alias gpush="git push"
alias gpull="git pull"
#
# FFmpeg
# to eliminate metadata, usage: ffmeta file.ogg out.ogg
alias ffmeta='function _ffmeta(){ ffmpeg -i $1 -map_metadata -1 -c:v copy -c:a copy $2 }; _ffmeta'
# to convert to voice, usage: ffogg file.webm     -> output: file.ogg
#                             ffogg file.webm mkv -> output: file.mkv
alias ffogg='function _ffogg(){ ffmpeg -i $1 -vn ${1%.*}$([ -z "$2" ] && echo ".ogg" || echo ".$2") }; _ffogg'
