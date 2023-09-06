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
#
# to be excluded from /
EXCLUDES="/swapf /proc /sys /dev /mnt /media /tmp /run"
# creates backup of /opt /var /home (and / excluding PARTS)
PARTS="/opt /var /home"
# to be excluded from each paths in the PARTS variable
PEXCLUDES=""
#
#
# add z to use gzip compressed data
TFLAGS=cpf
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
    -n                  just prints what going to do (dry run).
    -h, --help          prints help.
    -p, --prefix        specify backup path


OPTIONS:
    --prefix: 
      use a path to store backups.
      
      $ mkbackup --prefix /mnt -n
      will store backups in /mnt/*.tar (dry run)
EOF
}


set -e

# check flags
# use -n flag to just-print (dry run)
[[ $1 = "-n" || $2 = "-n" || $3 = "-n" ]] && _tar="echo tar" || _tar="tar"
# use -p flag to specify backup files path
[[ $1 = "-p" || $1 = "--prefix" ]] && _prefix="$(echo $2|sed 's/\/$//g')/"
# use -h flag to print help
if [[ $1 = "-h" || $1 = "--help" ]]
then
  usage
  exit 0
fi


_excludes=$(echo " "$PARTS" "$EXCLUDES | sed -e 's/ \// --exclude \//g')
_pexcludes=$(echo " "$PEXCLUDES | sed -e 's/ \// --exclude \//g')

[ -z $(echo $TFLAGS | grep "z" -o) ] && _ext="tar" || _ext="tar.gz"

mk_names(){
  _bname="$(echo $part|grep -E '[^\/]*$' -o|tr 'a-z' 'A-Z')"
  _fname="$_prefix$_bname$_d.$_ext"
}



echo " * Backup ROOT:"
$_tar -$TFLAGS $_prefix''ROOT$_d.$_ext $TOPTS $_excludes / \
  && echo -e "done.\n"


for part in $PARTS
do
  mk_names
  echo " * Backup $_bname:"
  [[ $CD = 1 ]] && part="-C $part ."
  $_tar -$TFLAGS $_fname $TOPTS $_pexcludes $part \
    && echo -e "done.\n"
done
