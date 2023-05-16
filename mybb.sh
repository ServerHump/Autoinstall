#!/bin/bash

# Define variables for MyBB installation
DB_NAME=mybb_db
DB_USER=mybb_user
DB_PASSWORD=password
DB_HOST=localhost
MYBB_URL=https://resources.mybb.com/downloads/mybb_1822.zip
INSTALL_DIR=/var/www/html

# Install required packages
sudo dnf update -y
sudo dnf install -y httpd mariadb mariadb-server php php-mysqlnd php-gd php-xml php-xmlrpc php-mbstring php-json php-zip unzip wget

# Allow ports 443, 80, 8080, and SQL port in the firewall
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --permanent --add-port=25/tcp
sudo firewall-cmd --permanent --add-port=587/tcp
sudo firewall-cmd --permanent --add-port=465/tcp
sudo firewall-cmd --permanent --add-port=2525/tcp
sudo firewall-cmd --permanent --add-port=993/tcp
sudo firewall-cmd --permanent --add-port=143/tcp
sudo firewall-cmd --permanent --add-port=110/tcp
sudo firewall-cmd --permanent --add-port=995/tcp
sudo firewall-cmd --reload

# Start and enable services
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Create database and user
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${DB_HOST}';"

# Download and extract MyBB
sudo wget ${MYBB_URL} -O /tmp/mybb.zip
sudo unzip /tmp/mybb.zip -d ${INSTALL_DIR}

# Set permissions
sudo chown -R apache:apache ${INSTALL_DIR}
sudo chmod -R 755 ${INSTALL_DIR}/inc/languages
sudo chmod -R 755 ${INSTALL_DIR}/uploads
sudo chmod -R 777 ${INSTALL_DIR}/cache
sudo chmod -R 777 ${INSTALL_DIR}/uploads/avatars

# Create configuration file
sudo mv ${INSTALL_DIR}/inc/config.default.php ${INSTALL_DIR}/inc/config.php
sudo chmod 777 ${INSTALL_DIR}/inc/config.php

# Configure MyBB database settings
sudo sed -i "s/^\$config\['database'\]\['type'\] = 'mysqli';/\$config\['database'\]\['type'\] = 'mysql';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['database'\] = 'mybb';/\$config\['database'\]\['database'\] = '${DB_NAME}';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['username'\] = 'mybbuser';/\$config\['database'\]\['username'\] = '${DB_USER}';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['password'\] = 'mypassword';/\$config\['database'\]\['password'\] = '${DB_PASSWORD}';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['hostname'\] = 'localhost';/\$config\['database'\]\['hostname'\] = '${DB_HOST}';/g" ${INSTALL_DIR}/inc/config.php

# Restart services
sudo systemctl restart httpd

echo "MyBB installed successfully!"
