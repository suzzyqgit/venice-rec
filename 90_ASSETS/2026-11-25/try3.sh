#!/bin/bash
cd /work || exit 1
h="$1"; O="ev/out/a_$h.log"; I="ev/out/ids_$h.txt"; : > "$I"
ev/hx HEAD "https://$h/wp-login.php" > /dev/null
loc=$(grep -i "^location:" /tmp/hx.h | tr -d "\r" | awk "{print \$2}")
echo "LOC $loc" >> "$O"
if echo "$loc" | grep -q cloudflareaccess; then echo "PARK_CLOUDFLARE" >> "$O"; exit 0; fi
c=$(HX_SLEEP=0.3 ev/hx GET "https://$h/wp-sitemap-users-1.xml" /tmp/t3.xml)
if [ "$c" = 200 ]; then
  echo "P3 $c" >> "$O"
  grep -o "/author/[^<\"]*" /tmp/t3.xml | sed "s#/author/##; s#/$##" | sort -u | head -3 >> "$I"
fi
ua=$(cat ev/ua.txt); eval "$(grep -m1 "^PX=" ev/tm6_wd.sh 2>/dev/null)"
for i in 1 2; do
  c2=$(curl -s -o /tmp/t3a.html -D /tmp/t3h -x "http://$PX" -A "$ua" -m 20 -w "%{http_code}" "https://$h/?author=1")
  [ "$c2" = 000 ] || break
  sleep 3
done
l2=$(grep -i "^location:" /tmp/t3h 2>/dev/null | tr -d "\r" | awk "{print \$2}")
echo "PA $c2 $l2" >> "$O"
case "$l2" in *author*) echo "$l2" | sed "s#.*/author/##; s#/.*##" | grep -E "^[a-zA-Z0-9._-]+$" >> "$I" ;; esac
sort -u "$I" -o "$I"
[ -s "$I" ] && { echo "FALLBACK_OK ids=$(tr '\n' ' ' < "$I")" >> "$O"; exit 0; }
exit 1
