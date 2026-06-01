#!/bin/bash
set -e

echo "Instalando dependencias de Drupal..."

apt update && apt install -y smbclient

# echo "Test" > test.txt
# smbclient //172.40.0.20/publico -U empleado1

echo "Iniciando Drupal..."

exec apache2-foreground