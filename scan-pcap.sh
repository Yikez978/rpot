#!/bin/sh
/usr/local/bro/bin/bro -r $1 ./config/intelligence.bro
#/usr/local/bro/bin/bro -r $1 ./config/scripts/hunt.bro
sudo suricata -c /usr/local/etc/suricata/suricata.yaml -r $1
