#!/bin/sh
#
# `ln2ml` is a simple script to convert raw links file to
# proper html format
# raw link file is a text file which contains
# newline separated links like: (proto://xxx.yyy/zzz)
#
#
# Usage:   ln2ml /path/to/links.text
#
#  ** jq ** is a dependency.
#
HTML_TEMPLATE_H="<li><code onclick=\"cp(this)\">\1<\/code><\/li>"
JQ="$(which jq)"


# make html output
#
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
$(cat $1 |\
    sed "s/^\(.*\)$/$HTML_TEMPLATE_H/"
)
</ul>
</body></html>
EOF
