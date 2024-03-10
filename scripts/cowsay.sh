#!/usr/bin/bash
#
#   a minimal cowsay program!
#
[ -z "$1" ] && _fetch="cat" || _fetch="echo -e '$1'"
[ -z "$DIALOG_LEN" ] && DIALOG_LEN=40

# be careful using the printf special characters,
# for instance, use %% for a single % character
[ -z "$HL" ] && HL="-"
[ -z "$VL" ] && VL="|"
# use AL to set HL and VL at once
[ -n "$AL" ] && HL=$AL VL=$AL

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
        \\
         \\   ^__^ 
          \\  (oo)\\_______
             (__)\\       )\\/\\\\
                 ||----w |
                 ||     ||
$(if [ "$1" == "-c" -o "$2" == "-c" ]; then
echo -n "                        "
for i in `seq 1 $((DIALOG_LEN-20))`; do
    _R=$((RANDOM % 10))
    case $_R in
        0|1|2|3|4|5) echo -en "\033[$((_R+90));5m*";;
        *) echo -n ' ';;
    esac
done
echo -en "\033[0m"
fi)

EOF
