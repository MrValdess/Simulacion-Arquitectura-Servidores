# Simulación de Arquitectura de Servidores en una empresa

Este proyecto simula una infraestructura completa de servicios en red
utilizando **Docker Compose**, con segmentación de redes, servicios de
producción y desarrollo, y un sistema de backups automatizado.

------------------------------------------------------------------------

## Objetivo del proyecto

El objetivo es replicar un entorno real de arquitectura de servidores
de una empresa, donde podemos encontrar algunos de los siguientes elementos:

-   Entorno de **desarrollo** 
-   Entorno de **producción**
-   Servicios compartidos
-   Sistema de **backups**
-   DNS interno
-   VPN
-   Filtrado de tráfico mediante iptables


------------------------------------------------------------------------

## Arquitectura general

El sistema está dividido en varias redes:

-   `development_net` → Simulación de la red de desarrollo 
-   `production_net` → Simulación de la red de producción
-   `services_net` → Red donde se encuentran los servicios compartidos (DNS, NAS, mail, etc.)
-   `vpn_net` → Acceso a la red mediante VPN

------------------------------------------------------------------------

## Servicios desplegados

### Desarrollo

-   Apache 
-   MySQL
-   SSH con autenticación por usuario y contraseña
-   Samba
-   FTP

### Producción

-   Nginx
-   PostgreSQL

### Servicios 

-   DNS interno mediante bind9
-   Almacenamiento en la nube mediante NAS
-   Servidor de correo usando SMTP/IMAP
-   SSH con autenticación por claves
-   OpenVPN

### Contenedor de pruebas

-   Es un contenedor con todas las dependencias instaladas para poder 
    testear los cambios realizados en los servicios
-   Incluye todas las herramientas necesarias para comprobar todos los 
    contenedores de la red

------------------------------------------------------------------------

## Sistema de backups

El contenedor NAS realiza copias de seguridad automatizadas mediante cron de
las bases de datos MySQL y PostgreSQL. Son respaldadas diariamente a las 02:00
en las rutas:

/backups/dev /backups/prod

Si es necesario un respaldo manual solo hay que ejecutar el script /backups/backup.sh
dentro del contenedor.

------------------------------------------------------------------------

## Firewall 

Se implementa un firewall basado en iptables para filtrar el tráfico. Se encarga de filtrar:

-   Reglas de comunicación entre Desarrollo, Producción y Servicios
-   La comunicación entre las Bases de datos y el NAS
-   El acceso y consultas al servidor DNS
-   Restricciones de FTP entre Desarrollo y Producción
-   Reglas para los usuarios VPN

------------------------------------------------------------------------

## DNS interno

El servidor bind9 proporciona resolución de nombres interna entre
contenedores. En el caso de querer modificar los nombres solo hay que modificar 
\bind\config\zones\db.empresa.local con las ips o nombres deseadas

------------------------------------------------------------------------

## VPN

Se incluye un servidor OpenVPN para acceso remoto. El inicializador de OpenVPN tambien
crea varios usuarios y los exporta a la carpeta \vpn\ovpn-data\clients por si se desea 
acceder mediante una interfaz gráfica.

------------------------------------------------------------------------

## SSH

El servidor de SSH de services es solo accesible mediante un par de claves. Para facilitar al 
usuario acceder a este sin problemas se le exporta la clave pública del usuario creado
en la carpeta \ssh\services\keys, incluyendo el archivo de authorized_keys.

