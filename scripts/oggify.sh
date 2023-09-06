#!/bin/sh
#
#  oggify is a simple script to change file extensions
#
#  Example:   $ echo "file.name.mp3" | oggify
#                  -> file.name.ogg
#    (with -f xxx) -> file.name.xxx
#    (with -t)     -> file.name
#
case $1 in
    "-f"|"--format")
        _format="$2"
        ;;

    "-t"|"--trim")
        _format=""
        ;;

    *)
        _format="ogg"
        ;;
esac



while IFS='$\n' read -r _ln; do
    _fn=$(echo $_ln | sed "s/\.[^./]*$//")

    if [ -z "$_fn" ]; then
        echo .$_format
    else
        if [ -z $_format ]; then
            # trim file extention
            echo $_fn
        else
            # change file extention
            echo $_fn.$_format
        fi
    fi
done
