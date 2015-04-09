# this is a Dockerfile to build an auto-starting docker container of an entire rAthena stack including FluxCP to manage access to the server from a website.
### 0
       FROM ubuntu
### 1
 MAINTAINER George Georgulas IV <georgegeorgulasiv@gmail.com>
### 2
# Add volumes to be shared to host for configuration file access
     VOLUME  /etc/apache /etc/mysql /etc/php /usr/bin/rathena /var/lib/mysql /var/www/html
### 3
        CMD bash
### 4
 ENTRYPOINT /boottime.sh
### 5
       USER root
### 6
        ENV HOME /root
### 7
        ENV DEBIAN_FRONTEND noninteractive
### 8
# work in the /usr/bin/rathena directory (for when we configure and make later)
    WORKDIR /usr/bin/rathena/
### 9
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
### 10
        ADD 000-default.conf /etc/apache2/sites-available/
### 11
        ADD import.sql /
### 12
        ADD my.cnf /etc/mysql/conf.d/
### 13
        ADD boottime.sh /
### 14
# add the ‘localhost’ hostname to the apache2 configs
        RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
# clone FluxCP to /var/www/html from github
         && git clone https://github.com/rathena/FluxCP.git /var/www/html/tmp \
         && cp -R /var/www/html/tmp /var/www/html \
         && rm -rf /var/www/html/tmp \
# clone rAthena into /usr/bin/rathena from github
         && git clone https://github.com/rathena/rathena.git /usr/bin/rathena/tmp \
         && cp -R /usr/bin/rathena/tmp /usr/bin/rathena \
         && rm -rf /usr/bin/rathena/tmp \         
# configure make and select packet version 
         && ./configure --enable-packetver=20131223 \
# compile rAthena server binaries
         && make server \
# import rAthena mysql files
         && service mysql start \
         && mysql < /import.sql \
         && service mysql stop \
# cleaning up after ourselves
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
# Environment variables to configure php
### 15
        ENV PHP_UPLOAD_MAX_FILESIZE 10M
### 16
        ENV PHP_POST_MAX_SIZE 10M
### 17
### 18
# open ports for network access
     EXPOSE 80 443 3306 5121 6121 6900


# launch this container with a command something like this one:

# docker run -it -v ~/Desktop/ROServer/etc-apache:/etc/apache -v ~/Desktop/ROServer/etc-mysql:/etc/mysql -v ~/Desktop/ROServer/etc-php:/etc/php -v ~/Desktop/ROServer/usr-bin-rathena:/usr/bin/rathena -v ~/Desktop/ROServer/var-lib-mysql:/var/lib/mysql -v ~/Desktop/ROServer/var-www-html:/var/www/html -p 20000:80 -p 20001:443 -p 20002:3306 -p 20003:5121 -p 20004:6121 -p 20005:6900 -e USER=root georgegeorgulasiv/tritogeneia