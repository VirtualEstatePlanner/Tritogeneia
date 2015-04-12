# this is a Dockerfile to build an auto-starting docker container of an entire rAthena stack including FluxCP to manage access to the server from a website.
       FROM ubuntu
 MAINTAINER George Georgulas IV <georgegeorgulasiv@gmail.com>
        ENV DEBIAN_FRONTEND noninteractive
        CMD bash
        ADD boottime.sh /
 ENTRYPOINT /boottime.sh
       USER root
        ENV HOME /root
    WORKDIR /usr/bin/rathena/		
        RUN apt-get update \
         && echo "}}}}}}}}}}}}}}}————> Apt repositories updated."
        RUN apt-get -y dist-upgrade \
         && echo "}}}}}}}}}}}}}}}————> Apt distribution upgrade completed."
        RUN apt-get -y --force-yes install apache2 \
         && echo "}}}}}}}}}}}}}}}————> Package installation (apache2) completed."
        ADD 000-default.conf /etc/apache2/sites-available/
        RUN echo "}}}}}}}}}}}}}}}————> Apache available sites configuration added."
        RUN apt-get -y --force-yes install gcc \
         && echo "}}}}}}}}}}}}}}}————> Package installation (gcc) completed."
        RUN apt-get -y --force-yes install git \
         && echo "}}}}}}}}}}}}}}}————> Package installation (git) completed."
        RUN apt-get -y --force-yes install libapache2-mod-php5 \
         && echo "}}}}}}}}}}}}}}}————> Package installation (libapache2-mod-php5) completed."
        RUN apt-get -y --force-yes install libmysqlclient-dev \
         && echo "}}}}}}}}}}}}}}}————> Package installation (libmysqlclient-dev) completed."
        RUN apt-get -y --force-yes install libpcre3-dev \
         && echo "}}}}}}}}}}}}}}}————> Package installation (libpcre3-dev) completed."
        RUN apt-get -y --force-yes install make \
         && echo "}}}}}}}}}}}}}}}————> Package installation (make) completed."
        RUN apt-get -y --force-yes install mysql-client \
         && echo "}}}}}}}}}}}}}}}————> Package installation (mysql-client) completed."
        RUN apt-get -y --force-yes install mysql-server \
         && echo "}}}}}}}}}}}}}}}————> Package installation (mysql-server) completed."
        RUN apt-get -y --force-yes install php5-mysql \
         && echo "}}}}}}}}}}}}}}}————> Package installation (php5-mysql) completed."
        RUN apt-get -y --force-yes install php-apc \
         && echo "}}}}}}}}}}}}}}}————> Package installation (php-apc) completed."
        RUN apt-get -y --force-yes install php5-mcrypt \
         && echo "}}}}}}}}}}}}}}}————> Package installation (php5-mcrypt) completed."
        RUN apt-get -y --force-yes install zlib1g-dev \
         && echo "}}}}}}}}}}}}}}}————> Package installation (zlib1g-dev) completed."
        ADD my.cnf /etc/mysql/conf.d/
        RUN echo "}}}}}}}}}}}}}}}————> MySQL configuration added."
        RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
         && rm -fr /var/www/html \
         && git clone https://github.com/rathena/FluxCP.git /var/www/html \
         && git clone https://github.com/rathena/rathena.git /usr/bin/rathena \
         && echo "}}}}}}}}}}}}}}}————> FluxCP and rAthena cloning completed."
        RUN ./configure --enable-packetver=20131223 \
         && make server \
         && echo "}}}}}}}}}}}}}}}————> Compiling of rAthena completed."
        ADD import.sql /
        RUN service mysql start \
         && mysql < /import.sql \
         && service mysql stop \
         && rm -f /import.sql \
         && echo "}}}}}}}}}}}}}}}————> MySQL rAthena default database created."
        RUN apt-get -y remove gcc git make \
         && echo "}}}}}}}}}}}}}}}————> Apt removal of build tools completed."
        RUN apt-get -y autoremove \
         && echo "}}}}}}}}}}}}}}}————> Apt automatic removal of unnecessary packages completed."
        RUN chmod a+x /usr/bin/rathena/*-server \
			/usr/bin/rathena/athena-start \
			/boottime.sh \
         && echo "}}}}}}}}}}}}}}}————> Executable flag for launchers, binaries, and shell scripts set."
        RUN chmod -R 777 /var/www/html/data \
         && chown -R 33:33 /var/www/html/data \
         && echo "}}}}}}}}}}}}}}}————> File permissions changed."
        RUN a2enmod rewrite  \
         && echo "}}}}}}}}}}}}}}}————> Usage of .htaccess enabled."
        ENV PHP_UPLOAD_MAX_FILESIZE 10M
        ENV PHP_POST_MAX_SIZE 10M
        RUN echo "}}}}}}}}}}}}}}}————> PHP environmental variables set."
     EXPOSE 80 443 3306 5121 6121 6900
        RUN echo "}}}}}}}}}}}}}}}————> Network ports opened."
        ENV DEBIAN_FRONTEND interactive

# replace with volumes-from in launch command and create data container
# Add volumes to be shared to host for configuration file access
#     VOLUME /etc/apache2 /etc/mysql /etc/php /usr/bin/rathena /var/lib/mysql /var/www/html 


# use this container with a command like:
# docker run -it -p 20000:80 -p 20001:443 -p 20002:3306 -p 20003:5121 -p 20004:6121 -p 20005:6900 -v ~/Desktop/ROServer/settings-apache:/etc/apache2 -v ~/Desktop/ROServer/settings-mysql:/etc/mysql -v ~/Desktop/ROServer/settings-php:/etc/php -v ~/Desktop/ROServer/files-rathena:/usr/bin/rathena -v ~/Desktop/ROServer/files-mysql:/var/lib/mysql -v ~/Desktop/ROServer/files-apache:/var/www/html  -e USER=root georgegeorgulasiv/tritogeneia