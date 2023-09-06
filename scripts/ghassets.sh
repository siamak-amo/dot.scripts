#!/bin/sh
#
# a simple script to fetch assets section links in github release pages
#
#  Usage:
#        fetch the latest release link:
#           $ ghassets https://github.com/[USER]/[REPO].git
#
#        specify release tag (version):
#           $ ghassets -l https://github.com/[USER]/[REPO]/releases/tag/[BUILD TAG]
#
#
if ! [ $1 = "-l" ]; then
    _repo_ln="$(echo $1 | sed -E "s/\.git$//g")/releases"
    _tmp_file="/tmp/gh_$(date +"%H%M%s_%d%m%y").html"
    
    curl -s $_repo_ln > $_tmp_file
    _release_line_number=$(grep -Eno "Latest" $_tmp_file |\
                           head -1 | grep -Eo "^[0-9]*")


    _release_span=$(tail -n +$(($_release_line_number-1)) $_tmp_file |\
                        head -1 | grep -Eo "<span.*span>")
    _release_span_ln=$(echo $_release_span |\
                       sed "s/.*href=\"\([^\"]*\)\".*/\1/g")

    _req_build=$(echo $_release_span_ln | grep -Eo "[^/]*$")
    _req_build_ln="$_repo_ln/expanded_assets/$_req_build"
else
    if [ -z $(echo $2 | grep -o "/releases/tag/") ]; then
        echo "invalid URL\nvalid url: github.com/.../releases/tag/[build tag]" >&2
        exit 1
    fi
    
    _req_build_ln=$(echo $2 | sed -E "s/tag/expanded_assets/g")
fi

if [ -z $_req_build_ln ];then
   echo "Error" >&2
   exit 1
fi
   

# fetch the build assets
_dl_ln="https://github.com"$(curl -s $_req_build_ln |\
         grep -Eo "<a.*>" |head -1 |\
         sed "s/.*href=\"\([^\"]*\)\".*/\1/g")

echo $_dl_ln
