#!/usr/bin/env sh
#
#   ** This script must be run with "source chpy" **
#   **         you cannot run it directly         **
#
#   `source chpy` without option or with -a, --activate
#       will activate the pyenv
#    and with -d, --deactivate
#       will deactivate the pyenv
#    -s, --status will show pyenv is active or not
#
PS1_PYENV="(pyenv)"
PYENV_BIN="$PYENV_ROOT/shims"


ps1set(){
    if [ -z $(echo $PS1 | grep "^$PS1_PYENV" -o) ]; then
        PS1="$PS1_PYENV $PS1"
        export PS1
    fi
}

ps1unset(){
    PS1=$(echo $PS1 | sed -e "s/^$PS1_PYENV //g")
    export PS1
}

activate(){
    if [ -z $(echo $PATH | grep $PYENV_BIN -o) ]
    then
        PATH="$PYENV_BIN:"$PATH
        export PATH
        echo "pyenv activated."
        
    else
        echo "pyenv is active already."
    fi    
    ps1set
}

deactivate(){
    if [ -z $(echo $PATH | grep $PYENV_BIN -o) ]
    then
        echo "pyenv is not active."
    else
        PATH=$(echo $PATH | tr ':' '\n'  |\
                   grep -v $PYENV_BIN |\
                   tr '\n' ':')
        
        PATH=${PATH:0:-1}
        export PATH
        echo "pyenv deactivated."
    fi
    ps1unset
}


if [ -z $PYENV_ROOT ]; then
    echo "Error, PYENV_ROOT was not set." >&2
else
    if [ -z $1 ]; then
        activate
    else
        case $1 in
            "-d"|"--deactivate")
                deactivate
                ;;

            "-a"|"--activate")
                activate
                ;;

            "-s"|"--status")
                [ -z $(echo $PATH | grep $PYENV_BIN -o) ] &&
                    echo "pyenv is not active."              ||
                    echo "pyenv is active."
                ;;
            *)
                echo "option not found" >&2
                exit 1
                ;;
        esac
    fi
fi
