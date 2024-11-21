#!/usr/bin/env sh
set -e

echo "*** Removing any existing files inside /var/www/html..."
find /var/www/html -type f -maxdepth 1 -delete
chown -R www-data:www-data /var/www

echo "*** Configure logging..."
mkdir -p /var/log/php
chmod a+rw /var/log/php
/bin/sed -i 's/;error_log\ =\ php_errors.log/error_log\ =\ \/var\/log\/php\/php_errors.log/g' /etc/php/8.3/cli/php.ini
/bin/sed -i 's/;error_log\ =\ php_errors.log/error_log\ =\ \/var\/log\/php\/php_errors.log/g' /etc/php/8.3/apache2/php.ini
echo "general_log_file = /var/log/mysql/mysql.log" >> /etc/mysql/mariadb.conf.d/50-server.cnf

echo "*** Installing Drupal..."
#composer create-project drupal/recommended-project /var/www/html

git clone https://git.drupalcode.org/project/drupal_cms.git /var/www/html
sed "s|\"url\": \"|\"url\": \"/var/www/html/|g" /var/www/html/components.composer.json > $(composer config --global home)/config.json
composer config --global repositories.template path /var/www/html/project_template
composer create-project drupal/cms /var/www/html/project --stability=dev
ln -snf /var/www/html/project/web /var/www/html/web

chmod 2775 /var/www/html/project_template
chgrp -R www-data /var/www/html/project_template
chmod g+w /var/www/html/project_template/web
chmod g+w /var/www/html/project_template/vendor

