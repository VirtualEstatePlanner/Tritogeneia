#!/bin/bash

service mysql start
echo “MySQL service started”
mysql -u root < /import.sql
echo “MySQL databases imported”
service mysql stop
echo “MySQL service stopped”