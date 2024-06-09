# aliases.sh
#
# Usage:
#   add the folloing line to your ~/.[your shell]rc
#   `source /path/to/aliases.sh`
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

##### Git #####
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcm="git commit -m"
alias gcl="git clone"
alias gstash="git stash"
alias gsh="git push"
alias gll="git pull"

##### PS #####
alias psm='ps -A --format=pid,pcpu,pmem,comm --sort=-pmem,-pcpu | head'
alias pss='ps -A --format=pid,pcpu,pmem,comm --sort=-pcpu,-pmem | head'
