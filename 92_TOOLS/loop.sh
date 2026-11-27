#!/bin/bash
cd /work
export https_proxy=http://nwxgczwm-jp-rotate:8yma8sifzpty@p.webshare.io:80
N=${1:-3}
for n in $(seq 1 $N); do
  H=$(awk "NR>1{print \$2}" ev/led/screen.tsv | grep -v -F -f <(awk "NR>1{print \$2}" ev/led/ledger2.tsv) | head -1)
  if [ -z "$H" ]; then echo NO_CANDIDATE; break; fi
  OUT=$(bash ev/run/judge.sh "$H")
  echo "$OUT"
  V=$(echo "$OUT" | awk "{print \$2}")
  PAY=$(echo "$OUT" | sed "s/.*pay=\([a-z]*\).*/\1/")
  IDS=$(echo "$OUT" | sed "s/.*ids=//; s/,$//")
  if [ "$V" != "REAL" ]; then echo "$H SKIP $V"; continue; fi
  if [ "$PAY" = "none" ]; then echo "$H SKIP NO_PAY"; continue; fi
  E=$(awk -F"	" -v h="$H" "$1==h{print $2}" ev/led/treg_hits.tsv); if [ -n "$E" ]; then IDS="$IDS,$E"; fi
  if [ -z "$IDS" ]; then echo "$H SKIP NOID"; continue; fi
  python3 ev/run/gw_words.py "$H" | head -50 > /tmp/wl_a_$H
  head -50 /tmp/wbig.txt >> /tmp/wl_a_$H
  sort -u /tmp/wl_a_$H -o /tmp/wl_a_$H
  C=$(python3 ev/run/x3.py "$H" "$IDS" /tmp/wl_a_$H 2>&1)
  echo "$C" | tail -3
  echo "$C" | grep -q "^HIT " && echo "$H HIT"
printf "%s %s - %s %s %s HIT0 HIT0_100 %s - -
" "ID50" "$H" "$SRC" "$(echo $IDS | tr , "
" | grep -c .)" "$(wc -l < /tmp/wl_a_$H)" "$PAY" >> /work/ev/led/ledger2.tsv
done
