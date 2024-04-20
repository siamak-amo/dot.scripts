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
            if [ -s "$2" ]; then
                _cow_file="$2"
                unset _color_mode
            fi
            shift 2
            ;;
        -g | --greedy)
            E='$$'
            shift
            ;;
        -d | --dead)
            E='xx'
            shift
            ;;
        -C | --connect | --connector)
            C="$2"
            shift 2
            ;;
        -t | --think | --think-mode)
            C='o' MD=' ' OD=' ' VR=')' VL='('
            shift
            ;;
        -T | --tired | --tired-mode)
            E='--'
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
         -vr)
            VR=$2
            shift 2
            ;;
         -al)
            HL=$2 VL=$2 VR=$2
            shift 2
            ;;
         -md | --main-diag | --main-diagonal)
             MD=$2
             shift 2
             ;;
         -od | --other-diag | --other-diagonal | --diag | --diagonal)
             OD=$2
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
[ -z "$HL" ] && HL='-' || HL="${HL:0:1}"
[ -z "$VL" ] && VL='<' || VL="${VL:0:1}"
[ -z "$VR" ] && VR='>' || VR="${VR:0:1}"
# use AL to set HL and VL at once
[ -n "$AL" ] && AL="${AL:0:1}" HL=$AL VL=$AL VR=$AL
# cow's eyes
[ -z "$E" ] && E='oo' || E="${E:0:2}"
# cow's connector
[ -z "$C" ] && C='\' || C="${C:0:1}"
# dialog box corners
[ -z "$MD" ] && MD=' ' || MD="${MD:0:1}" # main diagonal
[ -z "$OD" ] && OD=' ' || OD="${OD:0:1}" # other diagonal

cat <<EOF
$MD$(printf -- "$HL%.0s" $(seq 1 $(($DIALOG_LEN+2))))$OD \
$(IFS=$'\n'
for _ln in $(eval $_fetch |\
        sed -E -e "s/\t/  /g" \
               -e "s/^$/ \n /g" \
               -e "s/(.{$DIALOG_LEN})/\1\n/g")
do
        printf -- "\n%c %-"$DIALOG_LEN"s %c" \
                  "$VL" $_ln "$VR"
done)
$OD$(printf -- "$HL%.0s" $(seq 1 $(($DIALOG_LEN+2))))$MD
$([ -n "$_cow_file" ] && cat "$_cow_file" || echo "\
        $C
         $C   ^__^
          $C  ($E)\\_______
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
