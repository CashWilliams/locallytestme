#!/usr/bin/env sh
set -e

echo "*** Removing any existing files inside /var/www/html..."
find /var/www/html -type f -maxdepth 1 -delete

# Setup Drupal
echo "*** Downloading Drupal..."
cd /var/www/html
composer create-project drupal-composer/drupal-project:8.x-dev /var/www/html --stability dev --no-interaction --no-progress
echo "*** Download complete..."

mkdir -p /var/www/html/web/config/sync
chown -R www-data:www-data /var/www
mkdir -p /var/log/php
chmod a+rw /var/log/php
/bin/sed -i 's/;error_log\ =\ php_errors.log/error_log\ =\ \/var\/log\/php\/php_errors.log/g' /etc/php/7.2/cli/php.ini
/bin/sed -i 's/;error_log\ =\ php_errors.log/error_log\ =\ \/var\/log\/php\/php_errors.log/g' /etc/php/7.2/apache2/php.ini

echo "*** Configuring settings.php with environment variables..."
DRUPAL_HASH_SALT=`php -r "echo bin2hex(random_bytes(25));"`
cp /var/www/html/web/sites/default/default.settings.php /var/www/html/web/sites/default/settings.php
cat <<EOF >> /var/www/html/web/sites/default/settings.php
\$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupal',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'namespace' => 'Drupal\\\\Core\\\\Database\\\\Driver\\\\mysql',
  'driver' => 'mysql',
);
\$config_directories['sync'] = '../config/sync';
\$settings['hash_salt'] = '$DRUPAL_HASH_SALT';
\$settings['trusted_host_patterns'] = array(
  '^localhost$',
);
\$settings['file_chmod_directory'] = 02775;
EOF
# mink WAT https://www.drupal.org/node/2948700
cd /var/www/html/web && curl -s https://www.drupal.org/files/issues/2948700-5.patch | patch -p1

echo "*** Drupal codebase ready..."

echo "*** Configure apache for debuging..."
ln -sfT /dev/stderr "/var/log/apache2/error.log";
ln -sfT /dev/stdout "/var/log/apache2/access.log";
ln -sfT /dev/stderr "/var/log/php/php_errors.log";

