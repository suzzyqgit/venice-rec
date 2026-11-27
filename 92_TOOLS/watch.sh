#!/bin/bash
cd /work
while true; do
  for f in ev/out/*.log; do
    h=$(grep -H "^HIT " "$f" 2>/dev/null)
    if [ -n "$h" ]; then echo "$h" >> ev/led/HIT.txt; fi
  done
  if [ -s ev/led/HIT.txt ]; then sort -u ev/led/HIT.txt -o ev/led/HIT.txt; fi
  sleep 20
done
