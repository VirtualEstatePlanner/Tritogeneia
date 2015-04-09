#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
    echo “launching apache”
    source /etc/apache2/envvars
    service apache2 start
    echo “success!”
    echo “launching mysql”
    service mysql start
    echo “success!”
    echo “importing default database”
    mysql < /import.sql
    echo “success!”
    cd /usr/bin/rathena
    echo “launching rAthena”
    ./athena-start start
    echo “success!”
while [ 1 ]; do
    /bin/bash
done
