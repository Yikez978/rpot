#!/bin/bash

# update geoip
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
gzip -d GeoLiteCity.dat.gz
gzip -d GeoIPASNum.dat.gz
gzip -d GeoLiteCityv6.dat.gz

sudo mv GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
sudo mv GeoIPASNum.dat /usr/share/GeoIP/GeoIPASNum.dat
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

# update intel script
python bin/intel.py 'maltrail/trails/static/malware/*.txt,blocklist-ipsets/*.ipset' > config/intelligence.bro


sudo wget -qO - https://rules.emergingthreats.net/open/suricata-4.0/emerging.rules.tar.gz | sudo tar -x -z --exclude suricata.yaml -C "/usr/local/etc/suricata/" -f -
