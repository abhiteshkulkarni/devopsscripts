#!/bin/bash

set -e

# Update packages
sudo yum update -y

# Install OpenJDK 17
sudo amazon-linux-extras enable corretto17
sudo yum install -y java-17-amazon-corretto-devel

# Create /opt directory if not exists
sudo mkdir -p /opt
cd /opt

# Download Nexus
sudo wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz

# Extract Nexus
sudo tar -zxvf nexus-unix-x86-64-3.79.0-09.tar.gz

# Rename to 'nexus'
sudo mv nexus-3.79.0-09 nexus

# Create a user named 'nexus' without password prompt
sudo useradd -r -m -d /opt/nexus nexus

# Give ownership to nexus user
sudo chown -R nexus:nexus /opt/nexus
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/sonatype-work

# Configure run_as_user
sudo bash -c 'echo "run_as_user=\"nexus\"" > /opt/nexus/bin/nexus.rc'

# Update Nexus JVM heap settings
cat <<EOF | sudo tee /opt/nexus/bin/nexus.vmoptions
-Xms1024m
-Xmx1024m
-XX:MaxDirectMemorySize=1024m
-XX:LogFile=./sonatype-work/nexus3/log/jvm.log
-XX:-OmitStackTraceInFastThrow
-Djava.net.preferIPv4Stack=true
-Dkaraf.home=.
-Dkaraf.base=.
-Dkaraf.etc=etc/karaf
-Djava.util.logging.config.file=/etc/karaf/java.util.logging.properties
-Dkaraf.data=./sonatype-work/nexus3
-Dkaraf.log=./sonatype-work/nexus3/log
-Djava.io.tmpdir=./sonatype-work/nexus3/tmp
EOF

# Create systemd service file for Nexus
cat <<EOF | sudo tee /etc/systemd/system/nexus.service
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

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable Nexus service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo "Nexus installation and service setup is complete."
echo "Check status with: sudo systemctl status nexus"
echo "Access Nexus at: http://<your-server-ip>:8081"
