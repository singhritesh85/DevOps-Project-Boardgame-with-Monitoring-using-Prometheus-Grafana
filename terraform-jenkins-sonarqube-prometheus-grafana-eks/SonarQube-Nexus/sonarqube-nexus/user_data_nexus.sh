#!/bin/bash
/usr/sbin/useradd -s /bin/bash -m ritesh;
mkdir /home/ritesh/.ssh;
chmod -R 700 /home/ritesh;
echo "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ritesh@DESKTOP-0XXXXXX" >> /home/ritesh/.ssh/authorized_keys;
chmod 600 /home/ritesh/.ssh/authorized_keys;
chown ritesh:ritesh /home/ritesh/.ssh -R;
echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
chmod 440 /etc/sudoers.d/ritesh;

#################################### Nexus Installation ##############################################

useradd -s /bin/bash -m nexus;
echo "Password@#795" | passwd nexus --stdin;
sed -i '0,/#run_as_user=""/s//run_as_user="nexus"/' /opt/nexus/bin/nexus.rc;
echo "nexus  ALL=(ALL)  NOPASSWD:ALL" >> /etc/sudoers
yum install java-1.8* -y
cd /opt/ && wget https://download.sonatype.com/nexus/3/nexus-3.68.1-02-java8-unix.tar.gz
tar -xvf nexus-3.68.1-02-java8-unix.tar.gz
mv /opt/nexus-3.68.1-02 /opt/nexus
chown -R nexus:nexus /opt/nexus /opt/sonatype-work

cat > /etc/systemd/system/nexus.service <<END_FOR_SCRIPT
[Unit]
Description=nexus service
After=network.target
  
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop 
User=nexus
Restart=on-abort
TimeoutSec=600
  
[Install]
WantedBy=multi-user.target
END_FOR_SCRIPT

systemctl enable nexus.service
systemctl start nexus.service

su - nexus -c "/opt/nexus/bin/nexus start"
su - nexus -c "/opt/nexus/bin/nexus status"

#################################### Installing Node Exporter #####################################

useradd --system --no-create-home --shell /bin/false node_exporter
cd /opt/ && wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter*

cat > /etc/systemd/system/node_exporter.service <<END_FOR_SCRIPT
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
END_FOR_SCRIPT

systemctl enable node_exporter
systemctl start node_exporter
