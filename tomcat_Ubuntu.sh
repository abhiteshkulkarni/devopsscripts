#!/bin/bash

set -e  # Exit on any error

# 1. Install Java 17 (LTS)
sudo apt update
sudo apt install openjdk-17-jdk -y

# 2. Download Tomcat 10.1.85 (latest 10.1.x)
TOMCAT_VERSION=10.1.85
TOMCAT_BASE_URL="https://dlcdn.apache.org/tomcat/tomcat-10/v$TOMCAT_VERSION/bin"
TOMCAT_TAR="apache-tomcat-$TOMCAT_VERSION.tar.gz"

wget "$TOMCAT_BASE_URL/$TOMCAT_TAR"
wget "$TOMCAT_BASE_URL/$TOMCAT_TAR.sha512"

# 3. Verify checksum
sha512sum -c "$TOMCAT_TAR.sha512"

# 4. Extract
tar -zxvf "$TOMCAT_TAR"

# 5. Configure tomcat-users.xml
TOMCAT_DIR="apache-tomcat-$TOMCAT_VERSION"
CONF="$TOMCAT_DIR/conf/tomcat-users.xml"
cp "$CONF" "$CONF.bak"

# Insert roles and user before </tomcat-users>
sed -i '/<\/tomcat-users>/i\
<role rolename="manager-gui"/>\n\
<role rolename="manager-script"/>\n\
<user username="tomcat" password="root123" roles="manager-gui,manager-script"/>' "$CONF"

# 6. Permit manager app access (remove RemoteAddrValve to allow all IPs)
CTX="$TOMCAT_DIR/webapps/manager/META-INF/context.xml"
cp "$CTX" "$CTX.bak"
sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' "$CTX"

# 7. Start Tomcat
sh "$TOMCAT_DIR/bin/startup.sh"

echo "Tomcat $TOMCAT_VERSION started. Access http://<host>:8080"
