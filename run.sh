#!/usr/bin/env sh

echo 'Starting servers'
multirun "httpd -D FOREGROUND" "/usr/bin/mysqld --user=mysql --console"
