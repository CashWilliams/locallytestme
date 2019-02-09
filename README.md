# LocallyTestMe

## Running tests
sudo -u www-data php core/scripts/run-tests.sh --url http://localhost --php `which php` --verbose --browser --module book 

# Performance

## SQLite with tmpfs
docker run -ti -p "8080:80" --tmpfs /var/sqlite 44fde7710128
php core/scripts/run-tests.sh --url http://localhost --php `which php` --sqlite /var/sqlite/test.sqlite --module book
with tmpfs Test run duration: 1 min 48 sec


## SQLite without tmpfs
docker run -ti -p "8080:80" ad9226137604
php core/scripts/run-tests.sh --url http://localhost --php `which php` --sqlite /var/sqlite/test.sqlite --module book
Test run duration: 3 min 37 sec


## MySQL without tmpfs
docker run -ti -p "8080:80" 868f1a8d95e6
php core/scripts/run-tests.sh --url http://localhost --php `which php` --module book
Test run duration: 1 min 57 sec


## MySQL with tmpfs
docker run -ti -p "8080:80" --tmpfs /var/lib/mysql 868f1a8d95e6
php core/scripts/run-tests.sh --url http://localhost --php `which php` --module book
Test run duration: 1 min 46 sec


