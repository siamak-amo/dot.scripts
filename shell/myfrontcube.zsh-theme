print -P '\nLast login: %D{%a %d %B %Y - %H:%M:%S} on %y\n'

RPROMPT='$(git_prompt_info) $(ruby_prompt_info)'
PROMPT='%n@%M  %{$fg_bold[gray]%}%~% %{$reset_color%} 
%{$fg[blue]%}/# %{$reset_color%}'
RPS1='$(_C="$?"; [[ "$_C" != "0" && "$_C" != "130" ]] && echo "[%{$fg[red]%}$_C%{$reset_color%}]")'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[green]%}[git:"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}] %{$fg[red]%}✖ %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}] %{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_RUBY_PROMPT_SUFFIX="]%{$reset_color%}"
