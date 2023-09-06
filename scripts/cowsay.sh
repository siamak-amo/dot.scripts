#!/usr/bin/bash
#
#   a minimal cowsay program!
#
[ -z $1 ] && _fetch="cat" || _fetch="echo -e '$1'"
[ -z $DIALOG_LEN ] && DIALOG_LEN=40

# be careful using the printf special characters,
# for instance, use %% for a single % character
HL="-"
VL="|"


cat <<EOF
$(IFS=$'\n'
printf -- "$HL%.0s" $(seq 1 $(($DIALOG_LEN+4)))
for _ln in $(eval $_fetch    |\
        sed -E "s/\t/  /g"   |\
        sed -E "s/^$/ \n /g" |\
        sed -E "s/(.{$DIALOG_LEN})/\1\n/g")
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

EOF
