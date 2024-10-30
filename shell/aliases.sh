# aliases.sh
#
# Usage:
#   add the folloing line to your ~/.[your shell]rc
#   `source /path/to/aliases.sh`
#   *AFTER* `source /path/to/shellfuns.sh` if you have it
#
##### General #####
alias s="ls"
alias sl="ls"
alias mv="mv -i"
alias cp="cp -i"
alias ymv="yes | mv"
alias ycp="yes | cp"
alias ping="timeout 20s ping -c4"
alias cls="clear"

# unlinks alias, usage: `unlink [links]...`
if type unlinks 2>&1 1>/dev/null; then
    alias unlink="unlinks"
fi

##### Proxy #####
[[ -n "$HTTP_PROXY" ]] && __HTTP_PROXY=$HTTP_PROXY || \
           __HTTP_PROXY="http://127.0.0.1:10809"

alias curlx="curl -x $__HTTP_PROXY"
alias yt-dlpx="yt-dlp --proxy $__HTTP_PROXY"

##### Git #####
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcm="git commit -m"
alias gcl="git clone"
alias gcl1="git clone --depth 1"
alias gstash="git stash"
alias gsh="git push"
alias gll="git pull"

##### PS #####
alias psm='ps -A --format=pid,pcpu,pmem,comm --sort=-pmem,-pcpu | head'
alias pss='ps -A --format=pid,pcpu,pmem,comm --sort=-pcpu,-pmem | head'
