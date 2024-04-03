#!/bin/bash
#
# Vs2conf script,
#  converts vless, vmess, trojan, and ss `URLs` to
#  json configuration file for v2ray (v2ray-ng) VPN.
#
#  * trurl and jq are required *
#
#
#  Usage:    v2config [URL]  (or use stdin)
#
#
# edit the template below (in the parse_template function)
#  to make your desired configuration.
#
#  - we use the CONF_xxx pattern for substitution.
#  - if you need to define a new CONF_xxx parameter,
#    you need to modify the `normalize_kv` function.
#
TRURL=$(which trurl)
JQ=$(which jq)



#-----------
# template
#-----------
parse_template(){
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
      "protocol": "$CONF_proto",
        "settings": {
              $(case $CONF_proto in
                "vless"|"vmess")
                                                ### begining of the vless and vmes
cat <<EOF2

          "vnext": [
            {
              "address": "$CONF_add",
              "port": $CONF_port,
              "users": [
                {
                  "encryption": "$CONF_enc",
                  "flow": "$CONF_flow",
                  "id": "$CONF_id",
                  "alterId": $CONF_aid,
                  "level": 8,
                  "security": "$CONF_sec"
                }
              ]
            }
          ]
EOF2
                ;;                              ### end of the vless and vmess
                "shadowsocks"|"ss"|"trojan")
                                                ### begining of the ss and trojan
cat <<EOF2

          "servers": [
            {
                "address": "$CONF_add",
                "level": 8,
                "method": "$CONF_method",
                "ota": false,
                "password": "$CONF_password",
                "port": $CONF_port
            }
          ]
EOF2
                ;;                              ### end of the ss and trojan
              esac)
        },
      "streamSettings": {
        "network": "$CONF_net",
        "realitySettings": {
          "allowInsecure": false,
          "alpn": [
            "$CONF_alpn"
          ],
          "fingerprint": "$CONF_fp",
          "publicKey": "$CONF_pbk",
          "serverName": "$CONF_sn",
          "shortId": "$CONF_sid",
          "show": false,
          "spiderX": ""
        },
        "security": "$CONF_sec",
        "tcpSettings": {
          "header": {
            "type": "$CONF_headerType"
          }
        }
      },
        "wsSettings": {
          "connectionReuse": true,
          "path": "$CONF_path",
          "headers": {
            "Host": "$CONF_host"
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
      }
    ]
  }
}
EOF
}



#-----------
# functions
#-----------
unset_confs(){
    for v in ${!CONF_*}; do
        unset $v
    done
}
set_default_confs(){
    CONF_sec="auto"
    CONF_aid=0
    CONF_port=443
    CONF_enc="none"
    CONF_method="chacha20-poly1305"
    CONF_net="ws"
    CONF_fp="chrome"
    CONF_headerType="none"
}

# normalize _key and _value
# some of the _key names come from the trurl program
# and some others come directly from vmess URL,
# in addition, trojan and *ss URLs, have different
# naming for their parameters.
# so, we have to normalize them to ensure,
# they are substituted correctly in the template.
normalize_kv(){
    _key=${_key//amp\;/}
    
    case $_key in
        "enc"|"encryption")
            _key="enc"
            ;;
        "aid"|"alterId")
            _key="aid"
            ;;
        "id"|"user")
            [ $CONF_proto != "trojan" ] && _key="id" || _key="password"
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
        "port"|"scheme"|"fragment"|"serviceName"|"mode"|"flow"|"headerType")
            ;;
        *)
            # _key won't affect the final result
            printf "Warning -- unrecognized key '%s' was ignored.\n" $_key >&2
            ;;
    esac
}

# parse helper function
parse__H(){
    for _row in $_csv; do
        _key=${_row%%,*} && _key=${_key//\"/}
        _val=${_row#*,}  && _val=${_val//\"/}
        
        normalize_kv        
        export CONF_$_key="$_val"
        # printf "Debug -- %-13s was set to %s\n" CONF_$_key \"$_val\" >&2
    done
}

parse_vmess(){
    _csv=$(echo -n "${URL#*://}" | base64 -d |\
               $JQ -r "to_entries[] | [.key, .value] | @csv")
    
    parse__H
}

parse_vless(){
    # we need to distinguish between domain and host parameter
    # so we change `host` paramiter to `Host`
    _csv=$($TRURL --url $URL  --json | sed "s/: \"host/: \"Host/" |\
               $JQ ".[] | (.parts)+(.params|from_entries) |\
                       to_entries[] | .key+\",\"+ .value" |\
               grep -v "^\"url" | grep -v "^\"query")

   parse__H
}

parse_trojan(){
    _csv=$($TRURL --url $URL  --json | sed "s/: \"host/: \"Host/" |\
               $JQ ".[] | (.parts)+(.params|from_entries) |\
                       to_entries[] | .key+\",\"+ .value" |\
               grep -v "^\"url" | grep -v "^\"query")

    parse__H
}

parse_ss(){
    _csv=$($TRURL --url $URL  --json | sed "s/: \"host/: \"Host/" |\
               $JQ ".[]|.parts | to_entries[] |\
                           .key+\",\"+.value" |\
               grep -v "^\"url")

    parse__H
    _m_p=$(echo $CONF_id | base64 -d)  # id==user part of shadowsocks,
    CONF_method=${_m_p%:*}             # is base64 of encryption method
    CONF_password=${_m_p#*:}           # and password, separated by a comma
}

parse(){
    URL=${URL/\#*/} # remove link description at the end
    CONF_proto=${URL%%:*}
    set_default_confs
    
    case $CONF_proto in
        "vless")
            parse_vless
            parse_template
            ;;
        "vmess")
            parse_vmess
            parse_template
            ;;
        "trojan")
            parse_trojan
            parse_template
            ;;
        "ss")
            CONF_proto="shadowsocks"
            parse_ss
            parse_template
            ;;
        *)
            printf "vs2conf: invalid protocol -- '%s'\n" ${URL%%:*} >&2
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
