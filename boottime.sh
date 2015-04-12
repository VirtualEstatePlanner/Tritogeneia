#!/bin/bash
VOLUME_HOME="/var/lib/mysql"
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
    echo "copying initial files to host volume at /datastore/"
    rsync -az /etc/apache2/ /datastore/etc-apache2/
    rsync -az /etc/mysql/ /datastore/etc-mysql/
    rsync -az /usr/bin/rathena/ /datastore/usr-bin-rathena/
    rsync -az /var/lib/mysql/ /datastore/var-lib-mysql/
    rsync -az /var/www/html/ /datastore/var-www-html/
    echo "rsync complete"
    echo "launching apache"
    service apache2 start
    echo "success!"
    echo "launching mysql"
    service mysql start
    echo "success!"
    echo "importing default database"
    mysql < /import.sql
    echo "success!"
    cd /usr/bin/rathena
    echo "launching rAthena"
    ./athena-start start
    echo "success!"
while [ 1 ]; do
    /bin/bash
done
