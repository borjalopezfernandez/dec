#!/bin/bash
set -e

[ "$DEBUG" == 'true' ] && set -x

echo "container entrypoint init DEC NAOS gsc4eo@nl2-s-aut-srv-01"

# decListener -m ECMWF_TCC -i 3600
# sleep 10
# decListener -m CELESTRAK_SFS -i 86400
# sleep 10
# decListener -m CELESTRAK_TLE -i 86400
# sleep 10
# decListener -m CELESTRAK_TCA -i 86400
# sleep 10
# decListener -m NASA_NBULA -i 86400
# sleep 10
# decListener -m NASA_NBULC -i 86400
# sleep 10
# decListener -m NASA_SFL -i 86400
# sleep 10
# decListener -m IERS_BULA -i 86400
# sleep 10
# decListener -m IERS_BULC -i 86400
echo "container entrypoint started DEC NAOS gsc4eo@LUUAPLMDS01 / gsc4eo@nl2-s-aut-srv-01"

echo "no DEC listener is started / automation is performed by Auto4EO"

touch /tmp/foo.txt
tail -f /tmp/foo.txt
