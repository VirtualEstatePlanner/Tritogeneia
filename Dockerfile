FROM ubuntu:trusty
MAINTAINER George Georgulas IV <georgegeorgulas@gmail.com>

# Initial setup
USER root
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Install applications, remove default databases, name apache2 server
  # install stuff
    RUN \
     apt-get update \
     && apt-get -y dist-upgrade \
     && apt-get -y install \
        gcc \
        git \
        apache2 \
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
        zlib1g-dev
  # Add the name of the server to /etc/apache2/apache2.conf file
    RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
  # Delete stock mysql database
    RUN rm -rf /var/lib/mysql/*

# git clone things into place and set them up
  # git clone FluxCP into place 
    WORKDIR /var/www/html/
    RUN git clone https://github.com/rathena/FluxCP.git
 # git clone rAthena into place
    WORKDIR /usr/bin/
    RUN git clone https://github.com/rathena/rathena.git
    WORKDIR /usr/bin/rathena/
    RUN \
  # move the sql files for rAthena into /var/lib/mysql
    mv sql-files/ /var/lib/mysql && \
  # configure make and select packet version 
    ./configure --enable-packetver=20131223 && \
  # compile rAthena server binaries
     make server && \
  # CHMOD server binaries to be executable by anyone
     chmod 755 *-server && \
     chmod 755 athena-start

# add our custom scripts and configurations, CHMOD a few scripts
  # add image configuration and scripts
    WORKDIR /
    ADD my.cnf /etc/mysql/conf.d/my.cnf
    ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
    ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
    ADD start-apache2.sh /start-apache2.sh
    ADD start-mysqld.sh /start-mysqld.sh
    ADD run.sh /run.sh
    ADD import.sql /import.sql
    ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
    RUN chmod 755 /start-apache2.sh
    RUN chmod 755 /start-mysqld.sh
    RUN chmod 755 /run.sh
    RUN chmod 755 /create_mysql_admin_user.sh

  # config to enable .htaccess
    ADD apache_default /etc/apache2/sites-available/000-default.conf
###    RUN  a2enmod rewrite

  # Environment variables to configure php
    ENV PHP_UPLOAD_MAX_FILESIZE 10M
    ENV PHP_POST_MAX_SIZE 10M

  # Add volumes for external data access to MySQL, apache, FluxCP, etc. 
     VOLUME [ “/etc/apache2”, \
      ”/etc/mysql", \
      “/etc/www/html”, \
      “/usr/bin/rathena”, \
      ”/var/lib/mysql” ]

# Open network service ports
EXPOSE \
  22    \
 # ssh
  80    \
 # http
  443   \
 # ssl and https
  3306  \
 # mysql
  5121  \
 # char-server
  6121  \
 # login-server
  6900   
 # map-server

CMD /bash
ENTRYPOINT /run.sh

# docker run -i -t --rm -p 20000:22 -p 20001:80 -p 20002:443 -p 20003:3306 -p 20004:5121 -p 20005:6121 -p 20006:6900 -e USER=root --name BoxOfRags georgegeorgulasiv/flameproer:development