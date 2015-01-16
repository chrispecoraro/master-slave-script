#!/bin/bash

IPADDR=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'` ;

cp my.cnf my.backup.cnf;

sed -i s/127\.0\.0\.1/"$IPADDR"/g  /etc/mysql/my.cnf 

sed -i s/#server-id/server-id/g  /etc/mysql/my.cnf 

sed -i s/#log_bin/log_bin/g  /etc/mysql/my.cnf 

sudo service mysql restart

read -e -p "Enter the name of the master database: "  DATABASE

read -e -p "Enter the password of the master database: "  DATABASEPASSWORD

read -e -p "Enter the name of the slave database user: "  DATABASEUSER

read -e -p "Enter the password of the slave database user: "  DATABASESLAVEPASSWORD

read -e -p "Enter the destination where you want to save the mysqldump file: (use trailing slash)  "  -i "/root/" DATABASEDUMPPATH

echo  "GRANT REPLICATION SLAVE ON *.* TO '$DATABASEUSER'@'%' IDENTIFIED BY '$DATABASESLAVEPASSWORD';" | mysql -u root -p"$DATABASEPASSWORD" 

echo  "FLUSH PRIVILEGES;" | mysql -u root -p"$DATABASEPASSWORD" 

echo  "USE $DATABASE;" | mysql -u root -p"$DATABASEPASSWORD" 

echo  "FLUSH TABLES WITH READ LOCK;" | mysql -u root -p"$DATABASEPASSWORD" 

echo  "SHOW MASTER STATUS;" | mysql -u root -p"$DATABASEPASSWORD" 

mysqldump -u root -p"$DATABASEPASSWORD"  --opt "$DATABASE" > "$DATABASEDUMPPATH$DATABASE".sql

echo "database $DATABASE saved to $DATABASEDUMPPATH$DATABASE.sql"

echo  "UNLOCK TABLES;" | mysql -u root -p"$DATABASEPASSWORD" 
