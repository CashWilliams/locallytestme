FROM ubuntu:18.04

RUN set -ex \
	&& apt-get update \
    && apt-get -q -y dist-upgrade \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get -q -y install --no-install-recommends \
	ca-certificates \
    apache2 \
    mariadb-server \
	mariadb-client \
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
	#php-xdebug \
    libapache2-mod-php \
	eatmydata \
	git \
	zip \
	sudo \
	wget \
	patch \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& ln -s /usr/bin/vim.tiny /usr/bin/vim \
	&& rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld \
	&& a2enmod rewrite

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -Ls https://github.com/nicolas-van/multirun/releases/download/0.3.0/multirun-ubuntu-0.3.0.tar.gz | tar -zxv -C /usr/local/bin

COPY ./*.sh /
COPY ./site.conf /etc/apache2/sites-available/000-default.conf
RUN chmod +x /*.sh && sh /init.sh
ENV PATH="/var/www/html/vendor/bin/:${PATH}"

#COPY php.ini "$PHP_INI_DIR/php.ini"
#COPY my.cnf /etc/mysql/my.cnf

WORKDIR /var/www/html/

EXPOSE 80
#EXPOSE 443
#EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]