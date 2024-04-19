#!/usr/bin/bash
#
#   a minimal cowsay program!
#
while test $# -gt 0; do
    case "$1" in
        -c | --col | --color)
            _color_mode=1
            shift
            ;;
        -l | -dl | --len | --length | --dialog-len | --dialog-length)
            DIALOG_LEN=$2
            shift 2
            ;;
        -f)
            [ -s "$2" ] && _cow_file="$2"
            shift 2
            ;;
        -g | --greedy)
            E='$$'
            shift
            ;;
        -e | --eye | --eyes)
            E="$2"
            shift 2
            ;;
        -hl)
            HL=$2
            shift 2
            ;;
        -vl)
            VL=$2
            shift 2
            ;;
        -al)
            HL=$2
            VL=$2
            shift 2
            ;;
        --)
            shift
            _fetch="echo -e '$@'"
            break
            ;;
        *)
            _fetch="echo -e '$1'"
            shift
            ;;
    esac
done

[ -z "$_fetch" ] && _fetch="cat"
[ -z "$DIALOG_LEN" ] && DIALOG_LEN=40

# be careful using the printf special characters,
# for instance, use %% for a single % character
[ -z "$HL" ] && HL="-"
[ -z "$VL" ] && VL="|"
# use AL to set HL and VL at once
[ -n "$AL" ] && HL=$AL VL=$AL
# cow's eyes
[ -z "$E" ] && E="oo"

cat <<EOF
$(IFS=$'\n'
printf -- "$HL%.0s" $(seq 1 $(($DIALOG_LEN+4)))
for _ln in $(eval $_fetch |\
        sed -E -e "s/\t/  /g" \
               -e "s/^$/ \n /g" \
               -e "s/(.{$DIALOG_LEN})/\1\n/g")
do
        printf -- "\n%c %-"$DIALOG_LEN"s %c" \
                  "$VL" $_ln "$VL"
done
printf "\n"
printf -- "$HL%.0s" $(seq 1 $(($DIALOG_LEN+4))))
$([ -n "$_cow_file" ] && cat "$_cow_file" || echo "\
        \\
         \\   ^__^ 
          \\  ($E)\\_______
             (__)\\       )\\/\\\\
                 ||----w |
                 ||     ||")
$(if [ $_color_mode ]; then
echo -n "                          "
for i in `seq 1 $((DIALOG_LEN-22))`; do
    _R=$((RANDOM % 10))
    [ $_R -le 5 ] && echo -en "\033[$((_R+90));5m*" \
                  || echo -en " "
done
echo -e "\033[0m"
fi)
EOF
