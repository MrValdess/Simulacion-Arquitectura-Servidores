#!/bin/sh

set -e

OVPN_DIR="/etc/openvpn"

echo "[+] Iniciando contenedor OpenVPN..."

# Si no existe configuración → inicializar
if [ ! -f "$OVPN_DIR/openvpn.conf" ]; then
    echo "[+] Primera ejecución: generando configuración..."

    ovpn_genconfig -u udp://localhost
    sed -i 's/server .*/server 172.10.0.0 255.255.255.0/' $OVPN_DIR/openvpn.conf

    echo "[+] Generando PKI..."
    EASYRSA_BATCH=1 ovpn_initpki nopass
fi

if [ ! -f "$OVPN_DIR/clients/user1.ovpn" ]; then
    echo "[+] Creando usuario user1..."
    easyrsa build-client-full user1 nopass
    ovpn_getclient user1 > $OVPN_DIR/clients/user1.ovpn
fi

echo "[+] Arrancando servidor OpenVPN..."
exec ovpn_run