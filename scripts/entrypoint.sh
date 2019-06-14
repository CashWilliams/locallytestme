#!/usr/bin/env sh

# This is not baked into the container to allow tmpfs volume storage of mysql.
echo "*** Starting temp MySQL..."
mysql_install_db > /dev/null 2>&1
/usr/bin/mysqld_safe > /dev/null 2>&1 &

for i in {15..0}; do
  sleep 2
  if echo 'SELECT 1' | mysql 1>/dev/null; then
      break
  fi
done

echo "*** Adding drupal user..."
mysql <<-EOSQL
  DROP DATABASE IF EXISTS test ;
  CREATE DATABASE drupal;
  CREATE USER 'drupal'@'localhost' IDENTIFIED BY 'drupal';
  GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost';
EOSQL
echo 'FLUSH PRIVILEGES' | mysql

echo "*** Killing temp MySQL..."
mysqladmin -uroot shutdown

exec supervisord -n -c /etc/supervisor/supervisord.conf