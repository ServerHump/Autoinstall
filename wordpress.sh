#!/bin/bash

# Define variables for WordPress installation
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=password
DB_HOST=localhost
WORDPRESS_URL=https://wordpress.org/latest.tar.gz
INSTALL_DIR=/var/www/html
SSL_DOMAIN=example.com
SSL_EMAIL=admin@example.com

# Install latest versions of PHP, MySQL, and MariaDB
sudo dnf update -y
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.0 -y
sudo dnf module reset mysql -y
sudo dnf module enable mysql:8.0 -y
sudo dnf install -y httpd mariadb mariadb-server php php-mysqlnd php-gd php-xml php-xmlrpc php-mbstring php-json php-zip wget tar policycoreutils-python-utils

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

# Allow WordPress and required ports through SELinux
sudo semanage fcontext -a -t httpd_sys_rw_content_t "${INSTALL_DIR}(/.*)?"
sudo semanage port -a -t http_port_t -p tcp 80
sudo semanage port -a -t http_port_t -p tcp 8080
sudo semanage port -a -t http_port_t -p tcp 443
sudo semanage port -a -t mysql_port_t -p tcp 3306
sudo semanage port -a -t smtp_port_t -p tcp 25
sudo semanage port -a -t submission_port_t -p tcp 587
sudo semanage port -a -t smtps_port_t -p tcp 465
sudo semanage port -a -t alternate_smtp_port_t -p tcp 2525
sudo semanage port -a -t imap_port_t -p tcp 993
sudo semanage port -a -t pop_port_t -p tcp 110
sudo semanage port -a -t pop_port_t -p tcp 995
sudo restorecon -Rv ${INSTALL_DIR}

# Start and enable services
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Create database and user
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${DB_HOST}';"

# Download and extract WordPress
sudo wget ${WORDPRESS_URL} -O /tmp/wordpress.tar.gz
sudo tar xf /tmp/wordpress.tar.gz -C ${INSTALL_DIR}

# Move WordPress files to the root directory
sudo mv ${INSTALL_DIR}/wordpress/* ${INSTALL_DIR}

# Configure WordPress
sudo cp ${INSTALL_DIR}/wp-config-sample.php ${INSTALL_DIR}/wp-config.php
sudo sed -i "s/database_name_here/${DB_NAME}/g" ${INSTALL_DIR}/wp-config.php
sudo sed -i "s/username_here/${DB_USER}/g" ${INSTALL_DIR}/wp-config.php
sudo sed -i "s/password_here/${DB_PASSWORD}/g" ${INSTALL_DIR}/wp-config.php

# Set permissions
sudo chown -R apache:apache ${INSTALL_DIR}
sudo find ${INSTALL_DIR} -type d -exec chmod 755 {} \;
sudo find ${INSTALL_DIR} -type f -exec chmod 644 {} \;

# Restart services
sudo systemctl restart httpd

# Display wp-admin username and password
echo "WordPress installed successfully!"

# Install certbot (Let's Encrypt client)
sudo dnf install -y certbot python3-certbot-apache

# Obtain SSL certificate and configure automatic renewal
sudo certbot --apache --agree-tos --email ${SSL_EMAIL} --redirect --non-interactive --domains ${SSL_DOMAIN}

# Create a cron job for certificate renewal
sudo echo "0 0 1 * * certbot renew --quiet" | sudo tee -a /etc/crontab > /dev/null

echo "LetEncrypt SSL installed successfully!"

