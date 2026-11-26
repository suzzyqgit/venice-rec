#!/bin/bash
cd /work || exit 1
h="$1"
[ -f "ev/out/a_$h.log" ] || exit 2
u=$(grep "^REAL" "ev/out/a_$h.log" | awk "{print \$2}" | head -1)
grep "^UNK" "ev/out/a_$h.log" | awk "{print \$2}" > "ev/out/unk_$h.txt"
n=$(wc -l < "ev/out/unk_$h.txt"); echo "UNK=$n ID=$u"
[ "$n" -gt 0 ] || exit 0
[ -n "$u" ] || exit 3
rm -f "ev/out/unk_$h.cur"
MAXPOST=$((n+3)) ID="$u" O="ev/out/a_$h.log" S="ev/out/unk_$h.cur" L="ev/out/unk_$h.txt" bash ev/run/w6-probe.sh
echo "hit=$(grep -c "^HIT" "ev/out/a_$h.log")"
