#!/bin/sh
#
# `vconfig` is a simple script to convert v2ray config urls
#  gathered by php ConfigCollector program, to formats
#  like text, json or html.
# 
# ConfigCollector:  https://github.com/yebekhe/ConfigCollector
#
#
# Usage:   vconfig [OPTION]
#
# OPTIONS:
#          -t, --text      output text format  (default option)
#          -j, --json      output json format
#          -h, --html      output html format
#
#
#  ** jq ** is a dependency.
#
LN="https://raw.githubusercontent.com/yebekhe/ConfigCollector/main/json/configs.json"
DL_FILE_PATH="/tmp/conf$(date +%s%m%h%d%m%Y).json"
HTML_TEMPLATE_H="<li><code onclick=\"cp(this)\">\1<\/code><\/li>"
#
DL="$(which curl) -s -o $DL_FILE_PATH"  # you might use wget
JQ="$(which jq)"
RM="rm -f"


# download raw file
#
$DL $LN


# make html output
#
mkhtml(){
cat <<EOF
<html><body>
<script>
    function cp(element) {
        const textarea = document.createElement("textarea");
        textarea.value = element.innerText;
        document.body.appendChild(textarea);
        textarea.select();
        textarea.setSelectionRange(0, 99999);
        document.execCommand("copy");
        document.body.removeChild(textarea);
        element.style.backgroundColor = "#1155bb"; 
        setTimeout(() => {
            element.style.backgroundColor = ""; 
        }, 1000);
    }
</script>
<ul>
$($JQ ".[] | .config" $DL_FILE_PATH |\
    sed "s/\"\(.*\)\".*/$HTML_TEMPLATE_H/"
)
</ul>
</body></html>
EOF
}


# make text output
#
mktext(){
    $JQ ".[] | .config" $DL_FILE_PATH |\
        sed "s/\"\(.*\)\".*/\1/"
}


case $1 in
    "-t"|"--text")
        mktext
        ;;
    "-h"|"--html")
        mkhtml
        ;;
    "-j"|"--json")
        $JQ "." $DL_FILE_PATH
        ;;
    *)
        mktext
        ;;
esac

$RM $DL_FILE_PATH
