#!/bin/bash
INSTALL_USER=$USER
is_failed() {
	if [ $? -ne 0 ]; then
		echo "The command was not successful.";
		exit 1
	fi;
}
# Java install
sudo apt -y update
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt -y update
sudo apt -y install oracle-java8-installer

# upgrade
sudo apt -y upgrade

sudo git clone http://github.com/super-a1ice/rpot  /opt/rpot
sudo chown ${INSTALL_USER}:${INSTALL_USER} -R /opt/rpot
cd /opt/rpot/INSTALL
sudo mkdir -p /opt/rpot/extract_files/
sudo chmod 777 /opt/rpot/extract_files/

# install bro
tar zxpvf ./bro.tar.gz
sudo apt -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev libgeoip-dev zookeeperd autoconf
cd ./bro/
./configure
make -j 4
is_failed
sudo make install
sudo ln -s /usr/local/bro/bin/bro /usr/local/bin
cd ..

# install bro kafka plugin
tar zxpvf librdkafka.tar.gz
cd librdkafka-0.9.4
./configure --enable-sasl
make -j 4
is_failed
sudo make install
sudo ldconfig
cd ..
tar zxpvf metron-bro-plugin-kafka.tar.gz
cd metron-bro-plugin-kafka
./configure --bro-dist=../bro
make -j 4
is_failed
sudo make install
cd ..

# create malware mgmt directory
sudo mkdir -p /data/malware
sudo chmod 777 /data/malware

# update geoip database

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


# install kafka service
sudo mkdir -p /opt/kafka && sudo tar -xvf kafka_2.12-1.0.0.tgz -C /opt/kafka
sudo cp kafka.service /lib/systemd/system/kafka.service

# install suricata
cd ./suricata/
./install.sh
cd ..

# install clamav
cd ./clamav-install
./install.sh
cd ..

# install suricata
cd ./suricata
./install.sh
cd ..

# install ELK
wget https://artifacts.elastic.co/downloads/kibana/kibana-5.0.0-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0.deb
wget https://artifacts.elastic.co/downloads/logstash/logstash-5.0.0.deb
sudo dpkg -i *.deb
sudo usermod -a -G adm logstash
sudo cp logstash-kafka-bro.conf /etc/logstash/conf.d
sudo cp logstash-suricata-es.conf /etc/logstash/conf.d
sudo cp logstash-clamav-es.conf /etc/logstash/conf.d/
sudo /usr/share/logstash/bin/logstash-plugin install logstash-output-exec

# install node elasticdump
sudo apt -y install nodejs npm
sudo npm cache clean
sudo npm install n -g
sudo n stable
sudo ln -sf /usr/local/bin/node /usr/bin/node
sudo apt-get purge -y nodejs npm
sudo npm install elasticdump -g

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

# wait elasticsearch
while ! nc -z localhost 9200; do   
  sleep 0.1
done

# init database
cd /opt/rpot
./init.sh
./update.sh
