## Real-time Packet Observation Tool (RPOT)


This build was created and tested using Ubuntu 16.04.


### architecture
![architecture](https://github.com/super-a1ice/rpot/raw/master/screenshot/architecture.png "architecture")


## Startup
```
$ curl -sL https://raw.githubusercontent.com/super-a1ice/rpot/master/INSTALL/install-ubuntu1604.sh | bash
```

## Usage

Quick scan
```
$ cd /opt/rpot
$ bro -r sample-pcap/2017-10-19-Necurs-Botnet-malspam-pushing-Locky.pcap ./config/scripts/hunt.bro
```

Intelligence scan
```
$ cd /opt/rpot
$ bro -r sample-pcap/2017-10-19-Necurs-Botnet-malspam-pushing-Locky.pcap ./config/scripts/intelligence.bro
```

### Update Geoip and Intelligence
```
$ cd /opt/rpot
$ ./update.sh
```

### Update hunting rule
```
$ cd /usr/local/share/clamav/
$ sudo vim sample.yar
rule Sample_Rule {
        strings:
            $string1 = "Test"

        condition:
            $string1
}
```

### FAME integration

See how to build FAME [FAME’s Documentation](https://fame.readthedocs.io/en/latest/).
and change logstash config
```
$ cd /opt/rpot/INSTALL
$ vim logstash-clamav-es.conf # modify API_KEY and Hostname
$ sudo cp logstash-clamav-es.conf /etc/logstash/conf.d/
$ sudo service logstash restart
```

### Visualization

Access Kibana url (``http://localhost:5601``)
Click [Dashboard] -> [Open] -> [MAIN]

![screenshot0](https://github.com/super-a1ice/rpot/raw/master/screenshot/screenshot0.png "Hunt Dashboards")
![screenshot1](https://github.com/super-a1ice/rpot/raw/master/screenshot/screenshot1.png "Intel")
![screenshot2](https://github.com/super-a1ice/rpot/raw/master/screenshot/screenshot2.png "DNS")
![screenshot3](https://github.com/super-a1ice/rpot/raw/master/screenshot/screenshot3.png "Connection")
![screenshot5](https://github.com/super-a1ice/rpot/raw/master/screenshot/screenshot5.png "Files")
![screenshot6](https://github.com/super-a1ice/rpot/raw/master/screenshot/screenshot6.png "Search Files")
![screenshot7](https://github.com/super-a1ice/rpot/raw/master/screenshot/screenshot7.png "Suricata")
