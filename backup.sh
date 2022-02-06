#!/bin/bash -x
## JULIO CESAR VELASQUEZ MEJIA
## orzalata@pm.me
## Uso:
## sudo chmod +x backup.sh
## ./backup.sh {username} {password}


## Inicio Script
##
##
if [ $# -ne 2 ]
then
    echo "Usage: sudo ./`basename $0` {username} {password}"
    exit 0
fi
USERNAME=$1
PASSWORD=$2

## Crear Directorio Principal
## Tener en cuenta que debe estar creado el direcotiro: /var/backups/
##
cd /var/backups/
directoryName="server-`date +%b.%d.%y-%H:%M:%S`"
mkdir $directoryName


## Crear Directorio Principal
##
##
cd /var/backups/tevendotucoche/
directoryName="server-`date +%b.%d.%y-%H:%M:%S`"
mkdir $directoryName


## Copia Apache
##
##
mkdir $directoryName/apache
cp /etc/apache2/apache2.conf $directoryName/apache
cp -R /etc/apache2/sites-enabled/ $directoryName/apache/sites-enabled/
cp -R /etc/apache2/sites-available/ $directoryName/apache/sites-available/

## Copia Contenido de www/html
##
##
sudo zip -r $directoryName/www.zip /var/www/html/

## Copia archivos PHP
##
##
mkdir $directoryName/php
cp /etc/php/7.4/fpm/php.ini $directoryName/php/fpm-php.ini
cp /etc/php/7.4/cli/php.ini $directoryName/php/cli-php.ini


## Copia Base de datos MySQL
##
##
mkdir $directoryName/mysql
cp /etc/mysql/my.cnf $directoryName/mysql

mkdir $directoryName/mysql/databases
mysqldump --user $USERNAME --password=$PASSWORD --all-databases > $directoryName/mysql/databases/_all.sql

mysql --user $USERNAME --password=$PASSWORD -e "show databases;" -s | awk '{ if (NR > 2 ) {print } }' |
while IFS= read -r database; do
    mysqldump --user $USERNAME --password=$PASSWORD "$database" > $directoryName/mysql/databases/$database.sql
done


## Comprimir Carpeta en ZIP
##
##
zip -r backup-$(date +%b.%d.%y-%H:%M:%S).zip $directoryName/


## Borrar directorio Creado
##
##
rm -rf $directoryName/
