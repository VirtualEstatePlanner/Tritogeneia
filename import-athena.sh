#!/bin/bash 
    echo "copying initial files to host volume at /datastore/"
    rsync -az /datastore/etc-apache2/ /etc/apache2/
    rsync -az /datastore/etc-mysql/ /etc/mysql/
    rsync -az /datastore/usr-bin-rathena/ /usr/bin/rathena/
    rsync -az /datastore/var-lib-mysql/ /var/lib/mysql/
    rsync -az /datastore/var-www-html/ /var/www/html/
    echo "rsync complete"
    service mysql restart
    service apache2 restart
    echo "success!"