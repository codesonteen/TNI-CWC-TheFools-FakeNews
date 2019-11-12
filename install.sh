#!/bin/bash

# Check Root Privilege
if [ "$EUID" -ne 0 ]
  then echo "Root privilege is required to run the installation script."
  exit
fi

# Install Packages (Nginx, MySQL, PHP-FPM)
apt install -y nginx mysql-server php-fpm php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-ldap php-zip php-curl

# Copy files
cp -rf env/* /

# Remove default index.html
rm -f /var/www/html/index.nginx-debian.html

# Set owners and permission for public files
chown -R www-data. /var/www/html
chown root. /var/www/html/batch_process_service_status.sh
chmod 777 /var/www/html/batch_process_service_status.sh

# Set (Ensure) owner and permission for system files
chmod 644 /etc/nginx/sites-available/default
chmod 644 /etc/mysql/conf.d/mysql.conf
chmod 644 /etc/php/7.2/fpm/pool.d/www.conf

# Restart services
systemctl restart nginx
systemctl restart mysql

# Setup database
mysql -e "create database fakenews"
mysql -e 'create user "faker"@"localhost" IDENTIFIED BY "S3a0#d9$yj"'
mysql -e 'GRANT SELECT, INSERT ON fakenews.* TO "faker"@"localhost"'
mysql fakenews < imports/fakenews.sql

# Setup Cron
crontab imports/cronjobs