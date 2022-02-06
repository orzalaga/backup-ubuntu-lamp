#!/bin/bash -x
## JULIO CESAR VELASQUEZ MEJIA
## orzalata@pm.me
## Usage:
## sudo chmod +x backup.sh
## ./backup.sh {username} {password}


## 0.1 Username
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
##
##
cd
directoryName="server-`date +%b.%d.%y-%H:%M:%S`"
mkdir $directoryName


## Copia Apache
##
##
mkdir ~/$directoryName/apache
cp /etc/apache2/apache2.conf ~/$directoryName/apache
cp -R /etc/apache2/sites-enabled/ ~/$directoryName/apache/sites-enabled/
cp -R /etc/apache2/sites-available/ ~/$directoryName/apache/sites-available/

## Copia Contenido de www/html
##
##
sudo tar -cvzpf ~/$directoryName/www.tar.gz -C /var/www/ html

## Copia archivos PHP
##
##
mkdir ~/$directoryName/php
cp /etc/php/7.4/fpm/php.ini ~/$directoryName/php/fpm-php.ini
cp /etc/php/7.4/cli/php.ini ~/$directoryName/php/cli-php.ini


## Copia Base de datos MySQL
##
##
mkdir ~/$directoryName/mysql
cp /etc/mysql/my.cnf ~/$directoryName/mysql

mkdir ~/$directoryName/mysql/databases
mysqldump --user $USERNAME --password=$PASSWORD --all-databases > ~/$directoryName/mysql/databases/_all.sql

mysql --user $USERNAME --password=$PASSWORD -e "show databases;" -s | awk '{ if (NR > 2 ) {print } }' |
while IFS= read -r database; do
    mysqldump --user $USERNAME --password=$PASSWORD "$database" > ~/$directoryName/mysql/databases/$database.sql
done


## Comprimir Carpeta en ZIP
##
##
zip -r ~/$directoryName.zip ~/$directoryName/


## Borrar directorio Creado
##
##
rm -rf ~/$directoryName/
