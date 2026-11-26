#!/bin/bash
cd /work || exit 1
h="$1"
ev/hx GET "https://$h/" /tmp/pp.html > /dev/null
pb=$(grep -o "rel=\"pingback\" href=\"[^\"]*xmlrpc.php" /tmp/pp.html | head -1)
[ -n "$pb" ] || { echo NOPING; exit 1; }
d=$(echo "$pb" | sed "s#.*href=\"##; s#xmlrpc.php##")
echo "DIR $d"
c=$(HX_SLEEP=0.3 ev/hx GET "${d}wp-login.php" /tmp/ppl.html)
echo "LOGIN $c"
if [ "$c" = 200 ] && grep -qa "name=\"pwd\"" /tmp/ppl.html; then echo PATH_OK; fi
