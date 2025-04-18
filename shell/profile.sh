# This is my ~/.profile
# Usage:  in ~/.<shell>rc file source it:
#   [ -d "~/.profile" ] && source ~/.profile

function __safe_add2path()
{
    if [ -d "$1" ] ; then
        PATH="$PATH:$1"
    fi
}

# Common PATH configs
__safe_add2path "/opt/bin"
__safe_add2path "$HOME/bin"
__safe_add2path "$HOME/.local/bin"
__safe_add2path "$HOME/.local/opt/bin"

# My scripts
SCRIPTS="$HOME/Scripts"
# Go
export GOPATH="$HOME/.local/go"
# Rust
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="/opt/share/cargo"
# Pyenv
# export PYENV_ROOT="$HOME/.local/lib/pyenv"   -- depricated --
# LaTex
export TEXLIVE_ROOT="$HOME/.local/texlive/2023"
# V2ray
export V2_ROOT="$HOME/Stuff/vpn/v2ray"
export V2_ETC="$HOME/.local/etc/v2ray"

# Opt programs PATH
__safe_add2path "$HOME/Scripts/bin"
__safe_add2path "$CARGO_HOME/bin"
__safe_add2path "$GOPATH/bin"
__safe_add2path "$TEXLIVE_ROOT/bin/x86_64-linux"

# My custom shell configs
source $HOME/.aliases.sh
source $HOME/.shellfuns.sh
source $HOME/.ext_shellfuns.sh

export PATH
