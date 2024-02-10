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

# check is nice disabled
[[ -z "$NICEN" ]] && NICE="nice -n$_nice_level" || NICE=""
#
if [[ "root" == "$(whoami)" ]]; then
    _TAR="$NICE $(which tar)"
else
    _TAR="sudo $NICE $(which tar)"
fi
# check flags
# use -n flag to just-print (dry run)
[[ $1 = "-n" || $2 = "-n" || $3 = "-n" ]] && TAR="echo $_TAR" || TAR="$_TAR"
# use -p flag to specify backup files path
[[ $1 = "-p" || $1 = "--prefix" ]] && _prefix="$(echo $2|sed 's/\/$//g')/"
# use -h flag to print help
if [[ $1 = "-h" || $1 = "--help" ]]; then
  usage
  exit 0
fi


_excludes=$(echo " "$PARTS" "$EXCLUDES | sed -e 's/ \// --exclude \//g')
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
  [[ "$part" == "/" ]] && _EX=$_excludes || _EX=$_pexcludes

  $TAR -$TFLAGS $_fname $TOPTS $_EX $_src_path && echo -e "done.\n"
}


for part in '/' $PARTS
do
  mk_names
  echo " * Backup $_bname:"
  [[ $CD = 1 ]] && _src_path="-C $part ." || _src_path=$part
  do_backup
done
