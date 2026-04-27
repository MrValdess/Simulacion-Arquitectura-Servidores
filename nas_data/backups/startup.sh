#!/bin/bash

# Actualizar el sistema e instalar rsync si no está instalado
echo "Actualizando el sistema e instalando rsync"
apt update && apt install -y rsync
apt install -y net-tools

# Crear el archivo de configuración de rsync
echo "Creando archivo de configuración de rsync..."
cat <<EOF | tee /etc/rsyncd.conf
# Configuración del servidor rsync
uid = nobody
gid = nogroup
use chroot = yes
max connections = 10
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
timeout = 300

[backups]
    path = /backups
    comment = Mi directorio para rsync
    read only = no
    list = yes
    auth users = johndoe
    secrets file = /etc/rsyncd.secrets
EOF

# Crear el archivo de contraseñas para rsync
echo "Creando archivo de contraseñas..."
cat <<EOF | tee /etc/rsyncd.secrets
johndoe:uca2026
EOF

# Cambiar los permisos del archivo de contraseñas para asegurar que solo root pueda leerlo
chmod 600 /etc/rsyncd.secrets
chmod -R 777 /backups

# Iniciar el servicio rsync de manera manual (sin usar systemd)
echo "Iniciando rsync..."
rsync --daemon --no-detach

# Verificar que el puerto 873 está en escucha
echo "Verificando si rsync está escuchando en el puerto 873..."
netstat -tulnp | grep 873

echo "Servidor rsync levantado en el puerto 873 con éxito."

