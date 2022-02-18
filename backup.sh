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

## Notificarle al Script donde procedemos a realizar las copias de seguridad.
##
##
FOLDER=/var/backups/
cd $FOLDER
##Creamos una carpeta con el formato de fecha y hora completo
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
backupName="backup-`date +%b.%d.%y-%H:%M:%S`"
zip -r $backupName.zip $directoryName/


## Borrar directorio Creado
##
##
rm -rf $directoryName/

#Proceso copia en servidor FTP. Aqui agregamos todos los datos de acceso.
HOST='10.10.10.10'
USER='USER'
PASSWD='PASSWD'
FILE=$backupName.zip

curl --upload-file $FOLDER/$FILE ftp://$USER:$PASSWD@$HOST

##Borramos la copia de seguridad local para dejarla sola en el servidor remoto FTP
##Es opcional este punto si queremos almacenar igualmente de manera local una copia de seguridad
rm -rf $backupName.zip

exit 0
