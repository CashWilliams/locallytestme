FROM alpine:latest

# Basic dependencies
RUN set -ex \
	&& apk add --no-cache --virtual .build-deps \
		coreutils \
		freetype-dev \
		libjpeg-turbo-dev \
		libpng-dev \
	    curl \
	    git \
		sqlite \
	    php7-apache2 \
	    php7-cli \
	    php7-ctype \
	    php7-curl \
	    php7-dom \
	    php7-gd \
	    php7-iconv \
	    php7-json \
	    php7-mbstring \
	    php7-opcache \
	    php7-openssl \
		php7-pdo_sqlite \
	    php7-phar \
	    php7-tokenizer \
	    php7-xml \
	    php7-xmlwriter \
	    php7-session \
	    php7-simplexml \
	&& \
	# Composer
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    # Apache config
	mkdir -p /run/apache2 && chown -R apache:apache /run/apache2 && \
    sed -ri \
      -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
      -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
      -e 's#/var/www/localhost/htdocs#/var/www/localhost/web#g' \
      -e 's#AllowOverride None#AllowOverride All#g' \
      -e 's!^#LoadModule rewrite_module!LoadModule rewrite_module!' \
      /etc/apache2/httpd.conf \
	&& echo "Success"

COPY php.ini /etc/php7/php.ini
COPY my.cnf /etc/mysql/my.cnf
COPY ./*.sh /

RUN chmod +x /*.sh && sh /init.sh

WORKDIR /var/www/localhost/

# TODO SSL
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]