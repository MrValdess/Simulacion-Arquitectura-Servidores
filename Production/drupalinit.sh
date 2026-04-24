#!/bin/bash

if [ ! -d "/app/web" ]; then
    echo "Proyecto Drupal no encontrado, creando..."
    apt update
    apt install unzip
    rm 50x.html && rm index.html
    composer create-project drupal/recommended-project .
    chown -R daemon:daemon /app/
    chmod -R 755 /app/
    echo "Proyecto Drupal creado"
else
    echo "Proyecto Drupal encontrado, no se requiere instalacion. Continuando..."
    apt update
fi

useradd -m -s /bin/bash johndoe
exec php-fpm -F