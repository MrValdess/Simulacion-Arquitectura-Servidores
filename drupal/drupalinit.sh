#!/bin/bash
set -e

echo "Instalando dependencias de Drupal..."

apt update && apt install -y smbclient

echo "Iniciando Drupal..."

exec apache2-foreground