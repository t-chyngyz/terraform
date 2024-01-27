#!/bin/bash
apt update
apt install -y apache2 php libapache2-mod-php php-mysql php-curl php-gd php-imagick php-mbstring php-xml php-xmlrpc
systemctl stop nginx
systemctl disable nginx
systemctl start apache2
systemctl enable apache2
a2enmod rewrite
systemctl restart apache2
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/html
chown -R www-data:www-data /var/www/html
find /var/www/html/ -type d -exec chmod 750 {} \;
find /var/www/html/ -type f -exec chmod 640 {} \;
mv /var/www/html/index.html /opt
sed -i 's/username_here/${username}/g' /var/www/html/wp-config.php
sed -i 's/password_here/${password}/g' /var/www/html/wp-config.php
sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
sed -i 's/localhost/${rds_endpoint}/g' /var/www/html/wp-config.php