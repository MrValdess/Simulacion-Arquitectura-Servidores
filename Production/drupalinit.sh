#!/bin/bash

echo "Iniciando contenedor Drupal..."

apt update && apt install -y unzip default-mysql-client

# Crear proyecto Drupal si no existe
if [ ! -d "/var/www/html/web" ]; then
    echo "Proyecto Drupal no encontrado, creando..."
    rm 50x.html && rm index.html
    composer create-project drupal/recommended-project .
    chown -R daemon:daemon /app/
    chmod -R 755 /app/
    echo "Proyecto Drupal creado"
else
    echo "Proyecto Drupal encontrado, no se requiere instalacion. Continuando..."
fi

useradd -m -s /bin/bash johndoe

echo "Iniciando Apache..."
exec apache2-foreground