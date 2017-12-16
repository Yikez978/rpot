sudo service suricata stop
sudo service logstash stop

rm -rf extract_files/*
touch ./extract_files/empty
cd dashboards
curl -XDELETE "localhost:9200/*"
curl -XPUT 'http://localhost:9200/_template/bro_index' -d @mapping.json
./load.sh
sudo rm /usr/local/var/log/suricata/eve.json
sudo service suricata start
sudo service logstash start
