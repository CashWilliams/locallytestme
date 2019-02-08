#!/usr/bin/env sh
set -e

# Download the latest stable release of Drupal.
DRUPAL_DOWNLOAD_URL="https://www.drupal.org/download-latest/tar.gz"
DRUPAL_HASH_SALT=`php -r "echo bin2hex(random_bytes(25));"`

echo "Removing any existing files inside /var/www/localhost..."
find /var/www/html -type f -maxdepth 1 -delete

echo "Downloading Drupal..."
cd /var/www/html
curl -sSL $DRUPAL_DOWNLOAD_URL | tar -xz --strip-components=1
mkdir -p /var/www/config/sync
echo "Download complete!"

echo "Configuring settings.php with environment variables..."
cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php
cat <<EOF >> /var/www/html/sites/default/settings.php
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
EOF

echo "Correcting permissions on /var/www..."
chown -R www-data:www-data /var/www
echo "Drupal codebase ready!"
