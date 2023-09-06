#!/bin/sh
#
# this is a DNS changer utility

help(){
  cat <<EOF
* Shecan Dns:
     1s for 178.22.122.100  &  2s for 185.51.200.2

* DNS-over-TLS/HTTPS:
     1t for free.shecan.ir
     2t for https://free.shecan.ir/dns-query

* Google/Cloudflare Dns:
     1g for 8.8.8.8  &  2g for 4.2.2.4
     1c for 1.1.1.1

* anything else to rest the dns to the default (192.168.1.1).
EOF
}


set_dns__H(){
  echo "nameserver" $NS | sudo tee /etc/resolv.conf 1>/dev/null
}


set_dns(){
  case $OPT in
    "1s")
      NS="178.22.122.100"
      set_dns__H
      ;; 

    "2s")
      NS="185.51.200.2"
      set_dns__H
      ;; 

    "1t")
      NS="free.shecan.ir"
      echo "DNS over tls:" $NS
      echo "apply it manually"
      ;; 

    "2t")
      NS="https://free.shecan.ir/dns-query"
      echo "DNS over https:" $NS
      echo "apply it manually"
      ;; 

    "1g")
      NS="8.8.8.8"
      set_dns__H
      ;;

    "2g")
      NS="4.2.2.4"
      set_dns__H
      ;;

    "1c")
      NS="1.1.1.1"
      set_dns__H
      ;;

    "q")
      exit 0
      ;;

    *)
      NS="192.168.1.1"
      set_dns__H
      ;;
  esac

}

ask_param(){
  help
  echo -n "your choise: "
  read OPT
}


if [ -z $1 ]; then
  ask_param
  set_dns
else
  OPT=$1
  set_dns
fi
