#!/usr/bin/env sh
set -e

# Download the latest stable release of Drupal.
DRUPAL_DOWNLOAD_URL="https://ftp.drupal.org/files/projects/drupal-7.63.tar.gz"
DRUPAL_HASH_SALT=`php -r "echo bin2hex(random_bytes(25));"`

echo "Removing any existing files inside /var/www/localhost..."
find /var/www/localhost -type f -maxdepth 1 -delete
mkdir /var/www/localhost/web

echo "Downloading Drupal..."
cd /var/www/localhost/web
curl -sSL $DRUPAL_DOWNLOAD_URL | tar -xz --strip-components=1
mkdir -p /var/www/localhost/config/sync
echo "Download complete!"

echo "Configuring settings.php with environment variables..."
cp /var/www/localhost/web/sites/default/default.settings.php /var/www/localhost/web/sites/default/settings.php
cat <<EOF >> /var/www/localhost/web/sites/default/settings.php
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
\$settings['hash_salt'] = '$DRUPAL_HASH_SALT';
EOF

echo "Correcting permissions on /var/www/localhost..."
chown -R apache:apache /var/www/localhost
echo "Drupal codebase ready!"
