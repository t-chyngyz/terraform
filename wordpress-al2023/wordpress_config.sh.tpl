#!/bin/bash
dnf install wget php8.1-gd php-mysqlnd httpd php-fpm php-mysqli php-json php php-devel -y
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/html
chown -R apache:apache  /var/www/html
find /var/www/html/ -type d -exec chmod 750 {} \;
find /var/www/html/ -type f -exec chmod 640 {} \;
sed -i 's/username_here/${username}/g' /var/www/html/wp-config.php
sed -i 's/password_here/${password}/g' /var/www/html/wp-config.php
sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
sed -i 's/localhost/${rds_endpoint}/g' /var/www/html/wp-config.php
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd
mv /var/www/html/index.html /opt