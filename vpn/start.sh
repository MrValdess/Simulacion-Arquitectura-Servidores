#!/bin/sh
set -e

OVPN_DIR="/etc/openvpn"

echo "[+] Iniciando contenedor OpenVPN..."

# Inicialización 
if [ ! -f "$OVPN_DIR/openvpn.conf" ]; then
    echo "[+] Primera ejecución: generando configuración..."

    ovpn_genconfig -u udp://localhost
    echo "[+] Generando PKI..."
    EASYRSA_BATCH=1 ovpn_initpki nopass
fi

# Clientes y creacion de usuarios
mkdir -p "$OVPN_DIR/clients"

if [ ! -f "$OVPN_DIR/pki/private/user1.key" ]; then
    echo "[+] Creando usuario 1..."
    easyrsa build-client-full user1 nopass
fi

if [ ! -f "$OVPN_DIR/pki/private/user2.key" ]; then
    echo "[+] Creando usuario 2..."
    easyrsa build-client-full user2 nopass
fi

# Exportar a local
echo "[+] Exportando clientes..."

ovpn_getclient user1 > "$OVPN_DIR/clients/user1.ovpn"
ovpn_getclient user2 > "$OVPN_DIR/clients/user2.ovpn"

echo "[+] Arrancando servidor OpenVPN..."
exec ovpn_run