#!/bin/bash

set -e

KEY_DIR="/config/keys"
PRIVATE_KEY="$KEY_DIR/id_rsa"
PUBLIC_KEY="$KEY_DIR/id_rsa.pub"
AUTHORIZED_KEYS="$KEY_DIR/authorized_keys"

mkdir -p "$KEY_DIR"

if [ ! -d "$KEY_DIR" ]; then
  echo "[INIT] Creando directorio $KEY_DIR..."
  mkdir -p "$KEY_DIR"
fi

echo "[INIT] Comprobando claves SSH..."

# 1. Si no existe clave privada, la creamos
if [ ! -f "$PRIVATE_KEY" ]; then
  echo "[INIT] No existe clave. Generando par de claves..."

  ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY" -N ""

  echo "[INIT] Claves generadas"
else
  echo "[INIT] Clave ya existe, reutilizando"
fi

if [ -f "$PUBLIC_KEY" ]; then
  echo "[INIT] Actualizando authorized_keys..."
  cat "$PUBLIC_KEY" > "$AUTHORIZED_KEYS"
else
  echo "[ERROR] No existe clave pública"
  exit 1
fi

# 3. Permisos correctos (IMPORTANTE para SSH)
chmod 600 "$PRIVATE_KEY" || true
chmod 644 "$PUBLIC_KEY" "$AUTHORIZED_KEYS" || true

echo "[INIT] SSH keys listas"