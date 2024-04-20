#!/bin/bash
#
#   a simple utility to make backup
#   by default will make separate backups:
#     backup of / excluding /opt /var /home
#     and then 3 backups of /opt /var /home separately.
#   
#   you can set PARTS="" to disable this feature
#   and make a single backup of the root file system.
# 
#   by default, it runs tar command with `nice -n15`
#   set `NICEN` shell variable to anything to disable that
#   $ NICEN=1 mkbackup   # to run tar commands directly
#   $ _nice_level=16 mkbackup   # to run with nice -n 16
#
# to be excluded from /
EXCLUDES="/swapf /proc /sys /dev /mnt /media /tmp /run"
# creates backup of /opt /var /home (and / excluding PARTS)
PARTS="/opt /var /home"
# to be excluded from each paths in the PARTS variable
PEXCLUDES=""
# tar command niceness
[[ -z "$_nice_level" ]] && _nice_level="15"
#
#
# add z to use gzip compressed data
[[ -z "$TFLAGS" ]] && TFLAGS=cpf
# other tar command options like --exclude-caches
TOPTS=""
#
#
# finename date format
_d=$(date +"-%d-%b-%Y")
#
#
# CD into the backup directory (will pass `-C PATH .` to the tar command)
# by CD=1, contents of your backup tar file of /var wont begin with /var
# instead will include only files and directories in /var
# set it 0 to disable this feature, so content of your backup file
# will contain the absolute paths like /opt/FILE1 /var/DIR1
CD=1
_TAR=$(which tar)


usage(){
  cat <<EOF
mkbackup [OPTIONS args] [FLAGS]

FLAGS:
    -n                  dry run
    -h, --help          prints help
    -p, --prefix        specify backup path

OPTIONS:
    --prefix: 
      use a path to store backups.

Examples:
    $ mkbackup --prefix /mnt    # to store backups in /mnt
    $ NICEN=1 mkbackup          # to run tar commands directly without nice
    $ _nice_level=16 mkbackup   # to run with nice -n 16
EOF
}


set -e

# main
while test $# -gt 0; do
    case "$1" in
        -n | --dry | --dry-run)
            TAR="echo $_TAR"
            _dry_run=1
            shift
            ;;
        -p | --pref | --prefix)
            _prefix="$(echo $2 | sed 's/\/$//g')/"
            if [[ ! -z "$_prefix" && ! -d $_prefix ]]; then
                echo "invalid prefix -- No such directory." >&2
                exit 1
            fi
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "invalid option -- \'$1\'" >&2
            echo "Try \'--help\' for more information." >&2
            exit 1
            ;;
    esac
done

# normalizing
[[ -z "$TAR" ]] && TAR="$_TAR"
# check is nice disabled
[[ -z "$NICEN" ]] && NICE="nice -n$_nice_level" || NICE=""
#
if [[ "root" == "$(whoami)" ]]; then
    _TAR="$NICE $(which tar)"
else
    _TAR="sudo $NICE $(which tar)"
fi


# to be excluded from the root filesystem
_excludes=$(echo " "$PARTS" "$EXCLUDES | sed -e 's/ \// --exclude \//g')
# to be excluded from the other parts
_pexcludes=$(echo " "$PEXCLUDES | sed -e 's/ \// --exclude \//g')

[[ -z $(echo $TFLAGS | grep "z" -o) ]] && _ext="tar" || _ext="tar.gz"

mk_names(){
  if [[ "$part" == "/" ]]; then
      _bname="ROOT"
  else
      _bname="$(echo $part|grep -E '[^\/]*$' -o|tr 'a-z' 'A-Z')"
  fi
  _fname="$_prefix$_bname$_d.$_ext"
}

do_backup(){
  if [[ "$part" == "/" ]]; then
      _EX=$_excludes
      _src_path=$part
  else
      _EX=$_pexcludes
      [[ $CD = 1 ]] && _src_path="-C $part ." || _src_path=$part
  fi

  $TAR -$TFLAGS $_fname $TOPTS $_EX $_src_path && echo -e "done.\n"
}


for part in '/' $PARTS
do
  mk_names
  echo " * Backup $_bname:"
  if [[ -s "$_fname" && -z "$_dry_run" ]]; then
    read -p "$_fname already exists, overwrite it (y/N)? " _cho
    case "$_cho" in
        y|Y ) do_backup;;
        * ) echo -e "ignored.\n";;
    esac
  else
    do_backup
  fi
done
