#!/usr/bin/env sh
set -e

echo "*** Removing any existing files inside /var/www/html..."
find /var/www/html -type f -maxdepth 1 -delete
chown -R www-data:www-data /var/www

echo "*** Configure logging..."
mkdir -p /var/log/php
chmod a+rw /var/log/php
/bin/sed -i 's/;error_log\ =\ php_errors.log/error_log\ =\ \/var\/log\/php\/php_errors.log/g' /etc/php/7.2/cli/php.ini
/bin/sed -i 's/;error_log\ =\ php_errors.log/error_log\ =\ \/var\/log\/php\/php_errors.log/g' /etc/php/7.2/apache2/php.ini
echo "general_log_file = /var/log/mysql/mysql.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf
ln -sfT /dev/stderr "/var/log/apache2/error.log";
ln -sfT /dev/stdout "/var/log/apache2/access.log";
ln -sfT /dev/stderr "/var/log/php/php_errors.log";