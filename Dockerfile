# this is a Dockerfile to build an auto-starting docker container that runs the entire rAthena stack including FluxCP to manage access to the server from a website.

       FROM ubuntu

 MAINTAINER George Georgulas IV <georgegeorgulasiv@gmail.com>

        CMD bash

 ENTRYPOINT /run.sh

       USER root

        ENV HOME /root

        ENV DEBIAN_FRONTEND noninteractive

# update apt repositories
        RUN apt-get update \

# upgrade the ubuntu image you pulled from with the most current libs, auto-agree (-y)
         && apt-get -y dist-upgrade \

# install all of our packages, auto-agree (-y)
         && apt-get -y install \
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

# add the ‘localhost’ hostname to the apache2 configs
         && echo "ServerName localhost" >> /etc/apache2/apache2.conf \

# Clone FluxCP to /var/www/html from github
         && rm -fr /var/www/html \
         && git clone https://github.com/rathena/FluxCP.git /var/www/html \

# Clone rAthena into /usr/bin/rathena from github
         && git clone https://github.com/rathena/rathena.git /usr/bin/rathena

# configure make and select packet version 
    WORKDIR /usr/bin/rathena/
        RUN ./configure --enable-packetver=20131223 \

# compile rAthena server binaries
         && make server \

# chmod server binaries to be executable by anyone
         && chmod a+x *-server athena-start

# add necessary files
        ADD import.sql /
        ADD start-apache2.sh /start-apache2.sh
        ADD start-mysqld.sh /start-mysqld.sh
        ADD run.sh /run.sh
        ADD my.cnf /etc/mysql/conf.d/my.cnf
        ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
        ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
        ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
        ADD apache_default /etc/apache2/sites-available/000-default.conf

# import rAthena mysql default database files
        RUN service mysql start \
         && mysql < /import.sql \
         && service mysql stop \

# remove developer tools
         && apt-get -y remove gcc git make
    WORKDIR /

# chmod scripts at root level of hdd to be executable by anyone
        RUN chmod a+x /*.sh

# config to enable .htaccess
        RUN a2enmod rewrite

# Environment variables to configure php
        ENV PHP_UPLOAD_MAX_FILESIZE 10M
        ENV PHP_POST_MAX_SIZE 10M

# Add volumes to be shared to host for configuration
     VOLUME /etc/mysql /var/lib/mysql /usr/bin/rathena/conf

# open ports for network access
     EXPOSE 80 443 3306 5121 6121 6900