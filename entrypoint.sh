#!/usr/bin/env sh

# Start mysql to add user
mysql_install_db --user=mysql
mysqld --user=mysql &
pid="$!"

for i in {15..0}; do
  if echo 'SELECT 1' | mysql &> /dev/null; then
    break
  fi
  echo 'MySQL init process in progress...'
  sleep 2
done

if [ "$i" = 0 ]; then
  echo >&2 'MySQL init process failed.'
  exit 1
fi

mysql <<-EOSQL
  DROP DATABASE IF EXISTS test ;
  CREATE DATABASE drupal;
  CREATE USER 'drupal'@'localhost' IDENTIFIED BY 'drupal';
  GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost';
EOSQL
echo 'FLUSH PRIVILEGES' | mysql

kill $pid

echo 'MySQL init process done.'

/run.sh