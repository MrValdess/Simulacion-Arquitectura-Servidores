#!/bin/sh

set -e

OVPN_DIR="/etc/openvpn"

echo "[+] Iniciando contenedor OpenVPN..."

# Si no existe configuración → inicializar
if [ ! -f "$OVPN_DIR/openvpn.conf" ]; then
    echo "[+] Primera ejecución: generando configuración..."

    ovpn_genconfig -u udp://localhost

    echo "[+] Generando PKI..."
    EASYRSA_BATCH=1 ovpn_initpki nopass
fi

echo "[+] Arrancando servidor OpenVPN..."
exec ovpn_run