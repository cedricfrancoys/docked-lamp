FROM ubuntu:18.04
MAINTAINER Cedric Francoys <cedricfrancoys@gmail.com>
LABEL Description="LAMP stack, based on Ubuntu 18.04 LTS. php-7.2 apache2 mariaDB-10" \
        License="Apache License 2.0" \
        Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql docked_lamp" \
        Version="1.0"

ARG mysql_uid
ARG mysql_gid
ARG apache_uid
ARG apache_gid

RUN apt-get update
RUN apt-get upgrade -y

COPY debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		php \
		php-bz2 \
		php-cgi \
		php-cli \
		php-common \
		php-curl \
		php-dev \
		php-gd \
		php-gmp \
		php-intl \
		php-json \
		php-mbstring \
		php-mcrypt \
		php-mysql \
		php-opcache \
		php-phpdbg \
		php-pspell \
		php-readline \
		php-sqlite3 \
		php-xsl \
		php-zip; \
	configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*


RUN apt-get install -y apache2 libapache2-mod-php mariadb-common mariadb-server mariadb-client postfix


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite expires

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

COPY run-lamp.sh /usr/sbin/

RUN /usr/sbin/usermod -u $mysql_uid mysql && /usr/sbin/groupmod -g $mysql_gid mysql && /usr/sbin/usermod -u $apache_uid www-data && /usr/sbin/groupmod -g $apache_gid www-data

RUN chmod +x /usr/sbin/run-lamp.sh
