#!/bin/bash

set -e

echo "[INIT] Instalando dependencias de Google Authenticator..."

apk add --no-cache google-authenticator iproute2 iputils-ping

echo "[INIT] Configurando rutas de red..."
ip route del default 2>/dev/null
ip route add default via 172.40.0.2

echo "[INIT] Configurando PAM..."

# Añadir Google Authenticator a PAM si no existe
if ! grep -q "pam_google_authenticator.so" /etc/pam.d/sshd; then
    echo "auth required pam_google_authenticator.so" >> /etc/pam.d/sshd
fi

echo "[INIT] Generando configuración del usuario..."

USER_HOME="/config/home/${USER_NAME:-user}"

mkdir -p "$USER_HOME"

if [ ! -f "$USER_HOME/.google_authenticator" ]; then
    echo "Primera ejecución de Google Authenticator..."
fi

echo "[INIT] Iniciando SSH..."
