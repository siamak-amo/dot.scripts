#!/bin/bash
# vs2conf.sh
# This file is part of my dot.scripts project <https://gitlab.com/SI.AMO/>

# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.

# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# This is Vs2conf script
# converts vless, vmess, trojan, and ss URL's to
# json configuration file for v2ray (v2ray-ng) VPN.
#
#  * trurl and jq are required *
#
#  Usage:    v2config [URL]  (or use stdin)
#
#  - set _v2_rules_ip='A:B' to add rules to the `routing` section
#    Ex. _v2_rules_ip='"geoip:private", "..."'
#
# edit the template below (in the flush_json_config function)
#  to make your desired configuration.
#
#  - we use the V2CONF_xxx pattern for substitution.
#  - if you need to define a new V2CONF_xxx parameter,
#    you need to modify the `normalize_kv` function.
#
TRURL=$(which trurl)
JQ=$(which jq)



#-----------
# template
#-----------
flush_json_config(){
    cat <<EOF
{
  "dns": {
      "servers": [
      "1.1.1.1", "8.8.8.8"
    ]
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true,
        "userLevel": 8
      },
      "sniffing": {
        "destOverride": [
          "http",
          "tls"
        ],
        "enabled": true
      },
      "tag": "socks"
    },
    {
      "listen": "127.0.0.1",
      "port": 10809,
      "protocol": "http",
      "settings": {
        "userLevel": 8
      },
      "tag": "http"
    }
  ],
  "log": {
    "loglevel": "error"
  },
  "outbounds": [
    {
      "mux": {
        "concurrency": 8,
        "enabled": false
      },
      "protocol": "$V2CONF_proto",
        "settings": {
              $(case $V2CONF_proto in
                "vless"|"vmess")
                                                ### begining of vless and vmess
cat <<EOF2

          "vnext": [
            {
              "address": "$V2CONF_add",
              "port": $V2CONF_port,
              "users": [
                {
                  "encryption": "$V2CONF_enc",
                  "flow": "$V2CONF_flow",
                  "id": "$V2CONF_id",
                  "alterId": $V2CONF_aid,
                  "level": 8,
                  "security": "$V2CONF_sec"
                }
              ]
            }
          ]
EOF2
                ;;                              ### end of vless and vmess
                "shadowsocks"|"ss"|"trojan")
                                                ### begining of ss and trojan
cat <<EOF2

          "servers": [
            {
                "address": "$V2CONF_add",
                "level": 8,
                "method": "$V2CONF_method",
                "ota": false,
                "password": "$V2CONF_password",
                "port": $V2CONF_port
            }
          ]
EOF2
                ;;                              ### end of ss and trojan
              esac)
        },
      "streamSettings": {
        "network": "$V2CONF_net",
        "security": "$V2CONF_sec",
        "realitySettings": {
          "allowInsecure": $V2CONF_allowInsecure,
          "alpn": [
            "$V2CONF_alpn"
          ],
          "fingerprint": "$V2CONF_fp",
          "publicKey": "$V2CONF_pbk",
          "serverName": "$V2CONF_sni",
          "shortId": "$V2CONF_sid",
          "show": false,
          "spiderX": ""
        },
        "tcpSettings": {
          "header": {
            "type": "$V2CONF_headerType"
          }
        },
        "tlsSettings": {
          "allowInsecure": $V2CONF_allowInsecure
          $([[ -n "$V2CONF_sni" ]] && echo ",\"servername\": \"$V2CONF_sni\"")
        },
        "wsSettings": {
          "connectionReuse": true,
          "path": "$V2CONF_path",
          "headers": {
            "Host": "$V2CONF_host"
          }
        }
      },
      "tag": "proxy"
    },
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      },
      "tag": "block"
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "ip": [
          "1.1.1.1"
        ],
        "outboundTag": "proxy",
        "port": "53",
        "type": "field"
      }\
$(if [[ -n "$_v2_rules_ip" ]]; then
IFS=' '; for _rule in $_v2_rules_ip; do cat <<EOF2
,
      {
        "outboundTag": "direct",
        "ip": [
          $_rule
        ],
        "type": "field"
      }
EOF2
done; fi)
    ]
  }
}
EOF
}



#-----------
# functions
#-----------
unset_confs(){
    for v in ${!V2CONF_*}; do
        unset $v
    done
}

set_default_confs(){
    V2CONF_sec="auto"
    V2CONF_aid=0
    V2CONF_port=443
    V2CONF_enc="none"
    V2CONF_method="chacha20-poly1305"
    V2CONF_net="tcp"
    V2CONF_fp="chrome"
    V2CONF_headerType="none"
    V2CONF_allowInsecure="true"
}

warnln(){
    echo -e "vs2conf:" $1 >&2
}

# normalize _key and _value
# some of the _key names come from the trurl program
# and some others come directly from input vmess URL,
# in addition, trojan and *ss URLs, have different
# naming for their parameters.
# therefore keys need to be normalized to ensure,
# their values are substituted correctly in the template.
normalize_kv(){
    case $_key in
        "enc"|"encryption")
            _key="enc"
            ;;
        "aid"|"alterId")
            _key="aid"
            ;;
        "id"|"user")
            [ $V2CONF_proto != "trojan" ] && _key="id" || _key="password"
            ;;
        "sec"|"scy"|"security")
            _key="sec"
            ;;
        "net"|"network")
            _key="net"
            ;;
        "type")
            [ -n "$_val" -a "$_val" != "none" ] && _key="net"
            ;;
        "fp"|"fingerprint")
            _key="fp"
            ;;
        "pbk"|"publickey")
            _key="pbk"
            ;;
        "add"|"address"|"host")
            _key="add"
            ;;
        "Host")
            _key="host"
            ;;
        "sni"|"serverName"|"servername")
            _key="sni"
            ;;
        "sid"|"shortId"|"shortid")
            _key="sid"
            ;;
        "alpn")
            _val="${_val//,/\",\"}"
            ;;
        "path"|"spx")
            _key="path"
            ;;
        ""|"port"|"scheme"|"fragment"|"serviceName"|"mode"|"flow"|\
            "headerType"|"v"|"ps"|"tls"|"allowInsecure")
            ;;
        *)
            # _key won't affect the final result
            warnln "Warning: unrecognized key '$_key' was ignored."
            ;;
    esac
    # the pattern _val=`xxx=@comment0...` has been observed
    # in some cases, that should be eliminated
    _val=${_val%%=*}
}

# parse the URL_TSV and export V2CONF_xxx variables
parse_url_tsv(){
    IFS=$'\n'
    for _row in $URL_TSV; do
        _key=${_row%%$'\t'*}
        _val=${_row#*$'\t'}
        # normalize the _key and the _val
        normalize_kv
        if [ -z "$_key" ]; then
            warnln "Warning: got an empty key for value \`$_val\`" >&2
        else
            export V2CONF_$_key="$_val"
            [ -n "$DEBUG" ] && printf "Debug -- %-20s was set to %s\n"\
                                      \`V2CONF_$_key\` \`$_val\` >&2
        fi
    done
}

parse_vmess(){
    URL_TSV=$(echo -n "${URL#*://}" | base64 -d |\
               $JQ -r "to_entries[] | [.key, .value] | @tsv")

    parse_url_tsv
}

parse_vless(){
   # distinguish between the domain and the host parameters
   # by replacing `host` -> `Host`
   URL_TSV=$($TRURL --url $URL  --json | sed "s/: \"host/: \"Host/" |\
              $JQ -r ".[] | (.parts)+(.params|from_entries) |\
                      to_entries[] | [.key, .value] | @tsv" |\
              grep -v "^url\|^query") # ignore useless trurl outputs

   parse_url_tsv
}

parse_trojan(){
    URL_TSV=$($TRURL --url $URL  --json | sed "s/: \"host/: \"Host/" |\
              $JQ -r ".[] | (.parts)+(.params|from_entries) |\
                      to_entries[] | [.key, .value] | @tsv" |\
              grep -v "^url\|^query")

    parse_url_tsv
}

parse_ss(){
    URL_TSV=$($TRURL --url $URL  --json | sed "s/: \"host/: \"Host/" |\
               $JQ -r ".[]|.parts | to_entries[] |\
                          [.key, .value] | @tsv" |\
               grep -v "^url")

    parse_url_tsv
    _m_p=$(echo $V2CONF_id | base64 -d)  # id==user part of shadowsocks,
    V2CONF_method=${_m_p%:*}             # is base64 of encryption method
    V2CONF_password=${_m_p#*:}           # and password, separated by a comma
}

parse(){
    URL=${URL/\#*/} # remove v2 link details (url shebang)
    URL=${URL//amp\;/}
    V2CONF_proto=${URL%%:*}
    set_default_confs
    
    case $V2CONF_proto in
        "vless")
            parse_vless
            flush_json_config
            ;;
        "vmess")
            parse_vmess
            flush_json_config
            ;;
        "trojan")
            parse_trojan
            flush_json_config
            ;;
        "ss")
            V2CONF_proto="shadowsocks"
            parse_ss
            flush_json_config
            ;;
        *)
            warnln "Invalid protocol '${URL%%:*}'"
            ;;
    esac
    unset_confs
}



#-----------
# main
#-----------
if [ -z $1 ]; then
    while IFS=$'\n' read -r URL; do
        parse
    done
else
    for arg; do
        URL="$arg"
        parse
    done
fi
