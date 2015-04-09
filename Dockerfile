# this is a Dockerfile to build an auto-starting docker container of an entire rAthena stack including FluxCP to manage access to the server from a website.
### 0
       FROM ubuntu

### 1
 MAINTAINER George Georgulas IV <georgegeorgulasiv@gmail.com>

### 2
        CMD bash

### 3
 ENTRYPOINT /boottime.sh

### 4
       USER root

### 5
        ENV HOME /root

### 6
        ENV DEBIAN_FRONTEND noninteractive
### 7
# work in the /usr/bin/rathena directory (for when we configure and make later)
    WORKDIR /usr/bin/rathena/

### 8
# update apt repositories
        RUN apt-get update \

# upgrade the ubuntu image you pulled from with the most current libs, auto-agree (-y)
         && apt-get -y dist-upgrade \

# install all of our packages, auto-agree (-y)
         && apt-get -y --force-yes install \
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
                                           php-apc \
                                           php5-mcrypt \
                                           zlib1g-dev

# add necessary files
### 9
        ADD 000-default.conf /etc/apache2/sites-available/
### 10
        ADD import.sql /
### 11
        ADD my.cnf /etc/mysql/conf.d/
### 12
        ADD boottime.sh /

### 13
# add the ‘localhost’ hostname to the apache2 configs
        RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \

# clone FluxCP to /var/www/html from github
         && rm -fr /var/www/html \
         && git clone https://github.com/rathena/FluxCP.git /var/www/html \

# clone rAthena into /usr/bin/rathena from github
         && git clone https://github.com/rathena/rathena.git /usr/bin/rathena \

# configure make and select packet version 

         && ./configure --enable-packetver=20131223 \

# compile rAthena server binaries
         && make server \

# import rAthena mysql files by (tell me there’s a better way)
#   starting the mysql service
         && service mysql start \
#   importing the list of .sql files from the rAthena git pullfile)
         && mysql < /import.sql \
#   stopping the mysql service
         && service mysql stop \
#   and cleaning up after ourselves by removing the list
         && rm -f /import.sql \

# uninstall the developer tools, auto-agree (-y)
         && apt-get -y remove gcc git make \

# chmod the rAthena server binaries and boottime.sh to be executable by anyone
         && chmod a+x /usr/bin/rathena/*-server \
                      /usr/bin/rathena/athena-start \
                      /boottime.sh
        RUN chmod -R 777 /var/www/html/data \
         && chown -R 33:33 /var/www/html/data \

# configure apache to use .htaccess
         && a2enmod rewrite \
         && service apache2 restart \
         && service apache2 stop

### 14
# Environment variables to configure php
        ENV PHP_UPLOAD_MAX_FILESIZE 10M

### 15
        ENV PHP_POST_MAX_SIZE 10M

### 16
# Add volumes to be shared to host for configuration file access
     VOLUME /etc/mysql /var/lib/mysql /usr/bin/rathena/conf

### 17
# open ports for network access
     EXPOSE 80 443 3306 5121 6121 6900

# use this container with a command like:

# docker run -it -p 20000:80 -p 20001:443 -p 20002:3306 -p 20003:5121 -p 20004:6121 -p 20005:6900 -e USER=root georgegeorgulasiv/tritogeneia