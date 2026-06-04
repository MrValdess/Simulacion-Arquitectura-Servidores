#!/bin/bash

MYSQL_ROOT_PASSWORD="password"
POSTGRES_PASSWORD="password"

BACKUP_DIR="/backups"
DEV_DB_DIR="/dev"
PROD_DB_DIR="/prod"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR$DEV_DB_DIR"
mkdir -p "$BACKUP_DIR$PROD_DB_DIR"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: No se pudo crear el directorio de backups."
    exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "Error: La variable MYSQL_ROOT_PASSWORD no está definida."
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "Error: La variable POSTGRES_PASSWORD no está definida."
    exit 1
fi

echo "Iniciando copia de seguridad de MySQL..."

if ! mysqldump \
    -h mysql \
    -u root \
    --skip-ssl \
    -p"$MYSQL_ROOT_PASSWORD" \
    --all-databases \
    > "$BACKUP_DIR$DEV_DB_DIR/mysql-backup-$TIMESTAMP.sql"
then
    echo "Error: Falló la copia de seguridad de MySQL."
    exit 1
fi

echo "Iniciando copia de seguridad de PostgreSQL..."

if ! PGPASSWORD="$POSTGRES_PASSWORD" pg_dumpall \
    -h postgresql \
    -U nginx \
    > "$BACKUP_DIR$PROD_DB_DIR/postgres-backup-$TIMESTAMP.sql"
then
    echo "Error: Falló la copia de seguridad de PostgreSQL."
    exit 1
fi

echo "Copias generadas correctamente $TIMESTAMP."