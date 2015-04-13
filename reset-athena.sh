#!/bin/bash
    echo "creating new server from /datastoresetup/"
    rsync -az /datastoresetup/etc-apache2/ /etc/apache2/
    rsync -az /datastoresetup/etc-mysql/ /etc/mysql/
    rsync -az /datastoresetup/usr-bin-rathena/ /usr/bin/rathena/
    rsync -az /datastoresetup/var-lib-mysql/ /var/lib/mysql/
    rsync -az /datastoresetup/var-www-html/ /var/www/html/
    service mysql restart
    service apache2 restart
    echo "server setup complete"
