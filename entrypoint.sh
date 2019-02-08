#!/usr/bin/env sh

# Start mysql to add user
echo "Running mysql_install_db..."
mysql_install_db 1>/dev/null
echo "Starting temp MySQL..."
/usr/sbin/mysqld &
pid="$!"

for i in {15..0}; do
  if echo 'SELECT 1' | mysql 1>/dev/null; then
      break
  fi
  sleep 2
done

echo "Adding drupal user..."
mysql <<-EOSQL
  DROP DATABASE IF EXISTS test ;
  CREATE DATABASE drupal;
  CREATE USER 'drupal'@'localhost' IDENTIFIED BY 'drupal';
  GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost';
EOSQL
echo 'FLUSH PRIVILEGES' | mysql

echo "Killing temp MySQL..."
kill $pid

/bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf

eatmydata multirun /apache-foreground.sh /usr/sbin/mysqld