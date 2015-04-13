#!/bin/bash
    echo "backing up server setup to /datastore/"
    rsync -az /etc/apache2/ /datastore/etc-apache2/
    rsync -az /etc/mysql/ /datastore/etc-mysql/
    rsync -az /usr/bin/rathena/ /datastore/usr-bin-rathena/
    rsync -az /var/lib/mysql/ /datastore/var-lib-mysql/
    rsync -az /var/www/html/ /datastore/var-www-html/
    echo "Server backup completed."
