#!/bin/bash
INSTALL_USER=$USER
sudo git clone http://github.com/super-a1ice/rpot  /opt/rpot
sudo chown ${INSTALL_USER}:${INSTALL_USER} -R /opt/rpot
# install bro
tar zxpvf ./bro.tar.gz
sudo apt -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev libgeoip-dev zookeeperd autoconf
cd ./bro/
./configure
make -j 4
sudo make install
sudo ln -s /usr/local/bro/bin/bro /usr/local/bin
sudo mkdir -p /opt/bro/extract_files/

# install bro kafka plugin
tar zxpvf librdkafka.tar.gz
cd librdkafka-0.9.4
./configure --enable-sasl
make -j 4
sudo make install
sudo ldconfig
cd ..
tar zxpvf metron-bro-plugin-kafka.tar.gz
cd metron-bro-plugin-kafka
./configure --bro-dist=../bro
make -j 4
sudo make install
cd ..

# update geoip database
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
gzip -d GeoLiteCity.dat.gz
gzip -d GeoLiteCityv6.dat.gz
mv GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
mv GeoLiteCityv6.dat /usr/share/GeoIP/GeoIPCityv6.dat


# install kafka service
sudo mkdir -p /opt/kafka && sudo tar -xvf kafka_2.12-1.0.0.tgz -C /opt/kafka
sudo cp kafka.service /lib/systemd/system/kafka.service

# install ELK
wget https://artifacts.elastic.co/downloads/kibana/kibana-5.0.0-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0.deb
wget https://artifacts.elastic.co/downloads/logstash/logstash-5.0.0.deb
sudo dpkg -i *.deb
sudo cp logstash-kafka-bro.conf /etc/logstash/conf.d
sudo cp logstash-suricata-es.conf /etc/logstash/conf.d

# install suricata
cd ./suricata
./install.sh
cd ..

# register and start service
sudo systemctl enable zookeeper
sudo systemctl start zookeeper
sudo systemctl enable kafka.service
sudo systemctl start kafka.service
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
sudo systemctl enable kibana.service
sudo systemctl start kibana.service
sudo systemctl enable logstash.service
sudo systemctl start logstash.service

# init database
cd /opt/rpot
./init.sh
./update.sh
