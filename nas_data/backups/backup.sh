#!/bin/bash

MYSQL_ROOT_PASSWORD="password"
POSTGRES_PASSWORD="password"
BACKUP_DIR="/backups"  # Este es el directorio dentro del contenedor
DEV_DB_DIR="/dev"
PROD_DB_DIR="/prod"
TIMESTAMP=$(date +"%Y-%m-%d - %H:%M")

# Verifica que el directorio de backups exista
mkdir -p "$BACKUP_DIR"
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Error: No se pudo crear el directorio de backups."
  exit 1
fi
mkdir -p "$BACKUP_DIR$DEV_DB_DIR"
mkdir -p "$BACKUP_DIR$PROD_DB_DIR"

# Verifica que las variables de entorno estén definidas
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "Error: La variable MYSQL_ROOT_PASSWORD no está definida."
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "Error: La variable POSTGRES_PASSWORD no está definida."
  exit 1
fi

# Copia de seguridad de MySQL
echo "Iniciando copia de seguridad de MySQL..."
if ! mysqldump -h 172.40.0.6 -u root -p"$MYSQL_ROOT_PASSWORD" --all-databases > "$BACKUP_DIR$DEV_DB_DIR/mysql-backup-$TIMESTAMP.sql"; then
  echo "Error: Falló la copia de seguridad de MySQL."
  exit 1
fi

# Copia de seguridad de PostgreSQL
echo "Iniciando copia de seguridad de PostgreSQL..."
if ! PGPASSWORD="$POSTGRES_PASSWORD" pg_dumpall -h 172.30.0.8 -U drupal > "$BACKUP_DIR$PROD_DB_DIR/postgres-backup-$TIMESTAMP.sql"; then
  echo "Error: Falló la copia de seguridad de PostgreSQL."
  exit 1
fi

echo "Copia de seguridad completada."
