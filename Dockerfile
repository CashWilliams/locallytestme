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
	eatmydata \
	git \
	zip \
	sudo \
	wget \
	patch \
	gnupg2 \
	php7.2-dev \
	autoconf \
	automake \
	libtool \
	m4 \
	build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& ln -s /usr/bin/vim.tiny /usr/bin/vim \
	&& rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld \
	&& a2enmod rewrite
	
RUN git clone https://github.com/tideways/php-xhprof-extension.git /tmp/php-xhprof-extension \
	&& cd /tmp/php-xhprof-extension \
	&& phpize \
	&& ./configure \
	&& make \
	&& make install \
	&& echo "extension=tideways_xhprof.so" > /etc/php/7.2/cli/conf.d/20-xhprof.ini \
	&& echo "extension=tideways_xhprof.so" > /etc/php/7.2/apache2/conf.d/20-xhprof.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -Ls https://github.com/nicolas-van/multirun/releases/download/0.3.0/multirun-ubuntu-0.3.0.tar.gz | tar -zxv -C /usr/local/bin

COPY my.cnf /etc/mysql/conf.d/custom.cnf
COPY ./site.conf /etc/apache2/sites-available/000-default.conf

COPY ./*.sh /
RUN chmod +x /*.sh && sh /init.sh
ENV PATH="/var/www/html/vendor/bin/:${PATH}"

WORKDIR /var/www/html/

EXPOSE 80
#EXPOSE 443
#EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]