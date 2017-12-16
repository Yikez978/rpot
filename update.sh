#!/bin/bash

# update geoip
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
gzip -d GeoLiteCity.dat.gz
gzip -d GeoLiteCityv6.dat.gz

sudo mv GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
sudo mv GeoLiteCityv6.dat /usr/share/GeoIP/GeoIPCityv6.dat

# update feed
rm -rf ./maltrail
git clone https://github.com/stamparm/maltrail
for i in $(ls ./maltrail/trails/static/malware/*.txt)
do
	python ./bin/parse.py $i
done

rm -rf ./blocklist-ipsets
git clone https://github.com/firehol/blocklist-ipsets
cd ./blocklist-ipsets
git checkout master
cd ..
for i in $(ls ./blocklist-ipsets/*.ipset)
do
	python ./bin/parse.py $i
done

sudo oinkmaster -C /etc/oinkmaster.conf -o /usr/local/etc/suricata/rules
