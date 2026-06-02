#!/bin/bash
set -e

echo "Instalando dependencias de Apache..."

apt update && apt install -y smbclient ftp

a2enmod rewrite
a2enmod auth_basic

a2dissite 000-default.conf

a2ensite www.conf
a2ensite intranet.conf

htpasswd -bc /etc/apache2/.htpasswd documentos 'GraTiS!'

apache2ctl configtest
apache2ctl restart

echo "Iniciando Apache..."

exec apache2-foreground