```
                      _                   
                     | |                  
   ___  _ __ ______ _| | __ _  __ _  __ _ 
  / _ \| '__|_  / _` | |/ _` |/ _` |/ _` |
 | (_) | |   / / (_| | | (_| | (_| | (_| |
  \___/|_|  /___\__,_|_|\__,_|\__, |\__,_|
                               __/ |      
                              |___/       
```

# Backup Server Ubuntu Lamp
Paso a paso de como realizar una *copia de seguridad* manual de su LAMP instalado en un servidor Ubuntu.
**Script Bash** para efectuar una copia de seguridad del servidor web ubuntu mediante un script.
Crear un CRON para realizar una copia de seguridad automática en el servidor web ejecutando el script bash.

> Recomiendo ejecutar este script en un ambiente de pruebas antes de llevarlo a producción. Tambien recomiendo entender el paso a paso y realizar los cambios segun la configuracion o versiones que se tengan instaladas.

## Versión compatible con el proceso
- Server Ububtu 20.04
- Apache 2.4.41 (Ubuntu)
- MySQL 10.3.32-MariaDB-0ubuntu0.20.04.1
- PHP 7.4.3
- FPM-PHP
- Zip 3.0

## Instalar Zip 3.0
Este paquete es necesario para comprimir la copia de seguridad final.
```
sudo apt-get install -y zip
```

## Backup Archivos Apache

**Crear Carpeta Principal** 
Creamos una carpeta principal para almacenar todas las copias de seguridad. Esta parte solo la hacemos una sola vez. 
```
mkdir /var/backups/
```

**Generar Carpeta Diaria**
Creamos una carpeta principal incluyendo información de Fecha y Hora para tener un orden incremental en cada copia ejecutada. La idea es crear una carpeta al interior de ``/var/backups/`` cada vez que hagamos una copia de seguridad.

```bash
mkdir /var/backups/server-$(date +%b.%d.%y-%H:%M:%S)
```
Así debe quedar el nombre de la carpeta ``server-Feb.05.22-23:47:23/``
> Aqui creamos una carpeta que incluye la Fecha y hora de creación. Esto nos ayuda a tener claridad en las fechas en el momento que queramos restaurar una copia de seguridad. 


**Crear carpetas y respaldar Apache** 
Aquí creamos la carpeta apache y copiamos todos los archivos de configuración necesarios para su funcionamiento. Aqui creamos una carpeta con el nombre: ``apache/``
```bash 
cd /var/backups/server-{date-text}
mkdir apache
cp /etc/apache2/apache2.conf apache/
cp -R /etc/apache2/sites-enabled/ apache/sites-enabled/
cp -R /etc/apache2/sites-available/ apache/sites-available/
```


 **Copia de Archivos HTML** 
 
 Se realiza copia de seguridad de la carpeta ``html/`` teniendo la seguridad que esta se encuentra en la carpeta ```/var/www/html```  También podemos preferir hacer la copia de seguridad de toda el contenido en la carpeta ```www``` cambiando la carpeta final por ```/var/ www```
 
Comando para copia de carpeta ``html/``:
 ```bash 
 sudo tar -cvzpf www.tar.gz -C /var/www/ html
 ```
 
Comando para copia de carpeta ``www/``:
 ```bash 
 sudo tar -cvzpf www.tar.gz -C /var/ www
 ```

> Es importante que entiendas la funcionalidad de este comando para que puedas personalizar las carpetas que necesites realizar en la copia de seguridad. 


## Copia Configuración PHP
Generamos una nueva carpeta para alojar toda la configuración de los archivos PHP que tengamos en el servidor. En mi caso tengo el archivo que genera ```php-fmp``` y el archivo nativo que tiene PHP instalado por defecto. Los archivos tendrán el nombre de:  ``fpm-php.ini`` y ```cli-php.ini```
Aquí creamos una carpeta con el nombre: ``php/``

```bash 
mkdir php
cp /etc/php/7.4/fpm/php.ini php/fpm-php.ini
cp /etc/php/7.4/cli/php.ini php/cli-php.ini
```

> Debes tener claro que segun tu configuracion el archivo *php.ini* puede estar en una carpeta totalmente diferente a la que propongo. Por tal motivo asegurate de que el archivo es el correcto.


## Copia Base de Datos MySQL
Vamos a ejecutar el proceso de copia de seguridad para la base de datos y todos los archivos de configuración necesarios. Aqui creamos una carpeta con el nombre: ``mysql/``

```bash
mkdir mysql
cp /etc/mysql/my.cnf mysql
mkdir mysql/database
```


**Exportar las bases de datos**
Usar la opción ``--all-databases`` nos exportará todas las bases de datos en un solo archivo. En el momento de hacer una restauracion de esta base de datos, se debe importar con la misma opción ``--all-databases``

```bash
mysqldump --user $USERNAME --password=$PASSWORD --all-databases > mysql/databases/_all.sql
```


## Comprimir Archivos

Vamos a nuestra carpeta principal de backups ``/var/backups/`` y desde alli generamos un archivo zip con la carpeta que hemos creado y que incluye en el nombre del archivo la hora y la hora, viendose de la siguiente manera: ``server-Feb.05.22-23:47:23/`` En la línea que propongo ``server-{date-text}/`` colocar el nombre correcto de la carpeta que incluye hora y fecha.  
```bash
cd ..
zip -r backup-$(date +%b.%d.%y-%H:%M:%S).zip server-{date-text}/
```


**Borrar Carpeta con Archivos**
Tener cuidado con este paso, ya que vamos a borrar solo la carpeta en donde generamos las copias de seguridad y no el archivo ```.zip``` que hemos creado en el último paso y sería el archivo al cual vamos a respaldar en un servidor externo. 

```bash
rm -rf server-{date-text}/
```
Recuerda remplazar ``server-{date-text}/`` por el nombre generado correctamente con la fecha y hora. 

## Estructura carpetas y copia de seguridad
Ejemplo de la estructura que debe tener la carpeta individual por dia de la copia de seguridad. Para este caso utilizamos la estructura de la carpeta: ``server-Feb.05.22-23:47:23/``
```
$ /var/backup/
.
server-Feb.05.22-23:47:23/
├── apache
│	 ├── sites-enabled/*
│	 ├── sites-available/*
│ └── apache2.conf
├── php
│  └── cli-php.ini
│	└── fpm-php.ini
├── mysql
│	 ├── database/*
│ └── my.cnf
└── www.tar.gz

6 directorios, 8 files
```

## Archivo Bash 
Se ha creado un bash script que pueda ejecutar todo este proceso desde el script: ``backup.sh`` y el cual debemos ejecutar con el usuario y clave de la base de datos MySQL

**Modo de uso**
 -  Obtener archivo  [backup.sh](https://github.com/orzalaga/backup-ubuntu-lamp/blob/main/backup.sh)
 -  Otorgar permisos `sudo chmod +x backup.sh`
 -  Ejecutar script  ``./build.sh username password`` (Usuario y clave root de MySQL)
