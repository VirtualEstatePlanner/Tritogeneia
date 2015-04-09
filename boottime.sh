#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
    echo "=> Using an existing volume of MySQL"
    service apache2 start
    service mysql start
    mysql < /import.sql
    cd /usr/bin/rathena
    ./athena-start start
exec supervisord -n
