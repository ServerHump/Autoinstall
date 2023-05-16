#!/bin/bash

# Define variables for MyBB installation
DB_NAME=mybb_db
DB_USER=mybb_user
DB_PASSWORD=password
DB_HOST=localhost
MYBB_URL=https://resources.mybb.com/downloads/mybb_1822.zip
INSTALL_DIR=/var/www/html

# Install required packages
#sudo dnf update -y
sudo dnf install -y httpd mariadb mariadb-server php php-mysqlnd php-gd php-xml php-xmlrpc php-mbstring php-json php-zip unzip wget

# Set memory limit in php.ini
sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php.ini

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

# Allow mybb and required ports through SELinux
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "${INSTALL_DIR}(/.*)?"
#sudo semanage port -a -t http_port_t -p tcp 80
#sudo semanage port -a -t http_port_t -p tcp 8080
#sudo semanage port -a -t http_port_t -p tcp 443
#sudo semanage port -a -t mysql_port_t -p tcp 3306
#sudo semanage port -a -t smtp_port_t -p tcp 25
#sudo semanage port -a -t submission_port_t -p tcp 587
#sudo semanage port -a -t smtps_port_t -p tcp 465
#sudo semanage port -a -t alternate_smtp_port_t -p tcp 2525
#sudo semanage port -a -t imap_port_t -p tcp 993
#sudo semanage port -a -t pop_port_t -p tcp 110
#sudo semanage port -a -t pop_port_t -p tcp 995
#sudo restorecon -Rv ${INSTALL_DIR}

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

# Move Upload directory to the root directory
sudo mv ${INSTALL_DIR}/Upload/* ${INSTALL_DIR}
sudo rm -rf ${INSTALL_DIR}/Upload

# Set permissions
sudo chown -R apache:apache ${INSTALL_DIR}
sudo chmod -R 755 ${INSTALL_DIR}/inc/languages
sudo chmod -R 755 ${INSTALL_DIR}/uploads
sudo chmod -R 777 ${INSTALL_DIR}/cache
sudo chmod -R 777 ${INSTALL_DIR}/uploads/avatars


# Create configuration file
sudo cp ${INSTALL_DIR}/inc/config.default.php ${INSTALL_DIR}/inc/config.php
sudo chmod 666 ${INSTALL_DIR}/inc/config.php

# Configure MyBB database settings
sudo sed -i "s/^\$config\['database'\]\['type'\] = 'mysqli';/\$config\['database'\]\['type'\] = 'mysql';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['database'\] = 'mybb';/\$config\['database'\]\['database'\] = '${DB_NAME}';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['username'\] = 'mybbuser';/\$config\['database'\]\['username'\] = '${DB_USER}';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['password'\] = 'mypassword';/\$config\['database'\]\['password'\] = '${DB_PASSWORD}';/g" ${INSTALL_DIR}/inc/config.php
sudo sed -i "s/^\$config\['database'\]\['hostname'\] = 'localhost';/\$config\['database'\]\['hostname'\] = '${DB_HOST}';/g" ${INSTALL_DIR}/inc/config.php

# Restart services
sudo systemctl restart httpd

echo "MyBB installed successfully!"
