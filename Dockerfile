FROM ubuntu:24.04

# Install base Ubuntu packages.
RUN set -ex \
	&& apt-get update \
  && apt-get -q -y dist-upgrade \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get -q -y install --no-install-recommends \
    ca-certificates \
    apache2 \
    mariadb-server \
    mariadb-client \
    sqlite3 \
    curl \
    vim-tiny \
    php \
    php-gd \
    php-curl \
    php-xml \
    php-mbstring \
    php-mysql \
    php-zip \
    php-uploadprogress \
    php-sqlite3 \
    php-yaml \
    libapache2-mod-php \
    git \
    zip \
    sudo \
    wget \
    patch \
    gnupg2 \
    php8.3-dev \
    autoconf \
    automake \
    libtool \
    m4 \
    supervisor \
    build-essential \
    zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && ln -s /usr/bin/vim.tiny /usr/bin/vim \
  && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
  && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
  && chmod 777 /var/run/mysqld \
  && a2enmod rewrite

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV PATH="/var/www/html/vendor/bin/:${PATH}"

# Copy custom mysql conf.
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy default apache vhost.
COPY conf/site.conf /etc/apache2/sites-available/000-default.conf

# Using supervisor to run both apache and mysql.
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

# Copy custom php.ini
COPY conf/php.ini /etc/php/8.3/apache2/php.ini

# Copy start scripts.
COPY scripts/run.sh /
COPY scripts/entrypoint.sh /
COPY scripts/init.sh /
COPY scripts/start-apache2.sh /
COPY scripts/start-mysqld.sh /
RUN chmod +x /*.sh
RUN sh /init.sh
COPY conf/settings.php /var/www/html/web/sites/default/settings.php

WORKDIR /var/www/html/

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
