#!/bin/bash
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH
cd /work || exit 1
P=ev/queue.pos; [ -s "$P" ] || echo 1 > "$P"
F=0
while :; do
  pos=$(cat "$P"); h=$(sed -n "${pos}p" ev/queue.txt)
  [ -n "$h" ] || { echo QUEUE_END; break; }
  [ -f ev/HIT ] && { echo HIT_STOP; break; }
  [ -f ev/STOP ] && { echo STOP; break; }
  bash ev/run/auto1.sh "$h" > /dev/null 2>&1
  rc=$?
  last=$(tail -1 "ev/out/a_$h.log" 2>/dev/null)
  echo "$(date +%H:%M:%S) $h rc=$rc $last" >> ev/out/auto_run.log
  if [ "$rc" = 0 ]; then echo "$h HIT" >> ev/chain/abandoned; break; fi
  case "$rc" in
    3|4|5)
      bash ev/run/try3.sh "$h" > /dev/null 2>&1
      if [ "$rc" != 3 ] && [ -s "ev/out/ids_$h.txt" ]; then
        FID=$(head -1 "ev/out/ids_$h.txt")
        ID_FORCE="$FID" bash ev/run/auto1.sh "$h" > /dev/null 2>&1
        rc=$?
        last="FORCED_ID $FID rc=$rc $(tail -1 "ev/out/a_$h.log" 2>/dev/null)"
        echo "$(date +%H:%M:%S) $h rc=$rc $last" >> ev/out/auto_run.log
      fi
      [ "$rc" = 3 ] && { grep -q FALLBACK_OK "ev/out/a_$h.log" || rc=7; }
      ;;
  esac
  if [ "$rc" -ge 2 ] && [ "$rc" -le 7 ]; then
    F=$((F+1))
    printf "%s\n" "$(date "+%F_%H:%M")	$h	rc=$rc $last" >> ev/chain/abandoned
    timeout 180 /root/.opencode/bin/opencode run "ev/out/a_$h.log を読み rc=$rc の原因を3行で書け。次に取るべき手を1つ書け。撃つな。" > "ev/out/oc_$h.log" 2>&1
  else F=0; fi
  echo $((pos+1)) > "$P"
  [ "$F" -ge 3 ] && { echo FAIL3_STOP; break; }
done
