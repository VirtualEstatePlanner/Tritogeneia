FROM ubuntu:trusty
MAINTAINER George Georgulas IV <georgegeorgulasiv@gmail.com>
USER root
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Install packages
     RUN apt-get -qq update \
      && apt-get -yqq dist-upgrade \
      && apt-get -yqq install \
      apache2 \
      gcc \
      git \
      libapache2-mod-php5 \
      libmysqlclient-dev \
      libpcre3-dev \
      make \
      mysql-client \
      mysql-server \
      php5-mysql \
      pwgen \
      php-apc \
      php5-mcrypt \
      supervisor \
      zlib1g-dev \
      && echo "ServerName localhost" >> /etc/apache2/apache2.conf


# Configure /app folder with sample app
      RUN \
      rm -fr /var/www/html && \
      git clone https://github.com/rathena/FluxCP.git /var/www/html

# git clone rAthena into place
    RUN git clone https://github.com/rathena/rathena.git /usr/bin/rathena
    WORKDIR /usr/bin/rathena/
# configure make and select packet version 
    RUN ./configure --enable-packetver=20131223 \
# compile rAthena server binaries
 && make server \
# CHMOD server binaries to be executable by anyone
 && chmod 755 *-server athena-start
    WORKDIR /

# Add image configuration and scripts
      ADD start-apache2.sh /start-apache2.sh
      ADD start-mysqld.sh /start-mysqld.sh
      ADD run.sh /run.sh
      RUN chmod 755 /*.sh
      ADD my.cnf /etc/mysql/conf.d/my.cnf
      ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
      ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
     # RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
      ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
      RUN chmod 755 /*.sh

# config to enable .htaccess
      ADD apache_default /etc/apache2/sites-available/000-default.conf
      RUN a2enmod rewrite

# import rAthena sql databases
      ADD import.sql /
      RUN service mysql start && mysql < /import.sql && service mysql stop \
       && apt-get -y remove gcc git make

#Environment variables to configure php
      ENV PHP_UPLOAD_MAX_FILESIZE 10M
      ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL
      VOLUME  /etc/mysql /var/lib/mysql /usr/bin/rathena/conf

EXPOSE 80 443 3306 5121 6121 6900
      CMD bash
      ENTRYPOINT /run.sh
