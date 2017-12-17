sudo apt -y install libpcre3 libpcre3-dbg libpcre3-dev \
build-essential autoconf automake libtool libpcap-dev libnet1-dev \
libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libcap-ng0 \
make libmagic-dev libjansson-dev libjansson4 pkg-config oinkmaster
tar zxpvf oisf.tar.gz

cd oisf
./configure
make -j 4
sudo make install-full
sudo ldconfig
cd ..

sudo cp suricata.yaml /usr/local/etc/suricata/suricata.yaml
sudo cp oinkmaster.conf /etc/oinkmaster.conf
sudo cp suricata.service /lib/systemd/system/suricata.service
sudo systemctl enable suricata.service
sudo systemctl start suricata.service
