#!/bin/bash
# mkbackup.sh
# This file is part of my dot.scripts project <https://gitlab.com/SI.AMO/>

# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.

# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see <https://www.gnu.org/licenses/>.

#   This is mkbackup script
#   a simple utility to make backup
#   by default will make separate backups:
#     backup of / excluding /opt /var /home
#     and then 3 backups of /opt /var /home separately.
#   you can set PARTS="" to disable this feature
#   and make a single backup of the root file system.
# 
#   Examples:
#     - to store backups in /mnt
#     $ mkbackup -o /mnt
#     - to run tar commands directly without nice
#     $ mkbackup --no-nice   OR   $ NICEN=1 mkbackup
#     - to run with nice -n 16
#     $ mkbackup --level 16  OR   $ _nice_level=16 mkbackup
#

usage(){
  cat <<EOF
mkbackup [OPTIONS]

OPTIONS:
    -n                        dry run
    -h, --help                prints help
    -o, --prefix              to specify backup path
    -N, --no-nice             to disable nice
    -l, --nice-level          to specify nice -n level
    --parts                   to specify separated backup parts
    -s, --solid               to backup in a single file
    -e, --exclude             to exclude (file/dir) from backup
    -z, --gzip                to make compressed tar files (tar.gz)

EOF
}

set -e
while test $# -gt 0; do
    case "$1" in
        -n | --dry | --dry-run)
            _dry_run=1
            shift
            ;;
        -o | --pref | --prefix)
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
        -N | -nn | --no_nice)
            NICEN=1
            shift
            ;;
        -l | -nl | --nice | --nice-level)
            _nice_level=$2
            shift 2
            ;;
        -z | --gzip | --zip | --gnuzip)
            _gzip=1
            shift
            ;;
        -e | --exc | --exclude | --extra_exclude)
            [[ -s "$2" ]] && PEXCLUDES="$PEXCLUDES $(realpath $2)" ||\
                    echo "Warning, '$2' No such file or directory." >&2
            shift 2
            ;;
        --part | --parts)
            for _p in $2; do
                if [[ ! -s $_p ]]; then
                    echo "Error, $_p  No such file or directory." >&2
                    exit 1
                fi
            done
            PARTS="$2"
            shift 2
            ;;
        -s | --solid)
            PARTS=" "
            shift 1
            ;;
        *)
            echo "invalid option -- '$1'," >&2
            echo "Try '--help' for more information." >&2
            exit 1
            ;;
    esac
done

# defaults
# to be excluded from /
EXCLUDES="/swapf /proc /sys /dev /mnt /media /tmp /run"
# creates backup of /opt /var /home (and / excluding PARTS)
[[ -z "$PARTS" ]] && PARTS="/opt /var /home"
# to be excluded from each paths in the PARTS variable
[ -z "$PEXCLUDES" ] && PEXCLUDES=""
# tar command niceness
[[ -z "$_nice_level" ]] && _nice_level="15"
#
# add z to use gzip compressed data
if [[ -z "$TFLAGS" ]]; then
    [[ -z "$_gzip" ]] && TFLAGS=cpf || TFLAGS=zcpf
fi
# other tar command options like --exclude-caches
TOPTS=""
#
# finename date format
_d=$(date +"-%d-%b-%Y")
#
# CD into the backup directory (will pass `-C PATH .` to the tar command)
# by CD=1, contents of your backup tar file of /var wont begin with /var
# instead will include only files and directories in /var
# set it 0 to disable this feature, so content of your backup file
# will contain the absolute paths like /opt/FILE1 /var/DIR1
CD=1
_TAR=$(which tar)

# normalizing
if [[ -z "$NICEN" ]]; then
    NICE="nice -n$_nice_level"
else
    NICE=""
fi
if [[ "root" == "$(whoami)" ]]; then
    TAR="$NICE $_TAR"
else
    TAR="sudo $NICE $_TAR"
fi
[[ -n "$_dry_run" ]] && TAR="echo $TAR"

# prepare excludes
# to be excluded from the root filesystem
_excludes=$(echo " "$PARTS" "$EXCLUDES | sed -e 's/ \// --exclude \//g')
# to be excluded from the other parts
_pexcludes=$(echo " "$PEXCLUDES | sed -e 's/ \// --exclude \//g')

[[ -z "$_gzip" ]] && _ext="tar" || _ext="tar.gz"

#-----------
# functions
#-----------
mk_names(){
  if [[ "$part" == "/" ]]; then
      _bname="ROOT"
  else
      _bname="$(echo $part | grep -E '[^\/]*$' -o | tr 'a-z' 'A-Z')"
  fi
  _fname="$_prefix$_bname$_d.$_ext"
}

do_backup(){
  if [[ "$part" == "/" ]]; then
      _EX="$_excludes $_pexcludes"
      _src_path=$part
  else
      _EX=$_pexcludes
      [[ $CD = 1 ]] && _src_path="-C $part ." || _src_path=$part
  fi

  $TAR -$TFLAGS $_fname $TOPTS $_EX $_src_path && echo -e "done.\n"
}

#------
# main
#------
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
