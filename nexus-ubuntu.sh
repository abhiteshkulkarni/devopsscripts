#!/bin/bash

set -e

# Update system
echo "Updating system packages..."
sudo apt-get update

# Install Java 17
echo "Installing OpenJDK 17..."
sudo apt-get install openjdk-17-jdk openjdk-17-jre -y

# Download and extract Nexus
echo "Downloading Nexus Repository..."
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz
sudo tar -zxvf nexus-unix-x86-64-3.79.0-09.tar.gz
sudo mv nexus-3.79.0-09 nexus

# Create nexus user
echo "Creating nexus user..."
sudo adduser --disabled-password --gecos "" nexus

# Allow nexus user to run commands without password
echo "Configuring passwordless sudo for nexus..."
echo "nexus ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nexus

# Set permissions
echo "Setting permissions for nexus directories..."
sudo chown -R nexus:nexus /opt/nexus
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/sonatype-work

# Configure nexus.rc to run as nexus user
echo "Configuring nexus.rc..."
sudo sed -i 's|^#run_as_user=.*|run_as_user="nexus"|' /opt/nexus/bin/nexus.rc

# Set JVM options (can be tuned as needed)
echo "Configuring JVM options..."
sudo tee /opt/nexus/bin/nexus.vmoptions > /dev/null <<EOF
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

# Create systemd service
echo "Creating systemd service file for nexus..."
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
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

# Reload systemd and enable/start the nexus service
echo "Enabling and starting Nexus service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Open firewall port (optional)
echo "Allowing Nexus through UFW on port 8081..."
sudo ufw allow 8081/tcp

# Final message
echo "Nexus Repository Manager is installed and running."
echo "Access it via: http://<your-server-ip>:8081"
